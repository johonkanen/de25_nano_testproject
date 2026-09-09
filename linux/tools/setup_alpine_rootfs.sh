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

echo ">> configuring inittab, networking, hostname, time sync"
cat > "${ROOT_MNT}/etc/inittab" << EOF
::sysinit:/bin/mount -t proc proc /proc
::sysinit:/bin/mount -t sysfs sysfs /sys
::sysinit:/bin/mount -t devtmpfs devtmpfs /dev
::sysinit:/etc/rc.local
ttyS0::respawn:/bin/sh
::ctrlaltdel:/sbin/reboot
::shutdown:/bin/umount -a -r
EOF

cat > "${ROOT_MNT}/etc/rc.local" << EOF
#!/bin/sh
ifconfig lo 127.0.0.1
ifconfig eth0 ${NANO_IP} netmask 255.255.255.0 up
route add default gw ${NANO_GW}
echo "nameserver ${NANO_GW}" > /etc/resolv.conf
hostname de25-nano
# There's no RTC - the clock boots at the epoch, which fails TLS cert
# validation for apk. Sync it. -w waits for the link to actually come up
# first (link training takes a couple seconds after ifconfig up returns) -
# without it this races and silently fails on a fair number of boots.
sleep 2
ntpd -q -n -p pool.ntp.org
EOF
chmod +x "${ROOT_MNT}/etc/rc.local"

echo de25-nano > "${ROOT_MNT}/etc/hostname"

cat > "${ROOT_MNT}/etc/fstab" << 'EOF'
/dev/mmcblk0p2  /       ext4    rw,relatime     0 1
/dev/mmcblk0p1  /boot   vfat    rw,relatime     0 0
proc            /proc   proc    defaults        0 0
sysfs           /sys    sysfs   defaults        0 0
devtmpfs        /dev    devtmpfs defaults       0 0
EOF
mkdir -p "${ROOT_MNT}/boot"

sync
umount "${BOOT_MNT}" "${ROOT_MNT}"

echo
echo "==================================================================="
echo "  done - ${DEV}1 = boot files (FAT32), ${DEV}2 = Alpine rootfs (ext4)"
echo
echo "  Put the card back in the board and power-cycle. On U-Boot's first"
echo "  boot after this, set the persistent boot config once (see"
echo "  linux/README.md's 'Real rootfs (Alpine Linux)' section for the"
echo "  exact commands) - after that it boots straight to a login-free"
echo "  Alpine shell with networking and correct time, no manual steps."
echo "==================================================================="
