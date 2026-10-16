# Research: booting the DE25-Nano with `HPS_INITIALIZATION "HPS FIRST"`

Status 2026-10-16: **research only, nothing in the build changed.** The board
was not touched. Quartus experiments ran in a scratch copy of the project
(`HPS FIRST` set, `quartus_asm` re-run, `quartus_pfg` outputs compared).

Versions this refers to (the main session is moving the stack to these):

| piece | version read |
|---|---|
| Quartus | Pro 26.1.1 build 130 (`~/altera_pro/26.1.1`) |
| U-Boot | altera-fpga `socfpga_v2026.04` (local checkout `linux/build_output/u-boot-altera`, HEAD `e09d6fcc`) |
| ATF | altera-fpga `socfpga_v2.14.1` (HEAD `2ea5afd`, shallow clone) |
| Linux | altera-fpga `socfpga-6.18.20-lts` (HEAD `7726132`, sparse clone: `drivers/fpga`, `drivers/firmware`, `arch/arm64/boot/dts/intel`, `arch/arm64/configs`) |
| GSRD | `~/dev/agilex5e-ed-gsrd` (25.3.1) and `altera-fpga/meta-altera-fpga` @ `34f9caa` (the commit its `kas.yml` pins) |

Tags: **[V: source]** = verified (file/line, tool output, or document);
**[U]** = unverified (inference, or secondary source only).

---

## 0. Summary

**Recommendation: it can be done, but stay on "AFTER INIT_DONE" for the
default image unless loading a whole new FPGA image while Linux runs (no
reboot) is worth it. If it is, use HPS FIRST + U-Boot proper `fpga load`
of a `.core.rbf` from the SD card (falling back to QSPI), run from
`CONFIG_PREBOOT`, and reload from Linux with an fpga-region overlay.** Do not
use the SPL-FIT route.

The facts that decide it:

1. **The earlier "HPS FIRST" hang was not a race. Nothing ever configured
   the FPGA core.** Under HPS FIRST the `.jic` holds only the phase-1 image
   (SDM firmware, HPS I/O, HPS EMIF I/O, FSBL). The core and the FPGA I/O
   are phase 2, and the HPS has to ask the SDM for that phase. This repo
   never did. That explains why `FPGA_COMPLETE` "genuinely never set"
   (`linux/patches/README.md`, in git history up to `b2351c3`). The relaxed `is_fpga_config_ready()` patch
   then let `bridge enable` open LWH2F onto an unconfigured fabric, and the
   CPU hung. [V: Altera HPS Booting UG 813762, "HPS Boot First" / "Phase 1
   / Phase 2"; V: scratch trial below, the HPS-first P1 is 0x63000 bytes
   against 0xB8000 for AFTER INIT_DONE. The old hang was never rerun with a
   phase-2 load, so whether that load cures it is U.]
2. **The Linux console is HPS UART1 routed through the fabric**
   (`FPGA_UART_TX/RX`, `docs/de25_nano_hps.md`). Under HPS FIRST the console
   is dead until phase 2 is loaded: no SPL output, and no U-Boot output
   until `fpga load` runs. `sd_recover.py` depends on the U-Boot console, so
   phase 2 has to run before the autoboot prompt, from SD with a QSPI copy
   as fallback. [V: repo docs; the effect on output is U but follows
   directly from fabric I/O being tri-stated until phase 2 (UG 813762)]
3. **The upstream stack loads phase 2 from U-Boot proper and from Linux.
   U-Boot SPL cannot.** U-Boot 2026.04 has `CMD_FPGA` and
   `FPGA_INTEL_SDM_MAILBOX` enabled already. ATF 2.14.1 turns off all
   bridges at the start of a full reconfiguration and turns them on again
   once the SDM reports done. Kernel 6.18.20 has the `intel,agilex5-soc-fpga-mgr`
   driver and a `/fpga-region` node in `socfpga_agilex5.dtsi`. The SPL has
   no FPGA device registered (`socfpga_fpga_add()` is called only from
   `arch_early_init_r`, U-Boot proper). [V: code, see §2]
4. **Full core reconfiguration from Linux while Linux keeps running works
   only in HPS-first mode** (secondary sources; see §5). It needs the same
   HPS I/O and EMIF settings and the same Quartus version as phase 1. A
   new `.core.rbf` is then just a file on the SD card, so the RSU plan
   (QSPI slots) is only needed when the HPS side or the SPL changes.

---

## 1. What "HPS FIRST" means on Agilex 5

| | AFTER INIT_DONE (now) | HPS FIRST |
|---|---|---|
| SDM at power-on | configures the whole device (I/O + core + HPS I/O + EMIF), enters user mode, then releases the HPS | phase 1 only: SDM firmware, HPS I/O, HPS EMIF I/O, loads FSBL (SPL) into OCRAM, releases the HPS [V: UG 813762 "HPS Boot First"] |
| FPGA I/O (non-HPS) | configured before HPS runs | **tri-stated** until phase 2 [V: UG 813762] |
| FPGA core | in user mode before HPS runs; `SYSMGR FPGA_CONFIG` (0x10D120DC) = 0x3 | unconfigured until HPS software requests phase 2 [V: UG 813762]; this repo measured 0x2 (EARLY_USERMODE only) [V: docs/de25_nano_lwh2f_bringup.md] |
| Phase 2 | – | HPS sends the `.core.rbf` to the SDM (mailbox, through ATF SiP SMC calls). It configures the core and the FPGA I/O, but not the HPS EMIF I/O [V: UG 813762] |
| Phase 2 constraints | – | same HPS I/O + HPS EMIF settings and the same Quartus version (SDM firmware) as phase 1, or phase 2 fails [V: UG 813762 24.1/24.3]. The controlpaths blog says the "IO hash" must also match. That is stricter than the UG and **U** |

What this design needs before the first access to the fabric:

| item | under HPS FIRST |
|---|---|
| LWH2F / H2F bridges | must stay in reset until phase 2 is done. U-Boot `bridge enable` refuses unless `FPGA_CONFIG & 0x3 == 0x3` ("FPGA not ready. Bridge reset aborted!") [V: `arch/arm/mach-socfpga/misc_soc64.c` `is_fpga_config_ready()`/`do_bridge_reset()`]. **Never re-apply `linux/patches/u-boot-socfpga.patch`**: it relaxes that check, and that is what let the old hang happen. |
| `h2f_user0` clock (fabric `core_clock`) | an HPS clock-manager output that the SPL sets up from the handoff data. It runs whether or not the core is configured, and the fabric only exists after phase 2, so nothing is lost [U: from the clock-manager design; check on hardware with `H2F_CLK_TEST` / the heartbeat] |
| `h2f_reset` | the fabric reset synchronizer powers up asserted (`h2f_reset_sync := (others => '1')`) and releases after 10 `core_clock` edges, which fits a fabric that appears late [V: `de25_nano_uart_top.vhd`]. Whether ATF/U-Boot touch `h2f_reset` around `fpga load` is **U**: check that register 0 (id) reads correctly after phase 2 |
| HPS UART1 console | through fabric pins, so silent until phase 2 (fact 2 above) |
| Ethernet, SD card, QSPI | HPS dedicated I/O (`hps/hps_pins.tcl`), so configured in phase 1 and usable by the SPL [V: pin file; UG 813762 "HPS IO" in phase 1]. The old MDIO failure under HPS FIRST + QSPI HPS was also seen while phase 2 had never run. Whether it was caused by that is **U** |
| QSPI_OWNERSHIP | keep `HPS`. Every Agilex 5 GSRD pairs `QSPI_OWNERSHIP HPS` with `HPS FIRST` [V: `~/dev/agilex5e-ed-gsrd/*/legacy_baseline.qsf`, `baseline_a55.qsf`] |

## 2. Ways to load the core (phase 2)

| option | upstream support (versions above) | how the GSRD does it | verdict for this repo |
|---|---|---|---|
| **(a) SPL from the FIT** (`fpga` node / `CONFIG_SPL_FPGA`) | generic code exists (`common/spl/spl_fit.c` `spl_fit_load_fpga()` → `fpga_load()`), but on SoC64 the FPGA device is registered only in `arch_early_init_r()` (U-Boot proper), so SPL `fpga_load` has no device. No Agilex 5 `fit_spl_fpga.its` exists; only Arria 10 has one. `CONFIG_SPL_FPGA` is not set [V: `misc_soc64.c:135`, `board/altera/arria10-socdk/fit_spl_fpga.its`, `.config:623`] | not used | **no**: needs U-Boot patches, adds OCRAM pressure, and `socfpga_vab` is about authentication, not loading |
| **(b) U-Boot proper `fpga load`** | `CONFIG_CMD_FPGA=y`, `CONFIG_FPGA_INTEL_SDM_MAILBOX=y` already [V: `.config:801,1255`]. `intel_sdm_mb_load()` → ATF SiP `FPGA_CONFIG_START/WRITE/COMPLETED_WRITE/ISDONE` [V: `drivers/fpga/intel_sdm_mb.c`]. ATF 2.14.1 turns off all bridges on a full config start and runs `socfpga_bridges_enable(~0)` when ISDONE succeeds [V: `plat/intel/soc/common/socfpga_sip_svc.c` `intel_fpga_config_start()` / `intel_mailbox_fpga_config_isdone()`] | GSRD 26.1 SD boot: `load mmc 0:1 ${loadaddr} ghrd.core.rbf; fpga load 0 ${loadaddr} ${filesize}; bridge enable;` [V: altera-fpga.github.io rel-26.1 "HPS Linux Boot Tutorial", Agilex 5 premium 065b]. The GSRD baseline instead puts `top.core.rbf` as `fpga-0` in `kernel.itb` and runs `bootm ${loadaddr}#board-0`, which calls `boot_get_fpga()` [V: meta-altera-fpga `fit_agilex5_kernel.its`, `bootscr/uboot.txt`; U-Boot `boot/image-board.c:630`] | **yes**: a plain `fpga load` from `CONFIG_PREBOOT`, keeping extlinux. The FIT/`bootm` variant does not fit the extlinux flow |
| **(c) Linux fpga-manager + overlay** | `stratix10-soc.c` matches `intel,agilex5-soc-fpga-mgr`. `socfpga_agilex5.dtsi` has `fpga_mgr` and a root `fpga-region { fpga-mgr = <&fpga_mgr>; }`. There are **no fpga-bridge nodes** for Agilex 5, but ATF handles the bridges (row b). The svc driver uses the same SMC IDs (`COMMAND_RECONFIG` → `INTEL_SIP_SMC_FPGA_CONFIG_START`). defconfig: `FPGA_MGR_STRATIX10_SOC=m`, `FPGA_REGION=m`, `OF_FPGA_REGION=m`, `FPGA_BRIDGE=m`, `OF_OVERLAY=y`, `OF_CONFIGFS=y` [V: 6.18.20 sources] | overlay with `firmware-name = "<x>.core.rbf"`, `config-complete-timeout-us = <30000000>`, applied through configfs [V: rel-26.1 boot tutorial; controlpaths Agilex 3 blog] | **yes, for reloads at runtime**. The rootfs has no modules, so build those `=y` |

Notes:
- `fpga load` needs the image in DDR that ATF accepts (`is_address_in_ddr_range()`). `loadaddr` = 0x82000000 is inside the 1 GB. Whether ATF 2.14.1 still assumes 2 GB (the `config_ddr_size` patch) is **U**, since the main session is redoing that.
- GSRD warning: if the fabric is already configured and the bridges are on, run `bridge disable` before `fpga load` / `bootm` [V: rel-26.1 tutorial]. ATF does this itself as of v2.8 [V: same text + `bridge_disable` in ATF].

## 3. Quartus side (26.1.1)

Tried in the scratch copy (`HPS FIRST` in the `.qsf`; `quartus_asm` alone was enough, no re-fit):

| command | result |
|---|---|
| `quartus_pfg -c x.sof x.rbf -o hps=ON` on today's AFTER INIT_DONE `.sof` | `Error (19921): ... does not support HPS bitstream - HPS configuration order is not HPS first` [V] |
| same, without `hps_path` | `Error (19192): ... HPS is present but bootloader information is missing` [V] |
| `quartus_pfg -c de25_nano_uart.sof hf.rbf -o hps=ON -o hps_path=u-boot-spl-dtb.hex` (HPS FIRST sof) | `hf.hps.rbf` (839 680 B, phase 1 for JTAG/other) + `hf.core.rbf` (1 036 288 B) [V] |
| `quartus_pfg -c de25_nano_uart.sof core.rbf -o hps_core_only=ON` | only the `.core.rbf`, identical size [V]. `-l` describes it as "Generates only the raw binary file (*.core.rbf)" [V] |
| `quartus_pfg -c sof x.jic x.map -o hps_path=SPL -o device=MT25QU128 -o flash_loader=A5EB013BB23BCS -o mode=ASX4` (with or without `-o hps=1`) | P1 = `0x200000–0x262FFF` (HPS FIRST) against `0x200000–0x2B7FFF` (today's AFTER INIT_DONE). **The jic already leaves the core out.** With `-o hps=1` the output is named `x.hps.jic` and `x.core.rbf` is written as well [V] |

So `make_jic.sh`'s existing `.pfg` (the `<bitstream>` with `hps_path`) gives
the phase-1 image unchanged once the `.sof` is HPS FIRST [V: same mechanism;
the `.pfg` route itself is U]. The `.core.rbf` gets stored like this:

| where | what | why |
|---|---|---|
| SD FAT p1 | `de25_nano.core.rbf` | normal boot, and the file Linux and the web GUI replace |
| QSPI raw partition, e.g. `0x00C00000` (1 MB now, leave 2–4 MB) | same `.core.rbf`, `<raw_file bitswap="1" type="RBF">` like `u-boot.bin` | blank/broken SD card: `sd_recover.py` needs the console, and the console needs the core. `u-boot.itb` (953 KB) ends at about `0xAE9000`, so `0xC00000` is clear [V: sizes] |
| Linux rootfs `/lib/firmware/` | `*.core.rbf` | for overlay reloads |

The `.core.rbf` is only valid with the phase-1 image (HPS I/O + EMIF +
Quartus version) that is in QSPI. Stamp a build id into it (the PR plan's
register 19) and check it before loading.

## 4. Keeping LWH2F safe under HPS FIRST

Order that guarantees it:

1. SPL: DDR, then loads `u-boot.itb`. Bridges stay in reset (U-Boot never
   releases them on SoC64 by itself) [V: `docs/linux_boot.md`; code].
2. U-Boot `preboot`: `load` the core (SD, else `sf read` from QSPI), then
   `fpga load 0 ${loadaddr} ${filesize}`. ATF turns the bridges on only if
   the SDM reports success [V: ATF code].
3. `bridge enable` (as now). It re-checks `FPGA_CONFIG == 0x3`, so it fails
   safe, printing "FPGA not ready", when step 2 failed [V: U-Boot code].
   Make the `&&` chain skip it on failure anyway.
4. Linux: before the web GUI maps LWH2F, read `SYSMGR FPGA_CONFIG`
   (0x10D120DC, bits 0+1) [V: `system_manager_soc64_agilex5.h` 0xDC,
   base 0x10D12000] and/or `/sys/class/fpga_manager/fpga0/state`. Refuse to
   touch `0x2000_0000` unless the core is up. Whether userspace `/dev/mem`
   reads of SYSMGR are allowed is **U** (non-secure access to sysmgr).
5. Runtime reload: the web GUI stops all LWH2F traffic (same lock as the
   register access), then applies the overlay. ATF turns the bridges off for
   the load and on again afterwards; the GUI checks the id register before
   it resumes. The Agilex 3 blog shows that touching the fabric during a
   reload stalls AXI until the watchdog resets the board [V: secondary].

## 5. Benefits and costs for this project

| | |
|---|---|
| **New full FPGA image without reboot** | the main gain. HPS-first allows phase 2 again from Linux while the OS keeps running. Agilex 7 config UG: HPS First "supports FPGA reconfiguration while the HPS is running" [V: secondary copy of Altera UG]. The controlpaths blog quotes the Altera boot UG as saying fabric configuration from HPS software is supported *only* in HPS-first [U: not found in the primary doc]. It showed one Linux reload on Agilex 3 with the 6.12-era stack [V: secondary]. The GSRD 24.1 listed "Reconfiguring FPGA fabric from Linux fail" as a known issue [V: secondary search result]. Status on 6.18.20 is **U** |
| **Relation to RSU** | HPS-first covers "new fabric, same HPS I/O/EMIF/Quartus version" with a file copy: no QSPI writes, no power cycle, no SDM fallback. RSU is still needed when the SPL, the HPS I/O or EMIF, or the Quartus version changes, and for automatic fallback to a known-good image. Under RSU + HPS-first each slot holds only phase 1, and its matching `.core.rbf` has to travel with it (e.g. in its SSBL partition) [U: RSU + HPS-first combination untested] |
| **Relation to partial reconfiguration** | separate mechanisms. PR keeps the static part (UART console, LWH2F, fan) alive during a swap; a full core reload does not. HPS-first does not block PR [U]. For the blinker plan PR is still the gentler option |
| **During a full reload** | console UART, LWH2F register file, fan I²C driver and LEDs all disappear for about 1–2 s. The fan controller (AMC6821) keeps its last setting and thermal mode [V: docs/de25_nano_fan.md, Config3 left at default]. CRAM SEU EDAC log spam was seen on Agilex 3 [V: secondary] |
| **Boot time** | phase 1 is about 45 % smaller (P1 0x63000 vs 0xB8000), so the SPL starts sooner, but U-Boot then loads about 1 MB and configures the core. Time to Linux is probably about the same [U: measure] |
| **Risks** | (1) no SPL/early U-Boot console: SPL failures are invisible; keep an AFTER INIT_DONE `.jic` for debugging. (2) phase-1/phase-2 mismatch (different HPS I/O, EMIF or Quartus version), where the SDM can stall in `write` with no error [V: secondary]. (3) Ethernet MDIO regression seen once with HPS FIRST [U cause]. (4) `h2f_reset` state after `fpga load` [U]. (5) JTAG `program.sh` (`.sof` over JTAG) under HPS FIRST: whether the programmer configures both phases is **U**, test it |

## 6. Step-by-step plan (each step testable)

| # | change | files | verify on hardware |
|---|---|---|---|
| H0 | build variant switch `HPS_FIRST=1` (default off): `HPS_INITIALIZATION "HPS FIRST"`, keep `QSPI_OWNERSHIP HPS` | `build_de25_nano_uart.tcl` | – (compile only) |
| H1 | `.core.rbf` generation (`quartus_pfg -c sof core.rbf -o hps_core_only=ON`) | new step in `make_jic.sh` (or the build docs) | – |
| H2 | **U-Boot console test**: program the HPS-first `.jic` only, SD unchanged. Expect silence, then interrupt over JTAG/none. Run `fatload mmc 0:1 ${loadaddr} de25_nano.core.rbf; fpga load 0 ${loadaddr} ${filesize}` from a `CONFIG_PREBOOT` build | `build_de25_nano_linux.sh` (`CONFIG_USE_PREBOOT=y`, `CONFIG_PREBOOT="..."`) | console appears right after "FPGA reconfiguration OK!"; `md.l 0x10d120dc 1` = 3; `bridge enable` is silent; `md.l 0x20000000` reads the id register |
| H3 | QSPI fallback: `.core.rbf` as a raw partition at `0xC00000`; preboot `if load mmc ...; then; else sf probe && sf read ${loadaddr} 0xC00000 <size>; fi` (store the size, or read a fixed 2 MB, since the SDM ignores trailing data [U]) | `make_jic.sh` (.pfg `CORE` partition), U-Boot preboot | blank SD card → console + U-Boot prompt; `sd_recover.py` works unchanged |
| H4 | Linux boot as now (`bridge enable; run distro_bootcmd`) | – | web GUI works, `gui_test.py` passes; ethernet links (watch for "MDIO device at address 1 is missing"); 10 power cycles |
| H5 | SD image carries the core | `linux/tools/make_sdcard_image.sh` (mcopy `de25_nano.core.rbf`) | – |
| H6 | kernel: `CONFIG_FPGA_MGR_STRATIX10_SOC=y`, `CONFIG_FPGA_REGION=y`, `CONFIG_OF_FPGA_REGION=y`, `CONFIG_FPGA_BRIDGE=y` (`OF_OVERLAY`/`OF_CONFIGFS` already y) | `build_de25_nano_linux.sh` | `/sys/class/fpga_manager/fpga0/state` exists |
| H7 | Linux reload by hand: stop the GUI, apply an overlay on `/fpga-region` with `firmware-name = "de25_nano.core.rbf"` (same image) | rootfs `/lib/firmware`, a small `.dtbo` | console survives the reload; id register reads back; GUI restarts. Then a *different* build (same HPS side), e.g. another default blinker |
| H8 | web GUI "FPGA image" upload: build-id check, pause register traffic, configfs overlay, verify, resume | `linux/webapp/fpga_web.py`, `deploy_*` tool | 100× reload loop; a deliberately mismatched `.core.rbf` returns an error and does not hang (guard with a timeout and a separate process) |
| H9 | docs: boot chain, settings table, "when it doesn't boot" (silent console = core not loaded) | `docs/linux_boot.md`, the `make_jic.sh` header, `docs/de25_nano_lwh2f_bringup.md` (reinterpret the root cause) | – |

Fallback at every step: the current AFTER INIT_DONE `.jic`. Keep both
variants buildable until H8 has soaked.

## 7. Could not determine

- Whether the old ethernet MDIO failure under HPS FIRST is cured once the
  core is loaded.
- `h2f_reset` behaviour around `fpga load` / a Linux reload.
- How reliable repeated Linux full reloads are on 6.18.20 + ATF 2.14.1
  (the GSRD 24.1 known issue; only one reload on Agilex 3 is documented).
- Whether a JTAG `.sof` load under HPS FIRST configures the core too.
- Whether the "IO hash must match" rule (blog) is stricter than the UG's
  "HPS I/O + EMIF must match", i.e. whether FPGA pin assignments may change
  between `.core.rbf` builds.
- The Altera documentation pages redirect (intel.com → 404 redirector), so
  the UG wording above comes from search excerpts of 813762 (24.1/24.3/25.1)
  and the rel-26.1 tutorial, not from a full read.

Sources: Altera HPS Booting UG 813762 ("HPS Boot First", "Phase 1/Phase 2",
intel.com/content/www/us/en/docs/programmable/813762/), Altera rel-26.1
"HPS Linux Boot Tutorial" (altera-fpga.github.io/rel-26.1/embedded-designs/agilex-5/e-series/premium-065b/boot-examples/ug-linux-boot-agx5e-premium-065b/),
controlpaths.com 2026-09-13 "Reconfiguring the Agilex 3 FPGA fabric from
Linux without rebooting", Altera community thread "Agilex 5 - configure FPGA
from running linux via dt-overlay", the code paths cited inline, and
`quartus_pfg` 26.1.1 output.
