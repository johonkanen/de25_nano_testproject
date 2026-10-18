# Booting Linux on the DE25-Nano

How the board gets from power-on to Linux and the web GUI, what each piece
is, and the settings that matter. Verified on hardware 2026-10-16, hands
off: power-on → SPL → ATF 2.14.1 → U-Boot 2026.04 (loads the FPGA core) →
Linux 6.18.20 on all four cores → web GUI with the FPGA registers live over
LWH2F. All three come from Altera upstream (`altera-fpga`), which carries
the DE25-Nano itself. The boot is **HPS-first** - docs/hps_first.md has the
details, and how to reload the FPGA from a running Linux.

## The chain

```
power-on
  SDM          RSU: boots the highest-priority image that loads (P1, else the
               factory image) - its phase 1: HPS I/O, DDR I/O; loads its U-Boot
               SPL into HPS on-chip RAM (the FPGA fabric stays unconfigured)
  SPL          initialises the 1 GB LPDDR4; loads the U-Boot of that image:
               u-boot_<slot>.itb from the SD card's FAT partition (u-boot_P1.itb,
               u-boot_FACTORY_IMAGE.itb), or - if that fails - QSPI partition
               SSBL.<slot> (RSU multiboot; 0xA00000 without an RSU layout)
  ATF BL31     secure monitor (EL3), part of u-boot.itb
  U-Boot       preboot loads the running image's FPGA core (`rsu running_slot`:
               de25_nano_<image>.core.rbf from SD, else QSPI CORE.<image>) -
               the console appears only now; then `bridge enable`,
               and distro boot finds /extlinux/extlinux.conf
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
| `HPS_INITIALIZATION` | `"HPS FIRST"` (default; `FPGA_FIRST=1` gives `"AFTER INIT_DONE"`) | software loads the FPGA core, so Linux can reload it without a reboot (docs/hps_first.md). The old HPS-first hang was the core never being loaded (docs/de25_nano_lwh2f_bringup.md) |
| HPS IP `Pwr_a76_core2_on`/`_core3_on` | `true` | power for the two Cortex-A76 cores; `hps/hps_subsys.tcl` (commit aa10d49) had them off. After editing a `.ip`, regenerate it explicitly (docs/hps_first.md, Build) - stale generated HDL kept the cores off once (docs/a76_cores_research.md) |
| MSEL (SW5) | AS / QSPI | the SDM boots from QSPI |

**U-Boot** (applied by the build script)

| setting | value | why |
|---|---|---|
| `CONFIG_PREBOOT` | load the FPGA core if FPGA_CONFIG (`0x10d120dc`) isn't 3 | HPS-first: nothing else configures the fabric (docs/hps_first.md) |
| `CONFIG_BOOTCOMMAND` | `bridge enable; run distro_bootcmd` | upstream U-Boot leaves the HPS↔FPGA bridges in reset; Linux's first LWH2F read then dies with SIGBUS |
| `CONFIG_SYS_SPI_U_BOOT_OFFS` | `0x00A00000` | where the SPL looks for U-Boot in QSPI (upstream default; `make_jic.sh` puts it there) |
| `sdram_agilex5.c` | `dualport = 0` | Terasic's DE25-Nano DDR setting (single-port EMIF), kept from their U-Boot |
| environment | not needed | `extlinux.conf` carries the boot config; nothing to `saveenv` |

**Kernel**: `make defconfig` plus `CONFIG_SENSORS_SOC64=y` - the SoC's
temperature and voltage sensors (read by the SDM, `soc64-hwmon`) built in,
since the rootfs carries no modules. They appear as
`/sys/class/hwmon/hwmon0` (`soc64hwmon`); the web GUI shows them. And the
FPGA manager, bridges and fpga-region driver (`FPGA_MGR_STRATIX10_SOC`,
`FPGA_BRIDGE`, `FPGA_REGION`, `OF_FPGA_REGION` `=y`) for `fpga-reload`.

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
| `0x000000` | boot info + RSU decision firmware (to `0x20FFFF`) |
| `0x220000` | factory image: phase 1 (HPS I/O, DDR I/O) + SPL, 1 MB slot (~0.8 MB used) |
| `0x320000` | SPT0, SPT1, CPB0, CPB1 (32 KB each): the RSU slot and priority tables |
| `0x400000` | P1: application image, 1 MB slot - the SDM boots it first; same build as the factory image until an update writes it |
| `0x500000` | `SSBL.FACTORY_IM`: the factory image's `u-boot.itb` |
| `0x600000` | `SSBL.P1`: P1's `u-boot.itb` - the SPL takes these when the card has no `u-boot_<slot>.itb` |
| `0xA00000` | `u-boot.itb` - the fallback of an SPL without RSU multiboot, or a flash without the RSU layout |
| `0xC00000` | `CORE.FACTORY_IM`: the factory image's FPGA core - the fallback when the card has none (4 KB size header + core); also where U-Boots without `rsu running_slot` look |
| `0xD10000` | `CORE.P1`: P1's FPGA core, same format |

| SD card (768 MB image, rest of the card unused) | |
|---|---|
| p1, FAT32, bootable, 128 MB | `u-boot_P1.itb`, `u-boot_FACTORY_IMAGE.itb` (the SPL loads the one of the image running), `u-boot.itb` (SPLs without multiboot), `de25_nano_P1.core.rbf`, `de25_nano_FACTORY_IMAGE.core.rbf` (each image's core; `de25_nano.core.rbf` for U-Boots without `rsu running_slot`), `Image`, the `.dtb`, `extlinux/extlinux.conf` |
| p2, ext4 | Alpine; `/opt/de25web` (web GUI), static IP `192.168.1.222`; `/lib/firmware/de25_nano.core.rbf` + the reload overlay, `/usr/sbin/fpga-reload` |

## Build and install

```bash
# 1. FPGA
quartus_sh -t build_de25_nano_uart.tcl
quartus_ipgenerate de25_nano_uart -c de25_nano_uart --run_default_mode_op
quartus_syn de25_nano_uart && quartus_fit de25_nano_uart && quartus_sta de25_nano_uart && quartus_asm de25_nano_uart

# 2. ATF, U-Boot, kernel (~5 min with a cached toolchain: CROSS_TOOLCHAIN=...)
./linux/build_de25_nano_linux.sh

# 3. QSPI image (phase 1 + SPL + U-Boot + core) and the core file
./linux/make_jic.sh

# 4. SD card image, written over the network (or: gunzip -c ... | sudo dd of=/dev/sdX)
./linux/tools/make_sdcard_image.sh
python3 linux/tools/sd_recover.py          # power-cycle when it asks

# 5. then program QSPI, and restart (JTAG .sof load or power cycle)
quartus_pgm -c "DE25-Nano [1-3-iface0]" -m jtag -o "pvi;linux/build_output/de25_nano.jic"
quartus_pgm -c "DE25-Nano [1-3-iface0]" -m jtag -o "p;output_files/de25_nano_uart_hps_auto.sof@1"
```

Card before QSPI: an HPS-first `.jic` needs a U-Boot with the preboot core
loader on the card (docs/hps_first.md, Install).

`sd_recover.py` works with a blank or broken card: the SPL falls back to
U-Boot in QSPI, the script stops autoboot over the console, downloads the
image by TFTP (server started on Windows Python under WSL2, since the board
can't reach into WSL's NAT), checks its CRC32, `gzwrite`s it to the card
and boots it. The first boot installs `python3` (needs internet); copy
`linux/build_output/de25web_token` to `~/.de25web_token` for GUI updates.

## When it doesn't boot

| symptom on the console | cause |
|---|---|
| nothing at all, ever | HPS-first and the core not loaded: the card's U-Boot lacks the preboot loader, or core and `.jic` are from different builds (docs/hps_first.md) |
| `spl_register_fat_device: fat register err` then `Trying to boot from SPI` | no FAT/u-boot.itb on the card - expected on a blank card; QSPI U-Boot takes over |
| SPL stops after `WDT: Started watchdog`, board resets every ~30 s | `QSPI_OWNERSHIP SDM`: the SPL's QSPI probe stalls |
| `Waiting for PHY auto negotiation ... TIMEOUT`, `phy_startup() failed: -110` | no ethernet link: cable or switch port |
| web GUI down, `supervisor.log` shows `exited (135)` | SIGBUS on LWH2F: bridges still in reset - U-Boot without `bridge enable` |
| `DDR: Configured DDR size is greater than the hardware size - HANG` | ATF without the `config_ddr_size` patch |

## Applying a new FPGA image without a power cycle

- **New fabric, Linux keeps running:** `linux/tools/deploy_fpga.py` (or
  `fpga-reload [new.core.rbf]` on the board) - ~2 s, docs/hps_first.md.
  The core must come from a build with the same periphery (pins, HPS/DDR
  configuration); the manifest's periphery hash is checked before a load.
- **New phase 1 / everything:** program the `.jic`, then load the matching
  `.sof` with the SPL embedded over JTAG - the device reconfigures and boots
  again, as from power-on:

```bash
quartus_pgm -c "DE25-Nano [1-3-iface0]" -m jtag -o "p;output_files/de25_nano_uart_hps_auto.sof@1"
```

From Linux over the network, without JTAG, for phase 1 too:
docs/remote_system_update_plan.md (planned); parts of the fabric only:
docs/partial_reconfiguration_plan.md (planned).

## Known gaps

| what | state |
|---|---|
| `reboot` after a JTAG start | a session started by a JTAG `.sof` load can't `reboot`: the SDM accepts `REBOOT_HPS` but the SPL came over JTAG, so there is nothing to restart the HPS from - silent after `reboot: Restarting system`. After a power-on boot (from QSPI) `reboot` works (verified 2026-10-17). Not an ATF bug: ATF 2.12/2.14.1, HPS-/FPGA-first, Linux 6.12/6.18 and `maxcpus=2` all behaved the same after JTAG starts |
| root filesystem after many reboots | **fixed 2026-10-17**: busybox init ran `umount -a -r` while the web GUI still held its logs open for writing, so the remount to read-only failed and every reboot reset a read-write root; after a run of ~20 test reboots the ext4 journal was broken ("error loading journal", -74) and the card had to be written again (`sd_recover.py`). The inittab now stops every process (`killall5` TERM, 2 s, KILL) before `umount -a -r`; the console shows `re-mounted ... ro` before `reboot: Restarting system` |
| `quartus_pgm` "Erase failed on flash chip select 0 at address 0x00C00000" (2026-10-18, once) | the flash below that address was already erased, so the board did not boot after a power cycle; programming the same `.jic` again worked. Check the programmer's result before power-cycling |
| ethernet after a warm reboot | about 1 in 5 warm reboots (none seen after power-on) eth0 has link but passes no traffic - either the RX DMA stops (SMMU `F_TRANSLATION` faults on the EMAC rings at the first open, fatal bus error, frames overflow the MAC FIFO) or transmitted frames are lost after the MAC. Not a running DMA across the reboot (stopping eth0 first did not help), not the PHY delays (`rgmii-id` kills the link: the board carries the delays). `eth0` down/up clears both (and can itself land in the stall, seen once); `/usr/sbin/eth-watchdog` (linux/board/eth-watchdog.sh) does that when the gateway stops answering - tested: 15 warm reboots all up, and a real stall recovered by its next check. Root cause open. The MAC is random on every boot (U-Boot `NET_RANDOM_ETHADDR`) |
| QSPI flash in Linux | **fixed 2026-10-17**: the dtsi's QSPI reference clock is a fixed 200 MHz, the SDM's is 500 MHz (U-Boot prints `QSPI: Reference clock at 500000 kHz`), so Linux ran the flash at ~250 MHz - JEDEC id shifted by a bit (`90 5d 8c`, is `20 bb 18`), bulk reads different every time. `build_de25_nano_linux.sh` sets `&qspi_clk` to 500 MHz: `/dev/mtd0`, 1 MB read back identical with `cdns,read-delay` 0..3 (the DTS's 2 kept) |
| fan controller | reports its sticky `i2c_error` bit while working normally - not investigated |
