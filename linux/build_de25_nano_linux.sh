#!/usr/bin/env bash
# ============================================================================
# DE25-Nano Linux build: SPL (QSPI) -> ATF BL31 + U-Boot proper (SD) ->
# Linux kernel + initramfs (SD).
#
# Unlike de25_std_testproject/linux/ (which had to detour through upstream
# altera-fpga forks before finding Terasic's own board-specific u-boot fork
# necessary for working SD access), this goes straight to Terasic's own
# complete stack - they publish a dedicated branch on all three repos for
# this exact board:
#   altera-fpga/arm-trusted-firmware @ socfpga_v2.14.1  (SOCFPGA_UART_CONFIG=1)
#   altera-fpga/u-boot-socfpga    @ socfpga_v2026.04    (defconfig socfpga_agilex5_de25_nano_defconfig)
#   altera-fpga/linux-socfpga     @ socfpga-6.18.20-lts (in-tree DTS: socfpga_agilex5_de25_nano.dts)
# This combination booted to a live root shell on real hardware first try
# (aside from one already-known ATF bug, patched below).
#
# REQUIREMENTS: Linux host, internet, ~15 GB free, and:
#   git wget xz-utils bc bison flex libssl-dev python3 mtools dosfstools
# ============================================================================
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT="${HERE}/build_output"
JOBS="$(nproc)"

# ATF, U-Boot and the kernel all from Altera upstream (2026-10-16). Each
# Terasic de25-nano branch was Altera's spring-2025 release + one board
# commit; upstream now carries the DE25-Nano itself.
ATF_REPO="https://github.com/altera-fpga/arm-trusted-firmware"
ATF_BRANCH="socfpga_v2.14.1"
ATF_DIR="atf-altera"
# U-Boot from Altera upstream: socfpga_v2026.04 carries the DE25-Nano
# itself (board support added 2026-04-23), with the QSPI controller enabled
# and U-Boot proper in QSPI at 10 MB - Terasic's de25-nano-v2025.01 had QSPI
# disabled, and with it patched on, its SPL corrupted its own boot list
# while probing the flash (2026-10-16).
UBOOT_REPO="https://github.com/altera-fpga/u-boot-socfpga"
UBOOT_BRANCH="socfpga_v2026.04"
UBOOT_DIR="u-boot-altera"
UBOOT_DEFCONFIG="socfpga_agilex5_de25_nano_defconfig"
LINUX_REPO="https://github.com/altera-fpga/linux-socfpga"
LINUX_BRANCH="socfpga-6.18.20-lts"
LINUX_DIR="linux-altera"
LINUX_DTB="socfpga_agilex5_de25_nano.dtb"
TOYBOX_REPO="https://github.com/landley/toybox.git"
# where U-Boot proper sits in the 16 MB QSPI flash - upstream's
# CONFIG_SYS_SPI_U_BOOT_OFFS for this board, checked below; make_jic.sh
# uses the same default
QSPI_UBOOT_OFFS="${QSPI_UBOOT_OFFS:-0x00A00000}"
# where an HPS-first image's FPGA core sits in QSPI (U-Boot's preboot
# loads it from there when the SD card has none) - make_jic.sh uses the
# same default
QSPI_CORE_OFFS="${QSPI_CORE_OFFS:-0x00C00000}"

# ARM GNU aarch64-linux toolchain (has the LTO plugin ATF's release build
# needs). Point CROSS_TOOLCHAIN at an existing install (dir with
# bin/aarch64-none-linux-gnu-gcc) to skip the download.
TOOLCHAIN_URL="https://developer.arm.com/-/media/Files/downloads/gnu/11.2-2022.02/binrel/gcc-arm-11.2-2022.02-x86_64-aarch64-none-linux-gnu.tar.xz"
TOOLCHAIN_DIR="gcc-arm-11.2-2022.02-x86_64-aarch64-none-linux-gnu"
CROSS_PREFIX="aarch64-none-linux-gnu-"

[[ -n "${MTOOLS_BIN:-}" ]] && export PATH="${MTOOLS_BIN}:${PATH}"
command -v mformat >/dev/null || { echo "ERROR: mtools (mformat/mcopy) not found; apt install mtools, or set MTOOLS_BIN"; exit 1; }

mkdir -p "${OUT}"
cd "${OUT}"
export ARCH=arm64

# ---- toolchain -----------------------------------------------------------
if [[ -n "${CROSS_TOOLCHAIN:-}" && -x "${CROSS_TOOLCHAIN}/bin/${CROSS_PREFIX}gcc" ]]; then
    TC_BIN="${CROSS_TOOLCHAIN}/bin"
else
    if [[ ! -x "${TOOLCHAIN_DIR}/bin/${CROSS_PREFIX}gcc" ]]; then
        echo ">> fetching toolchain"
        wget -q --show-progress -O tc.tar.xz "${TOOLCHAIN_URL}"
        tar -xf tc.tar.xz && rm tc.tar.xz
    fi
    TC_BIN="${OUT}/${TOOLCHAIN_DIR}/bin"
fi
export PATH="${TC_BIN}:${PATH}"
export CROSS_COMPILE="${CROSS_PREFIX}"
echo ">> toolchain: $(command -v ${CROSS_PREFIX}gcc)  ($(${CROSS_PREFIX}gcc -dumpversion))"

# toybox's build (both its own Makefile's implicit CC=cc default, and
# mkroot.sh's own hardcoded `command -v "$CROSS_COMPILE"cc` check) expects
# a "...-cc" binary; this toolchain only ships "...-gcc". Symlink it in
# (once; -x check makes this idempotent across re-runs) rather than fight
# CC= overrides per invocation - found running this script end to end,
# 2026-09-10 (toybox failed with "No aarch64-none-linux-gnu-cc found"
# despite CROSS_COMPILE/PATH both being set correctly).
[[ -x "${TC_BIN}/${CROSS_PREFIX}cc" ]] || ln -sf "${CROSS_PREFIX}gcc" "${TC_BIN}/${CROSS_PREFIX}cc"

# ---- ARM Trusted Firmware (Altera upstream) ------------------------------
if [[ ! -d "${ATF_DIR}" ]]; then
    git clone --depth 1 -b "${ATF_BRANCH}" "${ATF_REPO}" "${ATF_DIR}"
fi
pushd "${ATF_DIR}" >/dev/null
    git checkout -- . 2>/dev/null || true
    # Known upstream bug (also hit in de25_std_testproject and in the
    # freertos-socfpga QSPI work): config_ddr_size is hardcoded to 0x80000000
    # (2GB), which hangs BL2/SPL's DDR-size sanity check on any board whose
    # real DDR is smaller than that (this board's LPDDR4 is 1GB). Use the
    # IOSSM-detected size directly instead.
    sed -i 's/config_ddr_size = 0x80000000;/config_ddr_size = hw_ddr_size;/' \
        plat/intel/soc/agilex5/soc/agilex5_ddr.c
    grep -q 'config_ddr_size = hw_ddr_size;' plat/intel/soc/agilex5/soc/agilex5_ddr.c || {
        echo "ERROR: DDR-size patch didn't apply - upstream file changed, check by hand"; exit 1; }
    # SOCFPGA_UART_CONFIG=1: console on UART1, this board's (Terasic's
    # fork hard-patched platform_def.h for the same thing)
    make PLAT=agilex5 clean >/dev/null
    make -j"${JOBS}" CROSS_COMPILE="${CROSS_PREFIX}" PLAT=agilex5 ENABLE_LTO=0 SOCFPGA_UART_CONFIG=1 bl31
    cp build/agilex5/release/bl31.bin "${OUT}/bl31.bin"
popd >/dev/null

# ---- U-Boot (Altera upstream, board defconfig) ---------------------------
if [[ ! -d "${UBOOT_DIR}" ]]; then
    git clone --depth 1 -b "${UBOOT_BRANCH}" "${UBOOT_REPO}" "${UBOOT_DIR}"
fi
pushd "${UBOOT_DIR}" >/dev/null
    git checkout -- . 2>/dev/null || true
    # Terasic's one DDR change for this board (their de25-nano-v2025.01
    # commit d0f8813, the U-Boot that has booted this board): single-port
    # EMIF, not the dual-port bit from the hand-off data.
    sed -i 's|^\(\s*\)plat->dualport = FIELD_GET(IO96B0_DUAL_PORT_MASK, handoff_table\[PORT_EMIF_CONFIG_OFFSET\]);|\1plat->dualport = 0;  /* DE25-Nano: single port (Terasic) */|' \
        drivers/ddr/altera/sdram_agilex5.c
    grep -q 'plat->dualport = 0;  /\* DE25-Nano' drivers/ddr/altera/sdram_agilex5.c || {
        echo "ERROR: the dual-port DDR patch didn't apply - sdram_agilex5.c changed, check by hand"; exit 1; }
    ln -sf "${OUT}/bl31.bin" bl31.bin
    make mrproper
    make "${UBOOT_DEFCONFIG}"
    # Release the HPS<->FPGA bridges before booting Linux: upstream U-Boot
    # leaves them all in reset (rstmgr brgmodrst = 0xf), and the first
    # LWH2F access from Linux then dies with SIGBUS (the web GUI's register
    # reads). Terasic's U-Boot released them; upstream needs `bridge enable`.
    scripts/config --set-str CONFIG_BOOTCOMMAND "bridge enable; run distro_bootcmd"
    make olddefconfig
    grep -q '^CONFIG_BOOTCOMMAND="bridge enable; run distro_bootcmd"$' .config || {
        echo "ERROR: CONFIG_BOOTCOMMAND not set"; exit 1; }
    # HPS-first images (build_de25_nano_uart.tcl, HPS_FIRST=1): the SDM
    # leaves the FPGA core unconfigured, so load it before anything else -
    # preboot runs before the autoboot prompt. Only when the fabric isn't
    # configured already (FPGA-first images, a JTAG .sof load): sysmgr
    # FPGA_CONFIG (0x10d120dc) reads 3 once configured and in user mode.
    # From the SD card's FAT partition, else from the QSPI copy make_jic.sh
    # writes at QSPI_CORE_OFFS: a 4 KB text header "core_size=0x..." for
    # `env import`, the core right after it. The console is silent until
    # the core is in (HPS UART1 runs through the fabric). A card core that
    # reads but does not load (damaged, e.g. by a power cut while
    # linux/tools/deploy_fpga.py wrote it) falls back to the QSPI copy too.
    scripts/config --enable CONFIG_USE_PREBOOT
    scripts/config --set-str CONFIG_PREBOOT "if itest.l *0x10d120dc != 3; then if load mmc 0:1 \${loadaddr} de25_nano.core.rbf && fpga load 0 \${loadaddr} \${filesize}; then echo core from SD; else sf probe && sf read \${loadaddr} $(printf '%#x' "${QSPI_CORE_OFFS}") 0x1000 && env import -t \${loadaddr} && sf read \${loadaddr} $(printf '%#x' $(( QSPI_CORE_OFFS + 0x1000 ))) \${core_size} && fpga load 0 \${loadaddr} \${core_size} && echo core from QSPI; fi; fi"
    make olddefconfig
    grep -q '^CONFIG_PREBOOT="if itest.l \*0x10d120dc != 3; then' .config || {
        echo "ERROR: CONFIG_PREBOOT not set"; exit 1; }
    # U-Boot proper from QSPI as well as from the SD card, so a blank or
    # broken card still reaches a U-Boot prompt (linux/tools/sd_recover.py).
    # make_jic.sh puts u-boot.itb at QSPI_UBOOT_OFFS in the .jic.
    got="$(sed -n 's/^CONFIG_SYS_SPI_U_BOOT_OFFS=//p' .config)"
    [[ -n "${got}" ]] && (( got == QSPI_UBOOT_OFFS )) || {
        echo "ERROR: CONFIG_SYS_SPI_U_BOOT_OFFS is '${got}', make_jic.sh expects ${QSPI_UBOOT_OFFS}"; exit 1; }
    make -j"${JOBS}"
    mkdir -p "${OUT}/spl"
    cp u-boot.itb              "${OUT}/u-boot.itb"
    cp spl/u-boot-spl-dtb.hex  "${OUT}/spl/u-boot-spl-dtb.hex"
popd >/dev/null

# ---- Linux kernel (Altera upstream, in-tree DE25-Nano DTS) ---------------
if [[ ! -d "${LINUX_DIR}" ]]; then
    git clone --depth 1 -b "${LINUX_BRANCH}" "${LINUX_REPO}" "${LINUX_DIR}"
fi
pushd "${LINUX_DIR}" >/dev/null
    git checkout -- . 2>/dev/null || true
    make defconfig
    # The SoC's temperature/voltage sensors (SDM mailbox, the dtsi's
    # intel,soc64-hwmon node) for the web GUI: defconfig has the driver as a
    # module, and the rootfs carries no modules - build it in.
    scripts/config --enable CONFIG_SENSORS_SOC64
    make olddefconfig
    grep -q '^CONFIG_SENSORS_SOC64=y$' .config || { echo "ERROR: CONFIG_SENSORS_SOC64 not built in"; exit 1; }
    # FPGA reload from a running Linux (HPS-first images): the FPGA manager
    # (SDM mailbox), bridges and the fpga-region driver, built in for the
    # same reason; an overlay on /fpga-region with firmware-name then loads
    # a .core.rbf from /lib/firmware (docs/hps_first_boot_research.md)
    for c in FPGA_MGR_STRATIX10_SOC FPGA_BRIDGE FPGA_REGION OF_FPGA_REGION; do
        scripts/config --enable "CONFIG_${c}"
    done
    make olddefconfig
    for c in FPGA_MGR_STRATIX10_SOC FPGA_BRIDGE FPGA_REGION OF_FPGA_REGION OF_OVERLAY OF_CONFIGFS; do
        grep -q "^CONFIG_${c}=y$" .config || { echo "ERROR: CONFIG_${c} not built in"; exit 1; }
    done
    make -j"${JOBS}" Image "intel/${LINUX_DTB}"
    cp arch/arm64/boot/Image                       "${OUT}/Image"
    cp "arch/arm64/boot/dts/intel/${LINUX_DTB}"     "${OUT}/${LINUX_DTB}"
popd >/dev/null

# ---- toybox initramfs (architecture-generic - no board-specific content) -
if [[ ! -d toybox ]]; then git clone --depth 1 "${TOYBOX_REPO}" toybox; fi
pushd toybox >/dev/null
    make clean || true
    make defconfig
    mkroot/mkroot.sh
    gzip -dc root/aarch64/initramfs.cpio.gz > "${OUT}/initramfs.cpio"
popd >/dev/null

# mkroot's stock /init sets up networking for QEMU (ifconfig eth0 10.0.2.15,
# gw 10.0.2.2) - useless on real hardware, and there's no DHCP client to
# fall back on. Patch in a static IP on the real LAN instead (see
# linux/README.md's "Networking" section for why this has to be static and
# how to pick the address). Doesn't touch anything else in the archive.
rm -rf "${OUT}/initramfs_patch"
mkdir -p "${OUT}/initramfs_patch"
pushd "${OUT}/initramfs_patch" >/dev/null
    cpio -idm --no-absolute-filenames < "${OUT}/initramfs.cpio" >/dev/null 2>&1
    sed -i \
        -e 's/# Setup networking for QEMU (needs \/proc)/# Networking for the real DE25-Nano LAN (see linux\/README.md)/' \
        -e 's/ifconfig eth0 10\.0\.2\.15/ifconfig eth0 192.168.1.222 netmask 255.255.255.0 up/' \
        -e '/route add default gw 10\.0\.2\.2/c\  route add default gw 192.168.1.1' \
        -e '/timeout 2 sntp -sq 10\.0\.2\.2/d' \
        init
    grep -q '192.168.1.222' init || { echo "ERROR: /init network patch didn't apply - mkroot's init changed, check by hand"; exit 1; }
    find . | cpio -o -H newc -R 0:0 > "${OUT}/initramfs.cpio"
popd >/dev/null
rm -rf "${OUT}/initramfs_patch"

# ---- SD card image (FAT32: u-boot.itb + Image + dtb + initramfs) --------
cd "${OUT}"
rm -f sdcard.img
dd if=/dev/zero of=sdcard.img bs=1M count=96 status=none
mformat -i sdcard.img -F ::
mcopy -i sdcard.img u-boot.itb Image "${LINUX_DTB}" initramfs.cpio ::

echo
echo "==================================================================="
echo "  build_output/ ready: sdcard.img  Image  ${LINUX_DTB}"
echo "                       u-boot.itb  initramfs.cpio  bl31.bin"
echo "                       spl/u-boot-spl-dtb.hex"
echo
echo "  next: ./linux/make_jic.sh   # SPL + our QSPI_OWNERSHIP-fixed .sof -> de25_nano.jic"
echo "        write sdcard.img to the SD card, flash the .jic, power-cycle."
echo "        See linux/README.md for the exact boot commands."
echo "==================================================================="
