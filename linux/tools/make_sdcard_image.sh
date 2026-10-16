#!/usr/bin/env bash
# make_sdcard_image.sh - a complete DE25-Nano SD card as one image file,
# built without root (fakeroot + mkfs.ext4 -d + mtools, no loop mounts):
#
#   partition 1  FAT32, bootable: u-boot.itb, Image, the board's .dtb,
#                extlinux/extlinux.conf (U-Boot's distro boot finds it)
#   partition 2  ext4: Alpine aarch64 minirootfs, configured by
#                alpine_rootfs_config.sh (init, network, NTP, the web GUI)
#
# Output in linux/build_output/: sdcard_alpine.img and sdcard_alpine.img.gz
# (+ .sha256). Write it from U-Boot over TFTP (linux/tools/sd_recover.py),
# or with dd from a card reader:
#   gunzip -c linux/build_output/sdcard_alpine.img.gz | sudo dd of=/dev/sdX bs=4M conv=fsync
#
# Needs build_de25_nano_linux.sh's output (u-boot.itb, Image, .dtb).
# Env: IMG_MB (default 768 - the rootfs can be grown on the board later),
# BOOT_MB (128), NANO_IP, NANO_GW, ALPINE_VERSION.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${OUT:-${HERE}/build_output}"
IMG_MB="${IMG_MB:-768}"
BOOT_MB="${BOOT_MB:-128}"            # FAT32 with 512-byte clusters needs >= 33 MB
ALPINE_VERSION="${ALPINE_VERSION:-3.24.1}"
ALPINE_URL="https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/aarch64/alpine-minirootfs-${ALPINE_VERSION}-aarch64.tar.gz"
TARBALL="${OUT}/alpine-minirootfs-${ALPINE_VERSION}-aarch64.tar.gz"
DTB="socfpga_agilex5_de25_nano.dtb"
IMG="${OUT}/sdcard_alpine.img"
STAGE="${OUT}/sdimage"

for f in u-boot.itb Image "${DTB}"; do
    [[ -f "${OUT}/${f}" ]] || { echo "ERROR: ${OUT}/${f} missing - run build_de25_nano_linux.sh first"; exit 1; }
done
for t in fakeroot mkfs.ext4 sfdisk mformat mcopy mmd gzip dtc; do
    command -v "${t}" >/dev/null || { echo "ERROR: ${t} not found"; exit 1; }
done
[[ -f "${TARBALL}" ]] || { echo ">> fetching Alpine ${ALPINE_VERSION} minirootfs"; wget -q -O "${TARBALL}" "${ALPINE_URL}"; }

# layout, in 512-byte sectors: 1 MiB gap, the FAT partition, ext4 to the end
P1_START=2048
P1_SECTORS=$(( BOOT_MB * 2048 ))
P2_START=$(( P1_START + P1_SECTORS ))
P2_SECTORS=$(( IMG_MB * 2048 - P2_START ))

echo ">> ${IMG} (${IMG_MB} MB): boot ${BOOT_MB} MB FAT32 + root $(( P2_SECTORS / 2048 )) MB ext4"
rm -f "${IMG}" "${IMG}.gz"
truncate -s "${IMG_MB}M" "${IMG}"
sfdisk --quiet "${IMG}" << EOF
label: dos
start=${P1_START}, size=${P1_SECTORS}, type=c, bootable
start=${P2_START}, size=${P2_SECTORS}, type=83
EOF

echo ">> boot partition"
rm -rf "${STAGE}"
mkdir -p "${STAGE}/boot"
mformat -i "${IMG}@@$(( P1_START * 512 ))" -F -c 1 -T "${P1_SECTORS}" -h 64 -s 32 -v NANOBOOT ::
mcopy -i "${IMG}@@$(( P1_START * 512 ))" "${OUT}/u-boot.itb" "${OUT}/Image" "${OUT}/${DTB}" ::
# an HPS-first build's FPGA core (make_jic.sh): U-Boot's preboot loads it
# from here before anything touches the fabric
if [[ -f "${OUT}/de25_nano.core.rbf" ]]; then
    mcopy -i "${IMG}@@$(( P1_START * 512 ))" "${OUT}/de25_nano.core.rbf" ::
    echo "   + de25_nano.core.rbf (HPS-first FPGA core)"
fi

echo ">> root partition (Alpine ${ALPINE_VERSION})"
# one fakeroot session: extraction, configuration and mkfs see the same
# (root) ownership, so the image has root-owned files without real root
NANO_IP="${NANO_IP:-192.168.1.222}" NANO_GW="${NANO_GW:-192.168.1.1}" \
fakeroot -- bash -euo pipefail -c '
    mkdir -p "$1/root"
    tar xzf "$2" -C "$1/root" --numeric-owner
    "$3/tools/alpine_rootfs_config.sh" "$1/root" "$1/boot"
    # HPS-first images: the core and the reload tool, for fpga-reload
    # (docs/hps_first.md)
    if [ -f "$7/de25_nano.core.rbf" ]; then
        install -D -m 644 "$7/de25_nano.core.rbf" "$1/root/lib/firmware/de25_nano.core.rbf"
        dtc -q -@ -I dts -O dtb -o "$1/root/lib/firmware/de25_nano_core_reload.dtbo" \
            "$3/tools/fpga_reload/core_reload.dts"
        install -D -m 755 "$3/tools/fpga_reload/fpga-reload" "$1/root/usr/sbin/fpga-reload"
        echo "   + /lib/firmware/de25_nano.core.rbf, de25_nano_core_reload.dtbo, /usr/sbin/fpga-reload"
    fi
    mkfs.ext4 -q -F -L nano-root -E offset=$(( $4 * 512 )) -d "$1/root" "$5" "$(( $6 / 2 ))k"
' _ "${STAGE}" "${TARBALL}" "${HERE}" "${P2_START}" "${IMG}" "${P2_SECTORS}" "${OUT}"

mmd   -i "${IMG}@@$(( P1_START * 512 ))" ::extlinux
mcopy -i "${IMG}@@$(( P1_START * 512 ))" "${STAGE}/boot/extlinux/extlinux.conf" ::extlinux/

TOKEN="$(cat "${STAGE}/root/opt/de25web/token")"
( umask 077; echo "${TOKEN}" > "${OUT}/de25web_token" )
rm -rf "${STAGE}"

echo ">> compressing"
gzip -k -9 "${IMG}"
( cd "${OUT}" && sha256sum "$(basename "${IMG}.gz")" > "$(basename "${IMG}.gz").sha256" )

echo
echo "==================================================================="
echo "  ${IMG}.gz  ($(du -h "${IMG}.gz" | cut -f1))"
echo "  web GUI update token: ${OUT}/de25web_token - copy it to"
echo "  ~/.de25web_token for deploy_web.py once this card is in use"
echo
echo "  write it: python3 linux/tools/sd_recover.py   (U-Boot + TFTP)"
echo "        or: gunzip -c ${IMG}.gz | sudo dd of=/dev/sdX bs=4M conv=fsync"
echo "==================================================================="
