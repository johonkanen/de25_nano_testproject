#!/usr/bin/env bash
# Replace the toybox in-RAM rootfs with a real, persistent Alpine Linux
# rootfs on the SD card: repartitions the card (boot FAT32 + root ext4),
# extracts Alpine's aarch64 minirootfs, and configures networking/hostname/
# time-sync so it comes up fully unattended on every boot.
#
# Needs the SD card in a USB reader on THIS host (not in the board) -
# there's no fdisk/mkfs.ext4/tar on the board's minimal toybox rootfs, so
# this can't be done remotely. Run with sudo:
#   sudo ./linux/tools/setup_alpine_rootfs.sh
#
# Prerequisites already built via build_de25_nano_linux.sh (u-boot.itb,
# Image, the board's .dtb) - and the SD card must already have been
# through that flow at least once (so build_output/ exists).
#
# WHY REPARTITION FROM SCRATCH: build_de25_nano_linux.sh's sdcard.img is
# written with `mformat -i sdcard.img -F ::` - a raw "superfloppy" FAT32
# filesystem with NO MBR/partition table at all, spanning the whole image.
# `parted print` on a card written this way reports "Partition Table:
# loop" (a pseudo-table meaning "one filesystem, no real partitions") -
# you can't just add a second partition to that; the first sector has to
# become a real MBR, which means the existing boot partition has to be
# rebuilt too. This script does both in one pass and restores the boot
# files it deletes along the way.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEV="${DEV:-/dev/sde}"
BOOT_FILES="${BOOT_FILES:-${HERE}/build_output}"
BOOT_MNT="${BOOT_MNT:-/mnt/nano_boot}"
ROOT_MNT="${ROOT_MNT:-/mnt/nano_root}"
ALPINE_VERSION="${ALPINE_VERSION:-3.24.1}"
ALPINE_URL="https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/aarch64/alpine-minirootfs-${ALPINE_VERSION}-aarch64.tar.gz"
TARBALL="/tmp/alpine-minirootfs-${ALPINE_VERSION}-aarch64.tar.gz"

# The board's static IP/gateway - see linux/README.md's "Networking"
# section for why this is static (no DHCP client, WSL2 can't be reached
# from the LAN). Must match what's baked into the toybox initramfs too if
# you still use that boot path.
NANO_IP="${NANO_IP:-192.168.1.222}"
NANO_GW="${NANO_GW:-192.168.1.1}"

(( EUID == 0 )) || { echo "ERROR: run with sudo"; exit 1; }
[[ -b "${DEV}" ]] || { echo "ERROR: ${DEV} not found - is the SD card in the reader?"; exit 1; }
[[ -f "${BOOT_FILES}/u-boot.itb" ]] || { echo "ERROR: ${BOOT_FILES} missing boot files - run build_de25_nano_linux.sh first"; exit 1; }

[[ -f "${TARBALL}" ]] || { echo ">> fetching Alpine ${ALPINE_VERSION} minirootfs"; wget -q -O "${TARBALL}" "${ALPINE_URL}"; }

echo ">> current layout"
parted -s "${DEV}" print || true
umount "${DEV}"* 2>/dev/null || true

echo ">> writing a fresh MBR: partition 1 FAT32 (boot files, ~150MB),"
echo "   partition 2 ext4 (Alpine rootfs, rest of the disk)"
parted -s "${DEV}" mklabel msdos
parted -s "${DEV}" mkpart primary fat32 1MiB 151MiB
parted -s "${DEV}" mkpart primary ext4 151MiB 100%
parted -s "${DEV}" set 1 boot on
partprobe "${DEV}"
sleep 2
parted -s "${DEV}" print

echo ">> formatting"
mkfs.vfat -F 32 -n NANOBOOT "${DEV}1"
mkfs.ext4 -F -L nano-root "${DEV}2"

mkdir -p "${BOOT_MNT}" "${ROOT_MNT}"
mount "${DEV}1" "${BOOT_MNT}"
mount "${DEV}2" "${ROOT_MNT}"

echo ">> restoring boot files"
cp "${BOOT_FILES}/u-boot.itb" "${BOOT_FILES}/Image" \
   "${BOOT_FILES}/socfpga_agilex5_de25_nano.dtb" \
   "${BOOT_MNT}/"
# The toybox initramfs.cpio isn't needed for this boot path (root mounts
# straight from ext4, no initrd) - copied anyway as a rescue-boot fallback
# if it exists.
[[ -f "${BOOT_FILES}/initramfs.cpio" ]] && cp "${BOOT_FILES}/initramfs.cpio" "${BOOT_MNT}/"

echo ">> extracting Alpine minirootfs"
tar xzf "${TARBALL}" -C "${ROOT_MNT}" --numeric-owner

# init, networking, time sync, fstab, the web GUI, extlinux.conf - shared
# with make_sdcard_image.sh
NANO_IP="${NANO_IP}" NANO_GW="${NANO_GW}" \
    "${HERE}/tools/alpine_rootfs_config.sh" "${ROOT_MNT}" "${BOOT_MNT}"
echo "   web GUI update token (copy it to ~/.de25web_token on the host):"
echo "   $(cat "${ROOT_MNT}/opt/de25web/token")"

sync
umount "${BOOT_MNT}" "${ROOT_MNT}"

echo
echo "==================================================================="
echo "  done - ${DEV}1 = boot files (FAT32), ${DEV}2 = Alpine rootfs (ext4)"
echo
echo "  Put the card back in the board and power-cycle: U-Boot finds"
echo "  extlinux/extlinux.conf on the boot partition and boots straight to a"
echo "  login-free Alpine shell with networking and correct time."
echo "==================================================================="
