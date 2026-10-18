#!/usr/bin/env bash
# Combine the FPGA bitstream, the U-Boot SPL and U-Boot proper into a QSPI
# flash image (.jic) for the DE25-Nano. Run linux/build_de25_nano_linux.sh
# first (SPL, u-boot.itb) and build output_files/de25_nano_uart.sof
# (quartus_syn/fit/asm) at the repo root first.
#
#   ./linux/make_jic.sh
#
# QSPI layout (16 MB MT25QU128), RSU=1 (default):
#   0x000000  boot info + decision firmware (to 0x20FFFF)
#   0x220000  FACTORY_IMAGE: phase 1 (HPS-first: HPS I/O, DDR I/O;
#             FPGA-first: the whole bitstream) + SPL, 1 MB
#   0x320000  SPT0, SPT1, CPB0, CPB1 (32 KB each): slot and priority tables
#   0x400000  P1: application image, 1 MB (same build at first)
#   0x500000  SSBL.FACTORY_IM, 0x600000 SSBL.P1: each image's u-boot.itb
#             (the SPL's RSU multiboot loads the one of the image running)
# RSU=0: boot info + the one image from 0x000000/0x200000. Both:
#   0xA00000  u-boot.itb (QSPI_UBOOT_OFFS, the SPL's CONFIG_SYS_SPI_U_BOOT_OFFS)
#   0xC00000  HPS-first only: the FPGA core (QSPI_CORE_OFFS) - docs/hps_first.md
# The SPL loads u-boot.itb from the SD card's FAT partition if it can, else
# this QSPI copy - so a blank or broken card still reaches a U-Boot prompt,
# from which linux/tools/sd_recover.py rewrites the card over TFTP.
# Kernel, dtb and rootfs always come from the SD card.
#
# The .sof comes from build_de25_nano_uart.tcl: QSPI_OWNERSHIP HPS (the SPL
# and U-Boot read QSPI) and HPS_INITIALIZATION "HPS FIRST" by default
# (FPGA_FIRST=1: "AFTER INIT_DONE") - docs/hps_first.md. LWH2F needs U-Boot's
# `bridge enable` before Linux in either mode.
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
QSPI_CORE_OFFS="${QSPI_CORE_OFFS:-0x00C00000}"
# RSU=1 (default with u-boot.itb): the remote system update layout - factory
# image + application slot P1 + SPT/CPB tables (below); RSU=0: the plain
# layout (one image at 0x200000). FACTORY_SOF= puts another build in the
# factory slot (default: the same .sof as P1).
RSU="${RSU:-1}"
CORE_RBF="${CORE_RBF:-${HERE}/build_output/de25_nano.core.rbf}"
MANIFEST="${CORE_RBF%.rbf}.json"

# DE25-Nano: Micron MT25QU128 QSPI flash (128Mb/16MB - same part as the
# DE25-Standard, confirmed via Terasic's own sof_to_jic.bat), device
# A5EB013BB23BCS (the full string WITH the CS suffix - the abbreviated
# "A5EB013BB23B" Terasic's own script uses resolves to a different JTAG
# IDCODE than this board's actual one)
DEVICE="${DEVICE:-MT25QU128}"
FLASH_LOADER="${FLASH_LOADER:-A5EB013BB23BCS}"

[[ -f "${SOF}" ]] || { echo "missing ${SOF} - build the FPGA first"; exit 1; }
[[ -f "${SPL}" ]] || { echo "missing ${SPL} - run build_de25_nano_linux.sh first"; exit 1; }

# HPS-first .sof (build_de25_nano_uart.tcl, HPS_FIRST=1): the .jic gets
# only the first stage (SDM firmware, HPS + DDR I/O, SPL); the FPGA core is
# a separate .core.rbf that U-Boot loads (preboot, build_de25_nano_linux.sh)
# from the SD card or from its QSPI copy at QSPI_CORE_OFFS. quartus_pfg
# refuses hps_core_only on an AFTER INIT_DONE .sof - that is the test.
HPS_FIRST=0
rm -f "${CORE_RBF}" "${MANIFEST}"
if quartus_pfg -c "${SOF}" "${CORE_RBF}" -o hps_core_only=ON > "${JIC%.jic}_core.log" 2>&1 && [[ -s "${CORE_RBF}" ]]; then
    HPS_FIRST=1
    echo ">> HPS-first .sof: core in ${CORE_RBF} ($(stat -c %s "${CORE_RBF}") bytes) - copy it to the SD card's FAT partition"
    # the core's manifest (fpga_access.py checks it before a load over the
    # network, linux/tools/deploy_fpga.py sends it along):
    #   build_id          register 19 of this build (build_id_pkg.vhd)
    #   periphery_sha256  what the first stage fixes and a core must match: the
    #                     fitter's pin table (every pin's location, direction and
    #                     I/O standard, the HPS's too; it names the Quartus
    #                     version and the device) and the HPS and EMIF IP. The
    #                     phase-1 bitstream itself is no key - two builds of one
    #                     periphery differ in it (per-build hashes), and the SDM
    #                     loads either's core (tested 2026-10-17).
    python3 - "${CORE_RBF}" "${MANIFEST}" "${HERE}/.." "${SOF}" << 'PYMAN'
import hashlib, json, os, re, subprocess, sys, time
core_path, out, top, sof = sys.argv[1:]
core = open(core_path, "rb").read()
pkg = os.path.join(top, "build_id_pkg.vhd")
m = re.search(r'build_id\s*:.*x"([0-9a-fA-F]{8})"', open(pkg).read())
if not m:
    sys.exit(f"no build id in {pkg}")
if os.path.getmtime(pkg) > os.path.getmtime(sof):
    sys.exit(f"{pkg} is newer than {sof} - rebuild (quartus_syn..quartus_asm) first")
h = hashlib.sha256()
pins = os.path.join(os.path.dirname(sof), os.path.basename(sof).replace(".sof", ".pin"))
for line in open(pins):
    if line.strip() and not line.lstrip().startswith("--"):
        h.update(line.rstrip().encode() + b"\n")
for ip in ("hps/ip/hps_subsys/agilex_hps.ip", "hps/ip/qsys_top/emif_io96b_hps.ip"):
    h.update(hashlib.sha256(open(os.path.join(top, ip), "rb").read()).digest())
try:
    git = subprocess.check_output(["git", "describe", "--always", "--dirty"], cwd=top,
                                  text=True, stderr=subprocess.DEVNULL).strip()
except (OSError, subprocess.CalledProcessError):
    git = ""
build_id = int(m.group(1), 16)
manifest = {"format": 1, "core_size": len(core), "core_sha256": hashlib.sha256(core).hexdigest(),
            "build_id": build_id, "built": time.strftime("%FT%TZ", time.gmtime(build_id)),
            "periphery_sha256": h.hexdigest(), "git": git}
with open(out, "w") as f:
    json.dump(manifest, f, indent=1)
    f.write("\n")
print(f">> manifest {out}: build {build_id}, periphery {h.hexdigest()[:12]}, git {git}")
PYMAN
else
    rm -f "${CORE_RBF}"
    echo ">> FPGA-first .sof (AFTER INIT_DONE): the core is in the .jic"
fi

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
    CORE_RAW="" CORE_PART="" CORE_ASSIGN=""
    if (( HPS_FIRST )); then
        # the QSPI copy of the core: a 4 KB "core_size=0x..." text header
        # (U-Boot's preboot `env import`s it), then the core
        CORE_BIN="${JIC%.jic}_core.bin"
        core_size=$(stat -c %s "${CORE_RBF}")
        (( QSPI_CORE_OFFS >= QSPI_UBOOT_OFFS + $(stat -c %s "${UBOOT_ITB}") && \
           QSPI_CORE_OFFS + 0x1000 + core_size <= 0x1000000 )) || {
            echo "QSPI_CORE_OFFS ${QSPI_CORE_OFFS} does not fit the core (${core_size} bytes) after U-Boot"; exit 1; }
        python3 - "${CORE_RBF}" "${CORE_BIN}" << 'PYCORE'
import sys
core = open(sys.argv[1], "rb").read()
head = ("core_size=%#x\n" % len(core)).encode().ljust(0x1000, b"\0")
open(sys.argv[2], "wb").write(head + core)
PYCORE
        CORE_RAW="        <raw_file bitswap=\"1\" type=\"RBF\" id=\"Raw_File_2\">${CORE_BIN}</raw_file>"
        CORE_PART="            <partition reserved=\"0\" fixed_s_addr=\"0\" s_addr=\"${QSPI_CORE_OFFS}\" e_addr=\"auto\" fixed_e_addr=\"0\" id=\"CORE\" size=\"0\"/>"
        CORE_ASSIGN="        <assignment page=\"0\" partition_id=\"CORE\">
            <raw_file_id>Raw_File_2</raw_file_id>
        </assignment>"
        echo ">> QSPI core copy at ${QSPI_CORE_OFFS} (header + ${core_size} bytes)"
    fi
    if (( RSU )); then
        # remote system update layout (docs/remote_system_update_plan.md, R1):
        # the SDM boots the highest-priority application slot that loads (P1),
        # else the factory image; the SPT/CPB tables say where they are. The
        # decision firmware makes BOOT_INFO 0x210000 long. Fixed addresses
        # throughout - with "auto" quartus_pfg 26.1.1 fails (internal error).
        # P1 holds the same build as the factory image until an update
        # writes it from Linux.
        BITSTREAMS="        <bitstream id=\"Factory\">
            <path hps_path=\"${SPL}\">${FACTORY_SOF:-${SOF}}</path>
        </bitstream>
        <bitstream id=\"App1\">
            <path hps_path=\"${SPL}\">${SOF}</path>
        </bitstream>"
        part() { printf '            <partition reserved="%s" fixed_s_addr="1" s_addr="%#010x" e_addr="%#010x" fixed_e_addr="1" id="%s" size="0"/>\n' "$4" "$2" "$3" "$1"; }
        PARTS="$(part BOOT_INFO 0x000000 0x20FFFF 1
                 part FACTORY_IMAGE 0x220000 0x31FFFF 0
                 part SPT0 0x320000 0x327FFF 1
                 part SPT1 0x328000 0x32FFFF 1
                 part CPB0 0x330000 0x337FFF 1
                 part CPB1 0x338000 0x33FFFF 1
                 part P1 0x400000 0x4FFFFF 0
                 part SSBL.FACTORY_IM 0x500000 0x5FFFFF 0
                 part SSBL.P1 0x600000 0x6FFFFF 0
                 part UBOOT $(( QSPI_UBOOT_OFFS )) $(( QSPI_UBOOT_OFFS + 0xFFFFF )) 0)"
        (( HPS_FIRST )) && PARTS="${PARTS}
$(part CORE $(( QSPI_CORE_OFFS )) $(( QSPI_CORE_OFFS + 0x10FFFF )) 0)"
        CORE_PART=""
        IMAGE_ASSIGN="        <assignment page=\"0\" partition_id=\"FACTORY_IMAGE\">
            <bitstream_id>Factory</bitstream_id>
        </assignment>
        <assignment page=\"1\" partition_id=\"P1\">
            <bitstream_id>App1</bitstream_id>
        </assignment>
        <assignment page=\"0\" partition_id=\"SSBL.FACTORY_IM\">
            <raw_file_id>Raw_File_1</raw_file_id>
        </assignment>
        <assignment page=\"0\" partition_id=\"SSBL.P1\">
            <raw_file_id>Raw_File_1</raw_file_id>
        </assignment>"
        echo ">> RSU layout: factory image 0x220000, P1 0x400000, SPT/CPB 0x320000,"
        echo "   their U-Boots SSBL.FACTORY_IM 0x500000, SSBL.P1 0x600000"
    else
        BITSTREAMS="        <bitstream id=\"Bitstream_1\">
            <path hps_path=\"${SPL}\">${SOF}</path>
        </bitstream>"
        PARTS="            <partition reserved=\"1\" fixed_s_addr=\"1\" s_addr=\"0x00000000\" e_addr=\"0x001FFFFF\" fixed_e_addr=\"1\" id=\"BOOT_INFO\" size=\"0\"/>
            <partition reserved=\"0\" fixed_s_addr=\"0\" s_addr=\"auto\" e_addr=\"auto\" fixed_e_addr=\"0\" id=\"P1\" size=\"0\"/>
            <partition reserved=\"0\" fixed_s_addr=\"0\" s_addr=\"${QSPI_UBOOT_OFFS}\" e_addr=\"auto\" fixed_e_addr=\"0\" id=\"UBOOT\" size=\"0\"/>"
        IMAGE_ASSIGN="        <assignment page=\"0\" partition_id=\"P1\">
            <bitstream_id>Bitstream_1</bitstream_id>
        </assignment>"
    fi
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
${BITSTREAMS}
    </bitstreams>
    <raw_files>
        <raw_file bitswap="1" type="RBF" id="Raw_File_1">${UBOOT_BIN}</raw_file>
${CORE_RAW}
    </raw_files>
    <flash_devices>
        <flash_loader>${FLASH_LOADER}</flash_loader>
        <flash_device type="${DEVICE}" id="Flash_Device_1">
${PARTS}
${CORE_PART}
        </flash_device>
    </flash_devices>
    <assignments>
${IMAGE_ASSIGN}
        <assignment page="0" partition_id="UBOOT">
            <raw_file_id>Raw_File_1</raw_file_id>
        </assignment>
${CORE_ASSIGN}
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
