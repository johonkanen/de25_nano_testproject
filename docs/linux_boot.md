# Booting Linux on the DE25-Nano

How the board gets from power-on to Linux and the web GUI, what each piece
is, and the settings that matter. Verified on hardware 2026-10-16, hands
off: power-on → SPL → ATF 2.14.1 → U-Boot 2026.04 → Linux 6.18.20 → web GUI
with the FPGA registers live over LWH2F. All three come from Altera
upstream (`altera-fpga`), which carries the DE25-Nano itself.

## The chain

```
power-on
  SDM          configures the FPGA from QSPI, loads the U-Boot SPL into HPS on-chip RAM
  SPL          initialises the 1 GB LPDDR4; loads u-boot.itb from the SD card's
               FAT partition, or - if that fails - from QSPI at 0xA00000
  ATF BL31     secure monitor (EL3), part of u-boot.itb
  U-Boot       `bridge enable`, then distro boot finds /extlinux/extlinux.conf
  Linux        Image + dtb from the FAT partition, root = SD partition 2 (ext4)
  Alpine init  rc.local: static IP, NTP, python3 (first boot) ; inittab starts
               /opt/de25web/supervisor.sh -> the web GUI on port 80
```

## Components

| piece | source | built by |
|---|---|---|
| FPGA + HPS config (`.sof`) | this repo, `build_de25_nano_uart.tcl` | Quartus Pro 26.1.1 |
| U-Boot SPL + U-Boot 2026.04 | `altera-fpga/u-boot-socfpga` `socfpga_v2026.04`, defconfig `socfpga_agilex5_de25_nano_defconfig` | `linux/build_de25_nano_linux.sh` |
| ATF BL31 v2.14.1 | `altera-fpga/arm-trusted-firmware` `socfpga_v2.14.1` | same |
| Linux 6.18.20 + `socfpga_agilex5_de25_nano.dtb` (upstream's own board DT) | `altera-fpga/linux-socfpga` `socfpga-6.18.20-lts` | same |
| rootfs | Alpine 3.24 aarch64 minirootfs + `linux/tools/alpine_rootfs_config.sh` | `linux/tools/make_sdcard_image.sh` |

## Settings that matter

**FPGA project** (`build_de25_nano_uart.tcl`)

| setting | value | why |
|---|---|---|
| `QSPI_OWNERSHIP` | `HPS` | the SPL reads U-Boot from QSPI; with `SDM` its first QSPI access stalls the bus |
| `HPS_INITIALIZATION` | `"AFTER INIT_DONE"` | the fabric is configured before the ARM cores run; `"HPS FIRST"` let Linux touch LWH2F too early and hung it (docs/de25_nano_lwh2f_bringup.md; what HPS-first would take: docs/hps_first_boot_research.md) |
| HPS IP `Pwr_a76_core2_on`/`_core3_on` | `true` | power for the two Cortex-A76 cores (Terasic's GHRD had them off) - they still don't start, see [Known gaps](#known-gaps) |
| MSEL (SW5) | AS / QSPI | the SDM boots from QSPI |

**U-Boot** (applied by the build script)

| setting | value | why |
|---|---|---|
| `CONFIG_BOOTCOMMAND` | `bridge enable; run distro_bootcmd` | upstream U-Boot leaves the HPS↔FPGA bridges in reset; Linux's first LWH2F read then dies with SIGBUS |
| `CONFIG_SYS_SPI_U_BOOT_OFFS` | `0x00A00000` | where the SPL looks for U-Boot in QSPI (upstream default; `make_jic.sh` puts it there) |
| `sdram_agilex5.c` | `dualport = 0` | Terasic's DE25-Nano DDR setting (single-port EMIF), kept from their U-Boot |
| environment | not needed | `extlinux.conf` carries the boot config; nothing to `saveenv` |

**Kernel**: `make defconfig` plus `CONFIG_SENSORS_SOC64=y` - the SoC's
temperature and voltage sensors (read by the SDM, `soc64-hwmon`) built in,
since the rootfs carries no modules. They appear as
`/sys/class/hwmon/hwmon0` (`soc64hwmon`); the web GUI shows them.

**ATF**: `SOCFPGA_UART_CONFIG=1` (console on UART1, this board's);
`config_ddr_size` patched to the detected size (the board has 1 GB;
upstream still hard-codes 2 GB).

**Kernel command line** (`/extlinux/extlinux.conf` on the FAT partition)

```
console=ttyS0,115200 root=/dev/mmcblk0p2 rw rootwait earlycon panic=-1 kvm-arm.mode=nvhe
```

`ttyS0` is HPS UART1, routed through the fabric onto the board's USB serial
port (`/dev/serial/by-id/usb-TERASIC_DE25-Nano_*-if03-port0`, 115200). No
`nosmp` (Terasic's old default): Linux starts every core it can.

## Flash and card layout

| QSPI (16 MB) | |
|---|---|
| `0x000000` | boot info |
| `0x200000` | bitstream + SPL (~0.7 MB) |
| `0xA00000` | `u-boot.itb` - the fallback when the card has none |

| SD card (768 MB image, rest of the card unused) | |
|---|---|
| p1, FAT32, bootable, 128 MB | `u-boot.itb`, `Image`, the `.dtb`, `extlinux/extlinux.conf` |
| p2, ext4 | Alpine; `/opt/de25web` (web GUI), static IP `192.168.1.222` |

## Build and install

```bash
# 1. FPGA
quartus_sh -t build_de25_nano_uart.tcl
quartus_ipgenerate de25_nano_uart -c de25_nano_uart --run_default_mode_op
quartus_syn de25_nano_uart && quartus_fit de25_nano_uart && quartus_sta de25_nano_uart && quartus_asm de25_nano_uart

# 2. ATF, U-Boot, kernel (~5 min with a cached toolchain: CROSS_TOOLCHAIN=...)
./linux/build_de25_nano_linux.sh

# 3. QSPI image (bitstream + SPL + U-Boot) and program it
./linux/make_jic.sh
quartus_pgm -c "DE25-Nano [1-3-iface0]" -m jtag -o "pvi;linux/build_output/de25_nano.jic"

# 4. SD card image, written over the network (or: gunzip -c ... | sudo dd of=/dev/sdX)
./linux/tools/make_sdcard_image.sh
python3 linux/tools/sd_recover.py          # power-cycle when it asks
```

`sd_recover.py` works with a blank or broken card: the SPL falls back to
U-Boot in QSPI, the script stops autoboot over the console, downloads the
image by TFTP (server started on Windows Python under WSL2, since the board
can't reach into WSL's NAT), checks its CRC32, `gzwrite`s it to the card
and boots it. The first boot installs `python3` (needs internet); copy
`linux/build_output/de25web_token` to `~/.de25web_token` for GUI updates.

## When it doesn't boot

| symptom on the console | cause |
|---|---|
| `spl_register_fat_device: fat register err` then `Trying to boot from SPI` | no FAT/u-boot.itb on the card - expected on a blank card; QSPI U-Boot takes over |
| SPL stops after `WDT: Started watchdog`, board resets every ~30 s | `QSPI_OWNERSHIP SDM`: the SPL's QSPI probe stalls |
| `Waiting for PHY auto negotiation ... TIMEOUT`, `phy_startup() failed: -110` | no ethernet link: cable or switch port |
| web GUI down, `supervisor.log` shows `exited (135)` | SIGBUS on LWH2F: bridges still in reset - U-Boot without `bridge enable` |
| `DDR: Configured DDR size is greater than the hardware size - HANG` | ATF without the `config_ddr_size` patch |

## Applying a new FPGA image without a power cycle

After programming the `.jic`, load the matching `.sof` with the SPL
embedded (written by `make_jic.sh`) over JTAG - the device reconfigures
and the board boots again, as from power-on:

```bash
quartus_pgm -c "DE25-Nano [1-3-iface0]" -m jtag -o "p;output_files/de25_nano_uart_hps_auto.sof@1"
```

From Linux over the network, without JTAG: docs/remote_system_update_plan.md
(planned); fabric-only changes without a reboot:
docs/partial_reconfiguration_plan.md (planned).

## Known gaps

| what | state |
|---|---|
| Cortex-A76 cores (CPU2, CPU3) | `CPU2: failed to come online` with ATF 2.12 and 2.14.1 alike, even with their power enabled in the HPS IP; Linux runs on the two A55s. The parts have A76s (Intel's Agilex 5 docs) - a firmware/configuration gap to investigate |
| QSPI flash in Linux | upstream's DT enables it, but the ID read is garbled (`unrecognized JEDEC id bytes: 90 5d 8c 08 22 00`, expected `20 bb 18`); U-Boot reads it fine with `cdns,read-delay` deleted - tune the Linux DT (read delay, clock) before RSU (docs/remote_system_update_plan.md, R0) |
| fan controller | reports its sticky `i2c_error` bit while working normally - not investigated |
