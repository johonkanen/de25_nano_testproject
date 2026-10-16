#!/usr/bin/env bash
# Combine the FPGA bitstream, the U-Boot SPL and U-Boot proper into a QSPI
# flash image (.jic) for the DE25-Nano. Run linux/build_de25_nano_linux.sh
# first (SPL, u-boot.itb) and build output_files/de25_nano_uart.sof
# (quartus_syn/fit/asm) at the repo root first.
#
#   ./linux/make_jic.sh
#
# QSPI layout (16 MB MT25QU128):
#   0x000000  boot info + bitstream + SPL (~3 MB)
#   0xA00000  u-boot.itb (QSPI_UBOOT_OFFS, the SPL's CONFIG_SYS_SPI_U_BOOT_OFFS)
# The SPL loads u-boot.itb from the SD card's FAT partition if it can, else
# this QSPI copy - so a blank or broken card still reaches a U-Boot prompt,
# from which linux/tools/sd_recover.py rewrites the card over TFTP.
# Kernel, dtb and rootfs always come from the SD card.
#
# The .sof must keep build_de25_nano_uart.tcl's QSPI_OWNERSHIP SDM +
# HPS_INITIALIZATION "AFTER INIT_DONE" (the Quartus defaults). The earlier
# QSPI_OWNERSHIP HPS + "HPS FIRST" combination hung every LWH2F access -
# see docs/de25_nano_lwh2f_bringup.md. The SPL asks the SDM for the QSPI
# (mbox_qspi_open) before reading U-Boot from it.
#
# Env overrides: SOF=, SPL=, JIC=, UBOOT_ITB= (empty: bitstream + SPL only,
# the old layout), QSPI_UBOOT_OFFS= (must match the U-Boot build).
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOF="${SOF:-${HERE}/../output_files/de25_nano_uart.sof}"
SPL="${SPL:-${HERE}/build_output/spl/u-boot-spl-dtb.hex}"
JIC="${JIC:-${HERE}/build_output/de25_nano.jic}"
UBOOT_ITB="${UBOOT_ITB-${HERE}/build_output/u-boot.itb}"
QSPI_UBOOT_OFFS="${QSPI_UBOOT_OFFS:-0x00A00000}"

# DE25-Nano: Micron MT25QU128 QSPI flash (128Mb/16MB - same part as the
# DE25-Standard, confirmed via Terasic's own sof_to_jic.bat), device
# A5EB013BB23BCS (the full string WITH the CS suffix - the abbreviated
# "A5EB013BB23B" Terasic's own script uses resolves to a different JTAG
# IDCODE than this board's actual one)
DEVICE="${DEVICE:-MT25QU128}"
FLASH_LOADER="${FLASH_LOADER:-A5EB013BB23BCS}"

[[ -f "${SOF}" ]] || { echo "missing ${SOF} - build the FPGA first"; exit 1; }
[[ -f "${SPL}" ]] || { echo "missing ${SPL} - run build_de25_nano_linux.sh first"; exit 1; }

if [[ -z "${UBOOT_ITB}" ]]; then
    echo ">> bitstream + SPL only"
    quartus_pfg -c "${SOF}" "${JIC}" \
        -o hps_path="${SPL}" \
        -o device="${DEVICE}" \
        -o flash_loader="${FLASH_LOADER}" \
        -o mode=ASX4
else
    [[ -f "${UBOOT_ITB}" ]] || {
        echo "missing ${UBOOT_ITB} - run build_de25_nano_linux.sh first (or UBOOT_ITB= to leave it out)"; exit 1; }
    # clear of the bitstream (~3 MB) and inside the 16 MB
    (( QSPI_UBOOT_OFFS >= 0x400000 && QSPI_UBOOT_OFFS + $(stat -c %s "${UBOOT_ITB}") <= 0x1000000 )) || {
        echo "QSPI_UBOOT_OFFS ${QSPI_UBOOT_OFFS} does not fit u-boot.itb after the bitstream"; exit 1; }
    echo ">> bitstream + SPL, u-boot.itb at ${QSPI_UBOOT_OFFS}"
    PFG="${JIC%.jic}.pfg"
    NAME="$(basename "${JIC%.jic}")"
    # quartus_pfg takes raw files by extension (.bin/.rbf/.hex): the FIT
    # image goes in under a .bin name, as the GSRD does
    UBOOT_BIN="${JIC%.jic}_u-boot.bin"
    cp "${UBOOT_ITB}" "${UBOOT_BIN}"
    # after Intel's Agilex 5 GSRD (software/yocto_linux/scripts/uboot_only.pfg)
    cat > "${PFG}" << PFGEOF
<pfg version="1">
    <settings custom_db_dir="./" mode="ASX4"/>
    <output_files>
        <output_file name="${NAME}" directory="$(dirname "${JIC}")" type="JIC">
            <file_options/>
            <secondary_file type="MAP" name="${NAME}">
                <file_options/>
            </secondary_file>
            <flash_device_id>Flash_Device_1</flash_device_id>
        </output_file>
    </output_files>
    <bitstreams>
        <bitstream id="Bitstream_1">
            <path hps_path="${SPL}">${SOF}</path>
        </bitstream>
    </bitstreams>
    <raw_files>
        <raw_file bitswap="1" type="RBF" id="Raw_File_1">${UBOOT_BIN}</raw_file>
    </raw_files>
    <flash_devices>
        <flash_loader>${FLASH_LOADER}</flash_loader>
        <flash_device type="${DEVICE}" id="Flash_Device_1">
            <partition reserved="1" fixed_s_addr="1" s_addr="0x00000000" e_addr="0x001FFFFF" fixed_e_addr="1" id="BOOT_INFO" size="0"/>
            <partition reserved="0" fixed_s_addr="0" s_addr="auto" e_addr="auto" fixed_e_addr="0" id="P1" size="0"/>
            <partition reserved="0" fixed_s_addr="0" s_addr="${QSPI_UBOOT_OFFS}" e_addr="auto" fixed_e_addr="0" id="UBOOT" size="0"/>
        </flash_device>
    </flash_devices>
    <assignments>
        <assignment page="0" partition_id="P1">
            <bitstream_id>Bitstream_1</bitstream_id>
        </assignment>
        <assignment page="0" partition_id="UBOOT">
            <raw_file_id>Raw_File_1</raw_file_id>
        </assignment>
    </assignments>
</pfg>
PFGEOF
    quartus_pfg -c "${PFG}"
    echo "   flash map: ${JIC%.jic}.map"
fi

echo
echo "wrote ${JIC}"
echo
echo "program it (board on JTAG; on WSL2 forward the USB-Blaster first, see"
echo "../program.sh; name the cable as jtagconfig lists it):"
echo "    quartus_pgm -c \"DE25-Nano [...]\" -m jtag -o \"pvi;${JIC}\""
echo "then power-cycle (MSEL should already be set for QSPI/AS boot)."
