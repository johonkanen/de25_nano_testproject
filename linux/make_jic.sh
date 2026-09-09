#!/usr/bin/env bash
# Combine the FPGA bitstream + U-Boot SPL into a QSPI flash image (.jic)
# for the DE25-Nano. Run linux/build_de25_nano_linux.sh first (for the SPL)
# and build output_files/de25_nano_uart.sof (quartus_syn/fit/asm) at the
# repo root first.
#
#   ./linux/make_jic.sh
#
# The SPL boots from QSPI, then loads u-boot.itb / Image / dtb / initramfs
# from the SD card (sdcard.img), so only SPL+bitstream go in the .jic.
#
# IMPORTANT: the .sof MUST have been built with QSPI_OWNERSHIP HPS and
# HPS_INITIALIZATION "HPS FIRST" set (see build_de25_nano_uart.tcl at the
# repo root) - without them SPL hangs forever on its first QSPI register
# read, identically to the bug hit chasing FreeRTOS-over-QSPI boot (see
# memory/de25_nano_qspi_ownership_fix.md).
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOF="${SOF:-${HERE}/../output_files/de25_nano_uart.sof}"
SPL="${SPL:-${HERE}/build_output/spl/u-boot-spl-dtb.hex}"
JIC="${JIC:-${HERE}/build_output/de25_nano.jic}"

# DE25-Nano: Micron MT25QU128 QSPI flash (128Mb/16MB - same part as the
# DE25-Standard, confirmed via Terasic's own sof_to_jic.bat), device
# A5EB013BB23BCS (the full string WITH the CS suffix - the abbreviated
# "A5EB013BB23B" Terasic's own script uses resolves to a different JTAG
# IDCODE than this board's actual one; see memory/de25_nano_qspi_ownership_fix.md)
DEVICE="${DEVICE:-MT25QU128}"
FLASH_LOADER="${FLASH_LOADER:-A5EB013BB23BCS}"

[[ -f "${SOF}" ]] || { echo "missing ${SOF} - build the FPGA first"; exit 1; }
[[ -f "${SPL}" ]] || { echo "missing ${SPL} - run build_de25_nano_linux.sh first"; exit 1; }

quartus_pfg -c "${SOF}" "${JIC}" \
    -o hps_path="${SPL}" \
    -o device="${DEVICE}" \
    -o flash_loader="${FLASH_LOADER}" \
    -o mode=ASX4

echo
echo "wrote ${JIC}"
echo
echo "program it (board on JTAG; on WSL2 forward the USB-Blaster first, see"
echo "../program.sh):"
echo "    quartus_pgm -c 1 -m jtag -o \"pvi;${JIC}\""
echo "then write sdcard.img to the SD card, insert it, and power-cycle"
echo "(MSEL should already be set for QSPI/AS boot - see README.md)."
