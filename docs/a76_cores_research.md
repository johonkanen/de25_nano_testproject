# Cortex-A76 cores (CPU2/CPU3) not coming online - research

Date: 2026-10-17. This was desk research only: nobody touched the board or JTAG. Tags:
**[verified: source]** means checked in source code, tool output or a primary document.
**[unverified]** means inferred or not yet checked.

## TL;DR

The bitstream that was flashed still has the A76 cores **switched off**. Setting
`Pwr_a76_core2_on/_core3_on = true` in `hps/ip/hps_subsys/agilex_hps.ip` never
reached synthesis, because the generated HDL for that IP is stale and the
project's IP regeneration policy is *Never Regenerate IPs*:

| Evidence | Value | Tag |
|---|---|---|
| `hps/ip/hps_subsys/agilex_hps.ip` (mtime 2026-10-16 23:29) | `Pwr_a76_core2_on = true`, `Pwr_a76_core3_on = true` | [verified: source] |
| Generated `hps/ip/hps_subsys/agilex_hps/intel_sundancemesa_hps_100/synth/agilex_hps_intel_sundancemesa_hps_100_vzqm2di.v` (mtime **20:59**, before the .ip edit) line 944 | `.soc_hps_wrapper_hps_a76_core_selection("HPS_A76_CORE_SELECTION_OFF")` | [verified: source] |
| `hps/ip/hps_subsys/agilex_hps/agilex_hps.html` (generated report) | `Pwr_a76_core2_on false`, `Pwr_a76_core3_on false` | [verified: source] |
| `output_files/de25_nano_uart.syn.rpt` line 318 | synthesis read `..._vzqm2di.v` (the stale OFF file) | [verified: tool output] |
| `output_files/de25_nano_uart.ipg.rpt` | `IP Regeneration Policy ; Never Regenerate IPs` | [verified: tool output] |
| Quartus 26.1.1 `common/tcl/internal/ipg/ipg_common_utils.tcl`, `should_generate_synth_files_based_on_regeneration_policy_and_clear_dirs_option` | under NEVER policy: if `<gen_dir>/agilex_hps.qip` exists, it skips generation ("Previously generated synthesis files were detected ...") | [verified: source] |
| Scratch `qsys-generate` of a **copy** of the current .ip (`--part=A5EB013BB23BE4SCS`) | new file `..._a5txmaq.v` with `HPS_A76_CORE_SELECTION_DUAL`. Apart from the hash, it is the **only** line that differs from the stale file. | [verified: tool output] |
| Terasic GHRD (`~/dev/golden_nano`, `~/dev/de25_nano`) and Altera GSRD 065 `baseline-a55` generated HDL | `HPS_A76_CORE_SELECTION_DUAL` | [verified: source] |

The Linux symptom fits a core that never executed a single instruction. That
is consistent with power-gated A76 cores. Each point below is [verified: source]:
- `linux-altera/arch/arm64/kernel/smp.c __cpu_up()`: PSCI CPU_ON returned 0, so ATF reported success. Otherwise Linux prints "failed to boot: <err>". `secondary_data.status` stayed `CPU_MMU_OFF`, and `__early_cpu_boot_status` stayed at its initial 0. The result is "failed in unknown state : 0x0": the core never reached the kernel's `secondary_entry`.
- ATF `socfpga_pwr_domain_on()` (agilex5) writes the reset vector, sets the `MPU_PCHCTLR` bit and writes `CPUSTRELEASE`, then returns `PSCI_E_SUCCESS` without checking anything ("TODO: Add in CPU FUSE from SDM"). It cannot detect a core that is powered off.

## 1. Root-cause candidates, ranked

| # | Candidate | Verdict | Evidence |
|---|---|---|---|
| 1 | **A76 power selection OFF in the bitstream (stale IP generation)** | **Most likely, about 95%** | Table above. The HPS atom parameter `hps_a76_core_selection` goes into the SDM's HPS configuration in the .sof/.jic, not into the bootloader handoff. `output_files/hps_bootloader_handoff.bin` holds only BOOT/PMUX/IOCT/FPGA/DLAY/CLKS/PERI/SDRM sections, with no power section [verified: source]. |
| 2 | `hps/hps_subsys.tcl` still sets `Pwr_a76_core2_on {0}` / `core3 {0}` (lines 285-286) | Latent regression trap | Re-running that script rewrites the .ip back to OFF [verified: source]. The OFF value came into the repo in commit aa10d49. The first HPS commit, 4e20a99, had `true`. |
| 3 | Device variant without A76 | **Ruled out** | Device Overview 762191 (2025.04.22), Part Number Decoder: 4th char `B` = "Quad HPS: 2x Cortex-A55 and 2x Cortex-A76", `E` = "Dual HPS: 2x A55" only. Our part is A5E**B**013BB23BE4SCS [verified: source]. Altera's own DE25-Nano rev B demo (altera-fpga/agilex5-demo-hps2fpga-interfaces, `brd_terasic_de25nano_revb`, same OPN) ships an A76-**boot**-core variant (`Pwr_boot_core_sel {2}`) [verified: source]. Whether that build was ever run on a board: [unverified]. |
| 4 | A76 clocks (core23 source/divider) | Unlikely | Decoded CLKS handoff from `output_files/hps_bootloader_handoff.bin`: main PLL `pllglob=0x16000101` (refdiv 1), `pllm=0x80` (x128 of 25 MHz osc = 3.2 GHz VCO), `pllc0=0x08000004` (/4, enabled) = 800 MHz. `ctl_core23ctr = core2ctr = core3ctr = 0` (source main PLL C0, /1), so the A76 clock is 800 MHz. U-Boot SPL `clk-agilex5.c` writes these directly [verified: source + arithmetic]. MPU clock parameters match the GSRD 065 `baseline-a55` and the Terasic GHRD [verified: source]. |
| 5 | ATF / U-Boot / kernel / DT | Unlikely | ATF agilex5 builds the A76 cpu_ops (`platform.mk` includes `cortex_a76.S`). `plat_my_core_pos` = Aff1 handles MPIDR 0x200/0x300. Reset vectors are written for CPU1/2/3 when boot core = 0. U-Boot SPL never touches pwrmgr or CPU release. The DT has cpu@2/cpu@3 with `enable-method = "psci"` and reg 0x200/0x300 [verified: source]. No A76-specific agilex5 bring-up fix appears in altera-fpga ATF history up to socfpga_v2.14.1 [verified: source, `git log` of the psci/plat files]. |
| 6 | Pwr_cpu_app_select, boot-core selection, L3 size | Unlikely | Identical to the GSRD 065 `baseline-a55` and the Terasic GHRD: `Pwr_boot_core_sel 0`, `Pwr_cpu_app_select 0`, `Pwr_mpu_l3_cache_size 2` [verified: source]. What `Pwr_cpu_app_select` means: [unverified]. |
| 7 | Known errata or release-note limitation | None found | No GSRD, release-note or forum hit describes the A76 failing to come up on Agilex 5 production parts [unverified, i.e. absence of evidence]. |

Side note: `docs/linux_boot.md` says "Terasic's GHRD had them off". The local
Terasic GHRD copies (`~/dev/golden_nano/.../GHRD/hps_subsys/ip/hps_subsys/agilex_hps.ip`,
`~/dev/de25_nano/...`) have both `true` and generated `..._DUAL` [verified: source].
The OFF value came from this repo's own `hps/hps_subsys.tcl`.

## 2. How Altera / Terasic configure the HPS for 4 cores

| Parameter | This repo (.ip now) | This repo (generated HDL used) | Terasic GHRD | GSRD 065 baseline-a55 | GSRD 065 baseline-a76 | GSRD 013 legacy | Altera demo DE25 a55/a76 |
|---|---|---|---|---|---|---|---|
| Pwr_a55_core0_1_on | true | BOTH_ON | true | true | true | true | 1 |
| Pwr_a76_core2_on / core3_on | true / true | **OFF** | true / true | true / true | true / true | true / true | 1 / 1 |
| Pwr_boot_core_sel | 0 | - | 0 | 0 | **2** | 0 | 0 / **2** |
| Pwr_cpu_app_select | 0 | - | 0 | 0 | 0 | 0 | 0 |
| Pwr_mpu_l3_cache_size | 2 | - | 2 | 2 | 2 | 1 | 1 |
| MPU_clk_override | true | - | (n/a) | true | true | false | 0 |
| MPU_core01 src / MHz | 1 / 800 | - | 1 / 800 | 1 / 800 | 1 / 800 | 1 / 1000 | 1 / 1000 |
| MPU_core23 src, core2/3 MHz | 0, 800/800 | - | 0, 800/800 | 0, 800/800 | 0, 800/800 | 0, 1600/1600 | 0, 1600/1600 |

Software: the Altera demo (QPDS26.1.1_REL_GSRD_PR tags) builds stock ATF
`PLAT=agilex5` with only `SOCFPGA_UART_CONFIG=1` changed. It uses stock
`socfpga_agilex5_defconfig` plus an unrelated fragment and a stock kernel DT.
It has **no** SMP/A76 patches [verified: source]. So no firmware change is
needed for 4 cores. Its docs say "core 1 ... is always an A55 core regardless of
the boot core configuration of the quad core cluster", which implies all 4 cores
online under Linux [unverified that it was observed].

## 3. Read-only board checklist (for the main session)

### 3a. Before flashing: no hardware needed
```sh
grep -o 'hps_a76_core_selection("[A-Z_]*")' hps/ip/hps_subsys/agilex_hps/intel_sundancemesa_hps_100/synth/*.v   # must be ..._DUAL
grep -c 'sundancemesa_hps_100_vzqm2di' output_files/de25_nano_uart.syn.rpt   # must be 0 after regen (new hash)
grep -A1 'Pwr_a76_core' hps/ip/hps_subsys/agilex_hps/agilex_hps.html        # must show true
```

### 3b. Linux: safe, read-only
| Command | Expect when fixed | Meaning when broken |
|---|---|---|
| `dmesg \| grep -iE 'psci\|smp\|CPU[0-3]'` | `smp: Brought up 1 node, 4 CPUs`, `CPU2: Booted secondary processor 0x0000000200 [0x414fd0b1]` (A76 MIDR part 0xd0b) | `failed to come online` / `unknown state : 0x0` = core never ran |
| `cat /sys/devices/system/cpu/{possible,present,online}` | `0-3`, `0-3`, `0-3` | online `0-1` |
| `grep -E 'processor\|CPU part' /proc/cpuinfo` | parts 0xd05 x2, 0xd0b x2 | only 0xd05 |
| `cat /sys/firmware/devicetree/base/cpus/cpu@2/compatible` | `arm,cortex-a76` | (DT is fine already) |

### 3c. U-Boot console (`md` = read)
| Command | Register | Expected / meaning | Tag |
|---|---|---|---|
| (boot log) | ATF banner `SOCFPGA: Boot Core = 0`, `CPU ID = 0` | reads `PWRMGR MPU_BOOTCONFIG[11:10]` | [verified: source] |
| `md.l 0x10d10100 4` | CLKMGR CTL_CORE01CTR, CORE23CTR, CORE2CTR, CORE3CTR | `0 0 0 0` per handoff: src[18:16]=0 main, cnt[10:0]=0 /1 | [verified: source] |
| `md.l 0x10d10020 4` | CLKMGR MAINPLL (0x24 = EN) | clock gate enables (bit meanings [unverified]) | |
| `md.l 0x10d11094 1` | RSTMGR CPUSTRELEASE | per-CPU release mask written by ATF (bit n = CPU n) | [verified: source] |
| `md.l 0x10d11098 8` | RSTMGR CPU0..3 RESETBASE LOW/HIGH | entry>>2 written by ATF on CPU_ON | [verified: source] |
| `md.l 0x10d14000 0x17` | PWRMGR (0x0 DSU_FWENCTL, 0x4 DSU_PGENCTL, 0x8 DSU_PGSTAT, 0x18/0x20/0x28/0x30 CPU_PWRCTLR0-3, 0x1c/0x24/0x2c/0x34 CPU_PWRSTAT0-3, 0x50 MPU_PCHCTLR, 0x54 MPU_PCHSTAT, 0x58 MPU_BOOTCONFIG) | CPU_PWRSTATn FSM state = bits[9:2], RUN_PCH = bit0. Compare core2/3 with core0/1: different/zero state on 2/3 = powered off | offsets [verified: source]; meanings of FSM values and **whether NS-EL2 may read pwrmgr** [unverified] - read it last; a secure-only abort just resets U-Boot |

Not needed: anything in `/sys/kernel/debug`. Do not use `devmem` on pwrmgr from
Linux: if the region is secure-only, it gives an SError panic.

## 4. Fix plan

| Step | File / action | Notes |
|---|---|---|
| 1 | Make sure `hps/ip/hps_subsys/agilex_hps.ip` keeps `Pwr_a76_core2_on/_core3_on = true` (it does now) | nothing else in the IP needs changing |
| 2 | `hps/hps_subsys.tcl` lines 285-286: `{0}` -> `{1}` | stops the trap from coming back |
| 3 | Regenerate the IP: `quartus_ipgenerate --generate_ip_file --ip_file=hps/ip/hps_subsys/agilex_hps.ip --synthesis=verilog --clear_ip_generation_dirs de25_nano_uart -c de25_nano_uart` (or delete the git-ignored `hps/ip/hps_subsys/agilex_hps/` dir, then the usual `--run_default_mode_op`) | the generated synth file gets a new hash and `..._DUAL` |
| 4 | Optional, permanent: in `build_de25_nano_uart.tcl` add `set_global_assignment -name PROJECT_IP_REGENERATION_POLICY ALWAYS_REGENERATE_IP` | the value string is checked in Quartus' `get_effective_regeneration_policy` [verified: source]; it costs a few seconds per build |
| 5 | Run the 3a checks, then syn/fit/sta/asm, `linux/make_jic.sh`, program | the same applies to any copy of the project, e.g. the scratch `hps_first/proj` copy has the same stale OFF file [verified: source] |
| 6 | No ATF, U-Boot, kernel or DT change | matches Altera's demo/GSRD |
| 7 | Verify with 3b: 4 CPUs, 2x 0xd0b | also `taskset -c 2 true` and check `/sys/devices/system/cpu/cpu2/online` |
| 8 | Update `docs/linux_boot.md` (table row line 41 and "Known gaps" line 140) | fix the "Terasic GHRD had them off" claim |

If it still fails after a **verified** DUAL bitstream [unverified fallbacks]:
- Read the pwrmgr/rstmgr registers above.
- Build ATF with `LOG_LEVEL=50` to trace `socfpga_pwr_domain_on`.
- Try Altera's `brd_terasic_de25nano_revb` A76-boot-core flow to prove the A76 silicon/rails on this board.
- Consider raising the issue with Altera, since the ATF "CPU FUSE" TODO means fused-off cores are not detected.

## Remaining unknowns
- Whether 4 cores actually come up after the regenerated bitstream: very likely, but not yet seen on hardware.
- The exact pwrmgr FSM state encodings, and whether pwrmgr is readable from non-secure EL2: needs the Agilex 5 HPS TRM register map [unverified].
- What `Pwr_cpu_app_select` does [unverified].
- Why the other session's 2026-10-17 00:05 IP-generation run also reported the NEVER policy: any compile made since the .ip edit is stale until step 3 [verified: report timestamp].

Sources: Agilex 5 Device Overview 762191 rev 2025.04.22 (Part Number Decoder, Fig. 4);
github.com/altera-fpga/agilex5-demo-hps2fpga-interfaces (`brd_terasic_de25nano_revb`);
altera-fpga/arm-trusted-firmware socfpga_v2.14.1; altera-fpga/u-boot-socfpga
socfpga_v2026.04; linux-socfpga 6.18; Quartus Pro 26.1.1 ipg Tcl.
