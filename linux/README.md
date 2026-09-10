# linux/ — Linux for the DE25-Nano

> ✅ **Booted to a live root shell on hardware** — real QSPI cold boot
> (SPL) → ATF BL31 → U-Boot → Linux 6.12.11 (Terasic's own kernel fork),
> toybox userspace, over the HPS UART1 console. See
> [Session status](#session-status) below.
>
> ✅ **A real, persistent rootfs is also hardware-confirmed**: Alpine
> Linux on a second SD card partition (ext4, mounted directly as root, no
> initramfs) — real dynamic linking (musl libc) and a working `apk`
> package manager, boots fully unattended (networking, hostname, and NTP
> time sync all self-configure). See
> [Real rootfs (Alpine Linux)](#real-rootfs-alpine-linux) below.

Unlike [`de25_std_testproject/linux/`](../../de25_std_testproject/linux/README.md)
(which had to detour through upstream `altera-fpga` forks before finding a
board-specific U-Boot fork was necessary), this goes straight to
**Terasic's own dedicated DE25-Nano branch on all three repos** — ATF,
U-Boot, and the kernel. That combination booted on real hardware essentially
first try, aside from one already-known ATF bug (patched automatically by
the build script).

## Files

| file | what |
|------|------|
| `build_de25_nano_linux.sh` | orchestrator — toolchain, ATF, U-Boot, kernel, toybox initramfs, `sdcard.img` |
| `patches/` | ATF/U-Boot fixes found while chasing the LWH2F bring-up bug, proven unnecessary once the real root cause was found — kept for reference, **not applied** — see `patches/README.md` |
| `make_jic.sh` | combines the SPL with `output_files/de25_nano_uart.sof` into a QSPI `.jic` |
| `tools/setup_alpine_rootfs.sh` | replaces the toybox initramfs with a real, persistent Alpine Linux rootfs — see [Real rootfs](#real-rootfs-alpine-linux) |
| `tools/push_to_nano.py` | pushes/runs a file on the board over the network, driven from the serial console — see [Writing and running your own software](#writing-and-running-your-own-software) |

## Prerequisites

Linux host, internet, ~15 GB free, and:
```
git wget xz-utils bc bison flex libssl-dev python3 mtools dosfstools
```
Quartus in `PATH` (for the `quartus_pfg` JIC step).

| env | for |
|-----|-----|
| `CROSS_TOOLCHAIN=<dir>` | use an existing toolchain (dir with `bin/aarch64-none-linux-gnu-gcc`) instead of downloading |
| `MTOOLS_BIN=<dir>` | where `mformat`/`mcopy` live if `mtools` isn't installed system-wide |
| `SOF=<path>` | override the `.sof` in `make_jic.sh` (default `output_files/de25_nano_uart.sof`) |

## Build

```bash
# 1. FPGA - build the fabric+HPS design with the QSPI fixes (see repo root
#    README and build_de25_nano_uart.tcl — QSPI_OWNERSHIP HPS and
#    HPS_INITIALIZATION "HPS FIRST" MUST be set, or SPL hangs forever on
#    its first QSPI register read)
quartus_sh -t build_de25_nano_uart.tcl
quartus_syn de25_nano_uart && quartus_fit de25_nano_uart && quartus_asm de25_nano_uart

# 2. Linux
./linux/build_de25_nano_linux.sh

# 3. QSPI image
./linux/make_jic.sh
```

Outputs in `linux/build_output/`:

| file | ~size | from |
|------|------:|------|
| `bl31.bin` | 60 KB | ARM Trusted Firmware, Terasic's `de25-nano-v2.12.0` |
| `u-boot.itb` | ~1 MB | U-Boot proper (FIT, contains BL31) |
| `spl/u-boot-spl-dtb.hex` | ~700 KB | first-stage loader → goes in the `.jic` |
| `Image` | ~47 MB | Linux kernel 6.12.11 |
| `socfpga_agilex5_de25_nano.dtb` | 24 KB | Terasic's own device tree for this exact board |
| `initramfs.cpio` | ~7 MB | toybox `mkroot` rootfs (architecture-generic, reused as-is from `de25_std_testproject`) |
| `sdcard.img` | 96 MB | FAT32: `u-boot.itb` + `Image` + `.dtb` + `initramfs.cpio` |
| `de25_nano.jic` | 16 MB | SPL + bitstream, for QSPI |

## Boot media

Like the Standard board: **SPL + bitstream go in QSPI**, **kernel + rootfs
go on the SD card**.

1. Write `sdcard.img` to the SD card:
   ```bash
   sudo dd if=linux/build_output/sdcard.img of=/dev/sdX bs=1M status=progress conv=fsync && sync
   ```
   (On WSL2: forward a USB SD card reader with `usbipd attach --wsl
   --busid <id>` first, same pattern as the USB-Blaster — see the repo
   root README's WSL2 section.)
2. Program the `.jic` (board on JTAG):
   ```bash
   quartus_pgm -c 1 -m jtag -o "pvi;linux/build_output/de25_nano.jic"
   ```
3. Insert the SD card into the board, power-cycle (MSEL should already be
   set for QSPI/AS boot — same setting used for the working `de25_nano_uart.sof`
   JTAG-loadable image; see the repo root README's [HPS](../README.md#hps)
   section for the switch table if you need to change it).
4. Console on the HPS UART1 (`/dev/ttyUSB0` on this board) @ 115200.

Boot flow: SDM → SPL (QSPI, DDR init) → ATF BL31 + U-Boot proper (loaded
from the SD card's FAT partition) → U-Boot prompt → manual `booti` (below)
→ Linux → toybox shell.

### Boot commands

Terasic's default `distro_bootcmd` doesn't know where our images are (it
tries QSPI/NAND script sources first, which fail harmlessly) and lands at
an interactive prompt. From there:

```
fatload mmc 0:1 0x82000000 Image
fatload mmc 0:1 0x86000000 socfpga_agilex5_de25_nano.dtb
fatload mmc 0:1 0x90000000 initramfs.cpio
booti 0x82000000 0x90000000:${filesize} 0x86000000
```

**Use `${filesize}` literally** (U-Boot sets it after each `fatload` to the
exact byte count read) — don't hardcode the initramfs size by hand, it's
easy to mistype a hex value.

You'll see `Initramfs unpacking failed: invalid magic at start of
compressed archive` during every boot regardless — this `initramfs.cpio`
is a plain, uncompressed cpio archive (toybox's `mkroot` doesn't gzip it),
so the kernel's compression-format auto-detection fails to match any
codec's magic bytes before falling back to unpacking it directly as raw
cpio, which succeeds. Harmless, not a sign anything's wrong.

Default `bootargs` (`console=ttyS0,115200 initrd=0x90000000 root=/dev/ram0
rw init=/sbin/init ramdisk_size=10000000 earlycon panic=-1 nosmp
kvm-arm.mode=nvhe`) already matches this initramfs-based boot — no need to
change it.

To skip retyping this every boot, save it as the default:
```
setenv bootcmd 'fatload mmc 0:1 0x82000000 Image; fatload mmc 0:1 0x86000000 socfpga_agilex5_de25_nano.dtb; fatload mmc 0:1 0x90000000 initramfs.cpio; booti 0x82000000 0x90000000:${filesize} 0x86000000'
saveenv
```
If `saveenv` fails with `Saving Environment to UBI... Partition root not
found!`, the failed QSPI/NAND boot-script probes earlier in this same boot
switched the active environment backend away from FAT - force it back
first: `env select FAT` then `env save` (equivalent to `saveenv`, but
lets you pick the target).

## Real rootfs (Alpine Linux)

Swaps the in-RAM toybox rootfs for a real, persistent one: Alpine Linux
(aarch64) on a second SD card partition (ext4), mounted directly as root
- no initramfs at all. Unlike toybox, Alpine has **real dynamic linking**
(musl libc) and `apk`, a working package manager - `apk add <anything>`
just works once networking is up.

### One-time setup

Needs the SD card in a reader on the *host* (not the board) - there's no
`fdisk`/`mkfs.ext4`/`tar` on the board's toybox rootfs, so the
partitioning can't be done remotely:

```bash
sudo ./linux/tools/setup_alpine_rootfs.sh
```

This **repartitions the whole card** (destroys the current single-FAT32
"superfloppy" layout `build_de25_nano_linux.sh`'s `sdcard.img` writes -
`parted print` on that layout reports `Partition Table: loop`, meaning
there's no real MBR to just add a partition to) into:
- partition 1 (FAT32, ~150MB): `u-boot.itb`, `Image`, the board's `.dtb`
  (restored automatically from `build_output/`)
- partition 2 (ext4, rest of the card): Alpine's minirootfs, with
  networking/hostname/NTP baked into `/etc/rc.local` (see
  [Networking](#networking) below for the static IP background) and a
  minimal hand-written `/etc/inittab` (no `openrc` - just mounts
  `/proc`/`/sys`/`/dev`, runs `rc.local`, then spawns a login-free shell
  directly on `ttyS0`, matching the toybox setup's dev-friendly style).
  `DEV`, `NANO_IP`, `NANO_GW`, and `ALPINE_VERSION` env vars override the
  defaults.

Put the card back in the board and power-cycle.

### Boot commands (one-time, persists after)

Same U-Boot prompt as [Boot commands](#boot-commands) above, but no
initrd this time - root mounts straight from the ext4 partition:

```
fatload mmc 0:1 0x82000000 Image
fatload mmc 0:1 0x86000000 socfpga_agilex5_de25_nano.dtb
setenv bootargs 'console=ttyS0,115200 root=/dev/mmcblk0p2 rw rootwait earlycon panic=-1 nosmp kvm-arm.mode=nvhe'
booti 0x82000000 - 0x86000000
```

To make this the permanent default (recommended - after this, every power
cycle boots straight to a working Alpine shell with no manual steps at
all):
```
setenv bootcmd 'fatload mmc 0:1 0x82000000 Image; fatload mmc 0:1 0x86000000 socfpga_agilex5_de25_nano.dtb; booti 0x82000000 - 0x86000000'
env select FAT
env save
```
(`env select FAT` first, same reason as the toybox bootcmd note above.)

Hardware-confirmed end to end: after this, a cold power cycle alone (zero
manual commands) reaches a shell with `hostname` = `de25-nano`, `eth0` on
the static IP, correct time (`date` matching real time, not the 1970
epoch a board with no RTC starts at), and `apk add htop` successfully
downloading, verifying (TLS - which is *why* the NTP sync matters:
without a correct clock, cert validation fails), and installing a real
package.

### There's no RTC

`date` starts at the Unix epoch every boot (no battery-backed clock on
this board) - `rc.local`'s `ntpd -q -n -p pool.ntp.org` (after a `sleep
2` for the link to actually finish training; without it this races and
silently fails on a fair number of boots) fixes it, but only once
networking is up. If you need correct time earlier in boot than that,
this doesn't solve it.

## Writing and running your own software

**On the toybox rootfs** there's **no dynamic linker or shared libraries
at all** (`/lib` doesn't exist — `/bin/sh` is a symlink straight to the
static `toybox` binary). Anything you build **must be statically
linked**, or it fails to run with a confusing "no such file or directory":

```bash
export PATH=/home/jari/dev/de25-nano.sdmmc/gcc-arm-11.2-2022.02-x86_64-aarch64-none-linux-gnu/bin:$PATH
aarch64-none-linux-gnu-gcc -static -o myprogram myprogram.c
```
(any `aarch64-none-linux-gnu-*` cross toolchain works — this is just the
one already downloaded by `build_de25_nano_linux.sh`.)

**On the [Alpine rootfs](#real-rootfs-alpine-linux)**, normal dynamic
linking works, so cross-compiling isn't even necessary if you'd rather
not: `apk add gcc musl-dev` on the board itself and compile natively. The
push workflow below works unchanged either way — `nc` is present in both
rootfs's.

### Networking

There's no DHCP client in this toybox build, and WSL2's own virtual
network can't be reached *from* the LAN — so the board uses a static IP,
and files get pushed *from* the host, not the other way around.

**This is now baked into `/init`** (`build_de25_nano_linux.sh` patches
mkroot's stock QEMU-oriented network setup automatically), so it comes up
with a working IP on every boot with no manual steps:
```
ifconfig eth0 192.168.1.222 netmask 255.255.255.0 up
route add default gw 192.168.1.1
```
If your LAN's subnet differs, edit the two `sed` replacement lines in
`build_de25_nano_linux.sh`'s toybox section (search for `192.168.1`) before
building, or just re-run the same `ifconfig`/`route` commands by hand at
the shell with your own values - confirm reachability from the host with
`ping <IP>` either way.

`toybox`'s rootfs has `nc`/`wget`/`ftpget`/`httpd` but no `scp`/`ssh`. The
working transfer direction is host → board (the board can't reach WSL2's
private NAT'd address): the board listens (`nc -l -p PORT > file`), the
host connects and pushes (`nc <board-ip> PORT < file`).

[`tools/push_to_nano.py`](tools/push_to_nano.py) automates this over the
serial console (there's no other way to start the listener remotely) —
verified end to end with a real cross-compiled binary:
```bash
python3 linux/tools/push_to_nano.py ./myprogram /tmp/myprogram --run
```
Drops the file at `/tmp/myprogram` on the board and (with `--run`) chmods
it executable and runs it, streaming its output back over the same serial
connection. Needs `pip install pyserial`. `--serial`, `--nano-ip`, and
`--port` override the defaults if yours differ.

## Session status

Real QSPI cold boot (SPL, confirmed via `Reset state: Cold`) through the
whole chain using Terasic's own de25-nano forks, after applying the
`config_ddr_size` ATF bug fix (hardcoded to 2GB — same bug independently
found and fixed in `de25_std_testproject` and in the `freertos-socfpga`
QSPI work; this board's LPDDR4 is 1GB) — a `sed` in
`build_de25_nano_linux.sh` itself.

`linux/patches/` holds two more fixes (`arm-trusted-firmware.patch` and
`u-boot-socfpga.patch`) found while chasing a permanent LWH2F-bridge
freeze, but **neither is applied** — both were proven unnecessary
(hardware-confirmed on 2026-09-10: reverted both, rebuilt BL31 + U-Boot
SPL from pristine upstream sources, still booted cleanly with LWH2F
fully working across two independent power cycles) once the real root
cause was fixed on the FPGA side instead. See `linux/patches/README.md`
for what they do and why they're kept anyway, and
[docs/de25_nano_lwh2f_bringup.md](../docs/de25_nano_lwh2f_bringup.md)
for the full investigation.

This also depends on `QSPI_OWNERSHIP SDM` + `HPS_INITIALIZATION
"AFTER INIT_DONE"` in `build_de25_nano_uart.tcl` (the FPGA project, not
this directory) — **not** `QSPI_OWNERSHIP HPS` + `HPS_INITIALIZATION
"HPS FIRST"`, which was tried first and fixed the original QSPI-cold-boot
hang but broke LWH2F and the ethernet PHY as a side effect. See
`memory/de25_nano_qspi_ownership_fix.md` and
`memory/de25_nano_lwh2f_hps_first_regression.md` for the full story.

Full boot trace (SPL → BL31 → U-Boot → kernel → shell):
- SPL: `LPDDR4: 1024 MiB`, `DDR: size check success`, `DDR: init success`
- SPL loads `u-boot.itb` from `mmc0` (SD), all FIT hashes (`board-0`,
  `atf`, `uboot`, `fdt-0`) verify OK
- BL31: `v2.12.0(release):de25_nano_revA_v1.0-dirty`
- U-Boot: `Model: SoCFPGA Agilex5 Terasic DE25-Nano`, `DRAM: 1 GiB`, `MMC:
  mmc0@10808000: 0`, EMAC (`eth0`, KSZ9031 PHY) probed
- Linux 6.12.11: `Machine model: SoCFPGA Agilex5 Terasic DE25-Nano`, SD
  card (`mmcblk0`, 29.1 GiB, partition table read), KSZ9031 Gigabit PHY
  driver bound, live toybox shell reachable and responsive over
  `/dev/ttyUSB0`

**Not yet done**: no real rootfs (still the in-RAM toybox one), no DT
hardening beyond what Terasic ships, HPS↔FPGA bridge nodes not added to
the DT (this design's LWH2F bridge is already wired and hardware-confirmed
working from the FreeRTOS/bare-metal work — see the repo root README's
[HPS](../README.md#hps) section — just not yet exposed to Linux).

## From here

- **Real rootfs**: build Buildroot or drop a Debian arm64 tarball onto an
  ext4 partition, matching `de25_std_testproject/linux/README.md`'s
  approach.
- **Automate the boot**: the `setenv bootcmd` / `saveenv` snippet above
  persists across power cycles (saved to `uboot.env` on the SD card's FAT
  partition).
- **HPS↔FPGA comms from Linux**: add a `soc2fpga`/`lwsoc2fpga` node to
  `socfpga_agilex5_de25_nano.dts` if you want the LWH2F bridge (already
  wired and working at the bare-metal level) reachable from userspace.
