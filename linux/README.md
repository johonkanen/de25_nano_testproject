# linux/ — Linux for the DE25-Nano

> ✅ **Booted to a live root shell on hardware** — real QSPI cold boot
> (SPL) → ATF BL31 → U-Boot → Linux 6.12.11 (Terasic's own kernel fork),
> toybox userspace, over the HPS UART1 console. See
> [Session status](#session-status) below.

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
| `make_jic.sh` | combines the SPL with `output_files/de25_nano_uart.sof` into a QSPI `.jic` |

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
exact byte count read) — don't hardcode the initramfs size by hand, a
slightly-wrong value produces a harmless-looking but confusing `Initramfs
unpacking failed: invalid magic` warning during boot (the archive still
unpacks almost entirely correctly if the size is only slightly too large,
which is how this was first found — but don't rely on that).

Default `bootargs` (`console=ttyS0,115200 initrd=0x90000000 root=/dev/ram0
rw init=/sbin/init ramdisk_size=10000000 earlycon panic=-1 nosmp
kvm-arm.mode=nvhe`) already matches this initramfs-based boot — no need to
change it.

To skip retyping this every boot, save it as the default:
```
setenv bootcmd 'fatload mmc 0:1 0x82000000 Image; fatload mmc 0:1 0x86000000 socfpga_agilex5_de25_nano.dtb; fatload mmc 0:1 0x90000000 initramfs.cpio; booti 0x82000000 0x90000000:${filesize} 0x86000000'
saveenv
```

## Writing and running your own software

The toybox rootfs has **no dynamic linker or shared libraries at all**
(`/lib` doesn't exist — `/bin/sh` is a symlink straight to the static
`toybox` binary). Anything you build **must be statically linked**, or it
fails to run with a confusing "no such file or directory":

```bash
export PATH=/home/jari/dev/de25-nano.sdmmc/gcc-arm-11.2-2022.02-x86_64-aarch64-none-linux-gnu/bin:$PATH
aarch64-none-linux-gnu-gcc -static -o myprogram myprogram.c
```
(any `aarch64-none-linux-gnu-*` cross toolchain works — this is just the
one already downloaded by `build_de25_nano_linux.sh`.)

### Networking

There's no DHCP client in this toybox build, and WSL2's own virtual
network can't be reached *from* the LAN — so set a static IP on the
board and push files *from* the host, not the other way around.

Each boot, from the U-Boot-reached shell (or right after `booti`):
```
ifconfig eth0 <IP> netmask 255.255.255.0 up
route add default gw <LAN gateway>
```
Pick `<IP>` free on your LAN (outside your router's DHCP range) - this
was verified working with `192.168.1.222` / gateway `192.168.1.1` on a
typical home LAN. Confirm from the host with `ping <IP>`.

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

**Not yet done**: the static IP doesn't persist across reboots (toybox's
`mkroot` init doesn't run a network config step) - re-run the `ifconfig`/
`route` commands each boot, or add them to a startup script if you rebuild
the initramfs.

## Session status

Real QSPI cold boot (SPL, confirmed via `Reset state: Cold`) through the
whole chain on the first attempt using Terasic's own de25-nano forks,
after applying the one known ATF bug fix (`config_ddr_size` hardcoded to
2GB — same bug independently found and fixed in `de25_std_testproject` and
in the `freertos-socfpga` QSPI work; this board's LPDDR4 is 1GB).

This also depended on the QSPI fix from
`memory/de25_nano_qspi_ownership_fix.md` — `QSPI_OWNERSHIP HPS` +
`HPS_INITIALIZATION "HPS FIRST"` in `build_de25_nano_uart.tcl` — without
which SPL hangs forever on its first QSPI register read, identically to
the symptom that fix was originally found for.

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
