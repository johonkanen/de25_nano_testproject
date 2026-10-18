# HPS-first boot: the FPGA core loaded by software, reloadable from Linux

Default since 2026-10-17. The SDM boots the HPS first and configures only
the HPS side; U-Boot loads the FPGA core ("phase 2") before anything touches
the fabric, and a running Linux can load a new core in ~2 s without
rebooting. Verified on the board: HPS-first boot with all four CPU cores,
ethernet, LWH2F and the web GUI working, and `fpga-reload` run repeatedly
while Linux kept running.

Background and sources: docs/hps_first_boot_research.md. Why the first
HPS-first attempt hung: the core was never loaded at all
(docs/de25_nano_lwh2f_bringup.md describes the symptom).

## How it works

```
power-on
  SDM       phase 1 from QSPI: SDM firmware, HPS I/O, DDR I/O, the SPL
            (the FPGA fabric stays unconfigured)
  SPL       DDR; the running image's U-Boot: u-boot_<slot>.itb from the SD
            card, or QSPI SSBL.<slot> (RSU multiboot, docs/linux_boot.md)
  ATF       BL31
  U-Boot    preboot: FPGA_CONFIG (0x10d120dc) != 3 -> load the core
            (de25_nano.core.rbf from SD FAT p1, else the QSPI copy at
            0xC00000) with `fpga load` -> "FPGA reconfiguration OK!"
            -- the console appears only now: HPS UART1 runs through the fabric
            bootcmd: bridge enable; run distro_bootcmd
  Linux     extlinux.conf; /lib/firmware/de25_nano.core.rbf for reloads
```

The preboot loads the core only when the fabric isn't configured, so the
same U-Boot works with FPGA-first images and after a JTAG `.sof` load
(both leave FPGA_CONFIG at 3). After a `reboot` from Linux the fabric is
still configured too (`REBOOT_HPS` restarts only the HPS): the preboot
skips, the running core stays, and the console works through the whole
reboot - only a power-on boot is silent until the core is loaded.

## Settings

| where | setting | value |
|---|---|---|
| `build_de25_nano_uart.tcl` | `HPS_INITIALIZATION` | `"HPS FIRST"` (default); `FPGA_FIRST=1` in the environment gives `"AFTER INIT_DONE"` |
| `build_de25_nano_uart.tcl` | `QSPI_OWNERSHIP` | `HPS` (the SPL and U-Boot read QSPI) |
| U-Boot (`linux/build_de25_nano_linux.sh`) | `CONFIG_USE_PREBOOT`, `CONFIG_PREBOOT` | the core loader above |
| U-Boot | `CONFIG_BOOTCOMMAND` | `bridge enable; run distro_bootcmd` |
| kernel | `CONFIG_FPGA_MGR_STRATIX10_SOC`, `CONFIG_FPGA_BRIDGE`, `CONFIG_FPGA_REGION`, `CONFIG_OF_FPGA_REGION` | `=y` (`OF_OVERLAY`, `OF_CONFIGFS` already `=y`) |

## Build

```bash
# FPGA - HPS-first is the default
quartus_sh -t build_de25_nano_uart.tcl
quartus_ipgenerate de25_nano_uart -c de25_nano_uart --run_default_mode_op
quartus_syn de25_nano_uart && quartus_fit de25_nano_uart && quartus_sta de25_nano_uart && quartus_asm de25_nano_uart

# ATF, U-Boot (with the preboot loader), kernel (with the FPGA manager)
./linux/build_de25_nano_linux.sh

# QSPI image + core
./linux/make_jic.sh
#   >> HPS-first .sof: core in linux/build_output/de25_nano.core.rbf (1036288 bytes)
#   >> QSPI core copy at 0x00C00000 (header + 1036288 bytes)

# SD card image: the core on FAT p1 and in /lib/firmware, plus fpga-reload
./linux/tools/make_sdcard_image.sh
```

`make_jic.sh` recognises an HPS-first `.sof` by asking `quartus_pfg` for the
core alone (`-o hps_core_only=ON`, refused for AFTER INIT_DONE images).

| QSPI (16 MB) | |
|---|---|
| `0x000000` | boot info + RSU decision firmware (to `0x20FFFF`) |
| `0x220000` | factory image: phase 1 (HPS I/O, DDR I/O) + SPL, 1 MB slot (~0.8 MB used) |
| `0x320000` | SPT0, SPT1, CPB0, CPB1 (32 KB each): the RSU slot and priority tables |
| `0x400000` | P1: application image, 1 MB slot - the SDM boots it first; same build as the factory image until an update writes it |
| `0x500000`, `0x600000` | `SSBL.FACTORY_IM`, `SSBL.P1`: each image's `u-boot.itb` |
| `0xA00000` | `u-boot.itb` (SPLs without RSU multiboot) |
| `0xC00000` | the core: a 4 KB text header `core_size=0x...` (U-Boot `env import`s it), the core from `0xC01000` |

**The core belongs to its phase 1.** A `.core.rbf` only loads on top of the
phase 1 image (HPS I/O, DDR, Quartus version) from the same build - so the
`.jic`, the card's `de25_nano.core.rbf` and `/lib/firmware/de25_nano.core.rbf`
must come from one build. A mismatch makes the SDM refuse the core, or the
load stalls.

**After editing any `.ip`** regenerate it explicitly - the default IP
regeneration policy keeps old generated HDL (that kept the A76 cores off):

```bash
quartus_ipgenerate --generate_ip_file --ip_file=hps/ip/hps_subsys/agilex_hps.ip \
    --synthesis=verilog --clear_ip_generation_dirs de25_nano_uart -c de25_nano_uart
```

## Install

On a board that already boots (FPGA-first or HPS-first):

1. **Card first**: `python3 linux/tools/sd_recover.py` writes the new card
   image (U-Boot with the preboot loader + the core). On an FPGA-first board
   this boot still works: the preboot sees a configured fabric and skips.
2. **Then QSPI**: `quartus_pgm -c "DE25-Nano [1-3-iface0]" -m jtag -o "pvi;linux/build_output/de25_nano.jic"`.
3. **Restart** - a JTAG load of the matching `.sof` works as well as a power cycle:
   `quartus_pgm -c "DE25-Nano [1-3-iface0]" -m jtag -o "p;output_files/de25_nano_uart_hps_auto.sof@1"`

In the other order, an HPS-first `.jic` with an old card (a U-Boot without
the preboot loader) never loads the core: no console, no fabric. Recover by
writing the card from a JTAG-loaded or FPGA-first boot.

## Check it

| where | what to see |
|---|---|
| console | ` FPGA reconfiguration OK!` - the first line ever printed in HPS-first mode |
| Linux | `smp: Brought up 1 node, 4 CPUs` (CPU2/3 are Cortex-A76, part `0xd0b`) |
| Linux | `fpga_manager fpga0: Stratix10 SOC FPGA Manager registered`, `of-fpga-region fpga-region: FPGA Region probed` |
| web GUI | board id OK, blinkers, sensors (`linux/tools/gui_test.py`) |

## A new core over the network

```bash
./write_build_id.sh && quartus_syn ... quartus_asm   # (Build above)
./linux/make_jic.sh                                  # core + manifest in linux/build_output
python3 linux/tools/deploy_fpga.py                   # to 192.168.1.222; Linux keeps running
```

`make_jic.sh` writes `de25_nano.core.json` beside the core:

| field | what |
|---|---|
| `build_id` | the Unix time `write_build_id.sh` stamped; the design shows it on register 19 |
| `core_size`, `core_sha256` | the core |
| `periphery_sha256` | what the first stage in QSPI fixes: the fitter's pin table (`.pin`: every pin's location, direction, I/O standard, the HPS's too; it names the Quartus version and the device) and the HPS and EMIF `.ip` files |
| `git`, `built` | for people |

`deploy_fpga.py` uploads core + manifest (`POST /api/fpga`, X-Token); the
web GUI's "FPGA core" card does the same with a bundle from
`deploy_fpga.py --pack-only`. On the board `fpga_access.py` (the one
process that touches LWH2F):

1. refuses a bundle whose core doesn't match its manifest (size, SHA-256:
   truncated, corrupt) or whose periphery hash differs from the installed
   core's (`/lib/firmware/de25_nano.core.json`) - such a core needs a new
   `.jic`. A board whose core has no manifest yet needs `--force` once;
2. keeps the running core as `de25_nano.core.rbf.prev` (and its manifest);
3. loads the new one (below), checks the board id and that register 19
   shows the manifest's build id;
4. on any failure puts the previous core back and loads it;
5. on success writes the core to the card's FAT partition too (mounted
   just for that: the board runs with `/boot` unmounted), so the next
   power-on loads it.

An install that never finishes - the load hangs the board, or the power
goes - leaves `de25_nano.core.pending` behind; `fpga_access.py` finds it at
its next start and puts the `.prev` core back as the installed one. The
card's copy is only written after a good load, so the board boots the last
good core meanwhile (tested on the board 2026-10-17).

**A damaged core can hang the SDM.** A core with 64 bytes flipped in the
middle (and a manifest made to match it) did not fail the load: the load
never returned, and the SDM stopped answering JTAG too - only a power cycle
brought the board back. Rollback cannot help there, so the manifest's
SHA-256 (checked before anything is touched) is the guard against a core
damaged in transit or on disk. Loads are not time-limited:
`fpga_access.py` keeps register traffic paused until the load returns,
since an LWH2F access to a fabric half-way through configuration hangs
the CPU.

Why not a hash of the phase-1 bitstream: two builds of the same periphery
differ in it (182 bytes: per-build hashes, two copies), and the SDM loads
either build's core on the other's phase 1 - tested 2026-10-17, build
`0x6ad30b34` loaded on the phase 1 of the build before.

## Reloading the core from Linux

```sh
fpga-reload                      # reload /lib/firmware/de25_nano.core.rbf
fpga-reload /tmp/new.core.rbf    # install that core (no manifest, no rollback), then load it
```

On the board (2026-10-17): `fpga-reload: overlay applied, FPGA manager
operating, 2.14 s` / `fpga-reload: board id 0xde25`, twice in a row, Linux
and the web GUI kept running.

What a load does (`fpga_access.py` op `reload`; `fpga-reload` asks it when
the web GUI runs, and does the same itself otherwise -
`linux/tools/fpga_reload/fpga-reload`, installed as `/usr/sbin/fpga-reload`
by `make_sdcard_image.sh`):

1. pauses the register traffic (`fpga_access.py`; without it, `fpga-reload`
   SIGSTOPs every process under `/opt/de25web`) - an LWH2F access while
   the fabric reconfigures can hang the CPU;
2. applies the overlay `/lib/firmware/de25_nano_core_reload.dtbo`
   (`linux/tools/fpga_reload/core_reload.dts`: `/fpga-region`,
   `firmware-name = "de25_nano.core.rbf"`) through configfs - a fresh
   overlay each time, re-applying is what triggers the load. The kernel's
   FPGA manager loads the core through the SDM; ATF keeps the bridges
   closed during the load;
3. checks the overlay (`applied`), the FPGA manager (`operating`) and the
   board id over LWH2F (register 1 = `0xDE25`), and the build id (register
   19) against the manifest;
4. `fpga_access.py` writes back the registers the load reset (LED
   register, fan duty, blinker mode, loopback) and resumes. A plain
   `fpga-reload` without the GUI leaves the fabric in its reset state
   (blinker mode 0, fan duty 30, LED register 0).

The console drops out for the ~2 s of the load.

A new core from a different build only works with the same periphery
(pins, HPS/DDR configuration, Quartus version) - FPGA-side logic and
register changes are fine; anything in the HPS IP or the pinout is not
(that needs a new `.jic`).

## Fallback: FPGA-first

```bash
FPGA_FIRST=1 quartus_sh -t build_de25_nano_uart.tcl   # then build and make_jic.sh as usual
```

The SDM configures the whole FPGA before the HPS starts; the console works
from the first SPL line (useful for debugging the early boot), the preboot
skips, `fpga-reload` is not available.

## When it doesn't boot

| symptom | cause |
|---|---|
| console silent after power-on, network up later or not | the core wasn't loaded: the card's U-Boot has no preboot loader, or no `de25_nano.core.rbf` and no QSPI copy - write the card (Install, step 1) |
| silent, and never any network | phase 1 / core from different builds - rebuild and reprogram both |
| `fpga-reload: overlay ...` not `applied`, or FPGA manager not `operating` | core from another phase 1, or the file isn't in `/lib/firmware` |
| CPU2/3 `failed to come online` | the bitstream has the A76 cores off (stale IP generation - regenerate `agilex_hps.ip`, see Build) |

## Known issues

| what | state |
|---|---|
| `reboot` after a JTAG `.sof` load hangs (silent after `reboot: Restarting system`) | the SPL came over JTAG, so the SDM can't restart the HPS; after a power-on boot `reboot` works. Restart a JTAG-started board with another JTAG load or a power cycle (docs/linux_boot.md) |
| ethernet after a warm reboot | about 1 in 5 warm reboots (none seen after power-on) eth0 has link but passes no traffic - either the RX DMA stops (SMMU `F_TRANSLATION` faults on the EMAC rings at the first open, fatal bus error, frames overflow the MAC FIFO) or transmitted frames are lost after the MAC. Not a running DMA across the reboot (stopping eth0 first did not help), not the PHY delays (`rgmii-id` kills the link: the board carries the delays). `eth0` down/up clears both; `/usr/sbin/eth-watchdog` (linux/board/eth-watchdog.sh) does that when the gateway stops answering. Root cause open. The MAC is random on every boot (U-Boot `NET_RANDOM_ETHADDR`) |
| the console during early boot | silent until the core is loaded - use an FPGA-first build to debug SPL/U-Boot |
| web GUI during a core load | register traffic paused for ~2 s; `fpga_access.py` writes the LED, fan and blinker registers back after |
