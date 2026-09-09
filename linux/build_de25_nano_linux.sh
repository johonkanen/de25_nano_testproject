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
#   terasic/arm-trusted-firmware  @ de25-nano-v2.12.0
#   terasic/u-boot-socfpga        @ de25-nano-v2025.01  (defconfig socfpga_agilex5_de25_nano_defconfig)
#   terasic/linux-socfpga         @ de25-nano-6.12.11-lts (in-tree DTS: socfpga_agilex5_de25_nano.dts)
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

ATF_REPO="https://github.com/terasic/arm-trusted-firmware"
ATF_BRANCH="de25-nano-v2.12.0"
UBOOT_REPO="https://github.com/terasic/u-boot-socfpga"
UBOOT_BRANCH="de25-nano-v2025.01"
UBOOT_DEFCONFIG="socfpga_agilex5_de25_nano_defconfig"
LINUX_REPO="https://github.com/terasic/linux-socfpga"
LINUX_BRANCH="de25-nano-6.12.11-lts"
LINUX_DTB="socfpga_agilex5_de25_nano.dtb"
TOYBOX_REPO="https://github.com/landley/toybox.git"

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

# ---- ARM Trusted Firmware (Terasic fork) --------------------------------
if [[ ! -d arm-trusted-firmware ]]; then
    git clone --depth 1 -b "${ATF_BRANCH}" "${ATF_REPO}" arm-trusted-firmware
fi
pushd arm-trusted-firmware >/dev/null
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
    make PLAT=agilex5 clean >/dev/null
    make -j"${JOBS}" CROSS_COMPILE="${CROSS_PREFIX}" PLAT=agilex5 ENABLE_LTO=0 bl31
    cp build/agilex5/release/bl31.bin "${OUT}/bl31.bin"
popd >/dev/null

# ---- U-Boot (Terasic fork, board-specific defconfig) --------------------
if [[ ! -d u-boot-socfpga ]]; then
    git clone --depth 1 -b "${UBOOT_BRANCH}" "${UBOOT_REPO}" u-boot-socfpga
fi
pushd u-boot-socfpga >/dev/null
    git checkout -- . 2>/dev/null || true
    ln -sf "${OUT}/bl31.bin" bl31.bin
    make mrproper
    make "${UBOOT_DEFCONFIG}"
    make -j"${JOBS}"
    mkdir -p "${OUT}/spl"
    cp u-boot.itb              "${OUT}/u-boot.itb"
    cp spl/u-boot-spl-dtb.hex  "${OUT}/spl/u-boot-spl-dtb.hex"
popd >/dev/null

# ---- Linux kernel (Terasic fork, in-tree board DTS) ----------------------
if [[ ! -d linux-socfpga ]]; then
    git clone --depth 1 -b "${LINUX_BRANCH}" "${LINUX_REPO}" linux-socfpga
fi
pushd linux-socfpga >/dev/null
    git checkout -- . 2>/dev/null || true
    make defconfig
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
