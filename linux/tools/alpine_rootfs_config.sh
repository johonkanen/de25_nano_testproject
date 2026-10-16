#!/usr/bin/env bash
# alpine_rootfs_config.sh ROOT_DIR [BOOT_DIR] - turn an extracted Alpine
# aarch64 minirootfs into the DE25-Nano's rootfs: init, networking,
# hostname, time sync, fstab, and the web GUI in /opt/de25web. With
# BOOT_DIR, also writes the boot partition's extlinux/extlinux.conf, which
# U-Boot's distro boot finds on its own (no saveenv needed).
#
# Shared by setup_alpine_rootfs.sh (a card in a reader) and
# make_sdcard_image.sh (an image file for sd_recover.py / dd). Run as root
# or under fakeroot so the files end up owned by root.
#
# Env: NANO_IP, NANO_GW - the board's static address (linux/README.md
# "Networking" says why static).
set -euo pipefail

ROOT="${1:?usage: alpine_rootfs_config.sh ROOT_DIR [BOOT_DIR]}"
BOOT="${2:-}"
TOOLS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NANO_IP="${NANO_IP:-192.168.1.222}"
NANO_GW="${NANO_GW:-192.168.1.1}"

[[ -f "${ROOT}/etc/alpine-release" ]] || { echo "ERROR: ${ROOT} is not an Alpine rootfs"; exit 1; }

echo ">> configuring inittab, networking, hostname, time sync"
# (no devtmpfs mount: the kernel mounts /dev itself, CONFIG_DEVTMPFS_MOUNT)
cat > "${ROOT}/etc/inittab" << EOF
::sysinit:/bin/mount -t proc proc /proc
::sysinit:/bin/mount -t sysfs sysfs /sys
::sysinit:/etc/rc.local
ttyS0::respawn:/bin/sh
::respawn:/opt/de25web/supervisor.sh
::ctrlaltdel:/sbin/reboot
::shutdown:/bin/umount -a -r
EOF

cat > "${ROOT}/etc/rc.local" << EOF
#!/bin/sh
ifconfig lo 127.0.0.1
ifconfig eth0 ${NANO_IP} netmask 255.255.255.0 up
route add default gw ${NANO_GW}
echo "nameserver ${NANO_GW}" > /etc/resolv.conf
hostname de25-nano
# There's no RTC - the clock boots at the epoch, which fails TLS cert
# validation for apk. Sync it, after a pause for the link to finish
# training (without it this races and silently fails on a fair number of
# boots).
sleep 2
ntpd -q -n -p pool.ntp.org
# The web GUI (/opt/de25web, started from inittab) needs python3: fetched
# on the first boot with network, a no-op after that.
command -v python3 >/dev/null || apk add python3
EOF
chmod +x "${ROOT}/etc/rc.local"

echo de25-nano > "${ROOT}/etc/hostname"

cat > "${ROOT}/etc/fstab" << 'EOF'
/dev/mmcblk0p2  /       ext4    rw,relatime     0 1
/dev/mmcblk0p1  /boot   vfat    rw,relatime     0 0
proc            /proc   proc    defaults        0 0
sysfs           /sys    sysfs   defaults        0 0
devtmpfs        /dev    devtmpfs defaults       0 0
EOF
mkdir -p "${ROOT}/boot"

echo ">> installing the web GUI to /opt/de25web (see linux/webapp/README.md)"
# the same layout linux/tools/install_webapp.py makes on a running board
python3 - "${ROOT}/opt/de25web" "${TOOLS}" << 'PYEOF'
import io, os, sys, tarfile
base, tools = sys.argv[1], sys.argv[2]
sys.modules.setdefault("serial", type(sys)("serial"))   # install_webapp imports it
sys.path.insert(0, tools)
import install_webapp
blob, rel = install_webapp.bundle()
os.makedirs(os.path.join(base, "releases"), exist_ok=True)
tarfile.open(fileobj=io.BytesIO(blob), mode="r:gz").extractall(base)
link = os.path.join(base, "current")
if os.path.lexists(link):
    os.remove(link)
os.symlink(os.path.join("releases", rel), link)
print("   release", rel)
PYEOF
find "${ROOT}/opt/de25web" -name __pycache__ -prune -exec rm -rf {} +
if [[ ! -f "${ROOT}/opt/de25web/token" ]]; then
    ( umask 077; head -c 16 /dev/urandom | od -An -tx1 | tr -d ' \n' > "${ROOT}/opt/de25web/token" )
fi

if [[ -n "${BOOT}" ]]; then
    echo ">> extlinux.conf"
    mkdir -p "${BOOT}/extlinux"
    cat > "${BOOT}/extlinux/extlinux.conf" << 'EOF'
# Found by U-Boot's distro boot on the card's bootable FAT partition.
default alpine
timeout 1

label alpine
    kernel /Image
    fdt /socfpga_agilex5_de25_nano.dtb
    append console=ttyS0,115200 root=/dev/mmcblk0p2 rw rootwait earlycon panic=-1 kvm-arm.mode=nvhe
EOF
fi
