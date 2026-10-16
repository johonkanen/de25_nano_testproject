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
  SPL       DDR; u-boot.itb from the SD card, or QSPI 0xA00000
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
(both leave FPGA_CONFIG at 3).

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
| `0x000000` | boot info |
| `0x200000` | phase 1: HPS I/O, DDR I/O, SPL (~0.4 MB) |
| `0xA00000` | `u-boot.itb` |
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

## Reloading the core from Linux

```sh
fpga-reload                      # reload /lib/firmware/de25_nano.core.rbf
fpga-reload /tmp/new.core.rbf    # install that core, then load it
```

On the board (2026-10-17): `fpga-reload: overlay applied, FPGA manager
operating, 2.14 s` / `fpga-reload: board id 0xde25`, twice in a row, Linux
and the web GUI kept running.

What it does (`linux/tools/fpga_reload/fpga-reload`, installed as
`/usr/sbin/fpga-reload` by `make_sdcard_image.sh`):

1. pauses every process under `/opt/de25web` (SIGSTOP) - an LWH2F access
   while the fabric reconfigures can hang the CPU;
2. applies the overlay `/lib/firmware/de25_nano_core_reload.dtbo`
   (`linux/tools/fpga_reload/core_reload.dts`: `/fpga-region`,
   `firmware-name = "de25_nano.core.rbf"`) through configfs - a fresh
   overlay each time, re-applying is what triggers the load. The kernel's
   FPGA manager loads the core through the SDM; ATF keeps the bridges
   closed during the load;
3. checks the overlay (`applied`), the FPGA manager (`operating`) and the
   board id over LWH2F (register 1 = `0xDE25`), and resumes the processes.

After a reload the fabric is in its reset state (blinker mode 0, fan duty
30, LED register 0) - software that set registers must set them again. The
console drops out for the ~2 s of the load.

A new core from a different build only works if its phase 1 is identical
(same HPS/DDR configuration, same Quartus) - FPGA-side logic and register
changes are fine; anything in the HPS IP is not (that needs a new `.jic`).

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
| `reboot` from Linux hangs (silent after `reboot: Restarting system`) | since ATF v2.14.1 (worked with 2.12); restart with the JTAG `.sof` load or a power cycle |
| ethernet receive stalled once after boot (link up, no RX) | `ip link set eth0 down; ip link set eth0 up` recovered it; cause unknown. The MAC is random on every boot (U-Boot `NET_RANDOM_ETHADDR`) |
| the console during early boot | silent until the core is loaded - use an FPGA-first build to debug SPL/U-Boot |
| web GUI during `fpga-reload` | paused for ~2 s; the fabric comes back with reset register values |
