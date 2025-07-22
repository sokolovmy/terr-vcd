#!/bin/bash
# This script converts an official Ubuntu cloud image to one with LVM root
# Maxim Sokolov (sokolovmy@gmail.com), 2025
# MIT License

set -euo pipefail

if [ -z "${1:-}" ]; then echo "Usage: $0 <Official ubuntu cloud image.ova>"; exit 1; fi

IN_OVA=$(realpath "$1")
BASENAME=$(basename "$IN_OVA" .ova)
OUT_OVA="$(dirname "$IN_OVA")/${BASENAME}-lvm.ova"

WORKDIR=$(mktemp -d)
DISK_SIZE=10G

cleanup() {
    echo "[*] Cleaning up..."
    sudo umount "$WORKDIR/mnt" 2>/dev/null || true
    sudo umount "$WORKDIR/newroot/dev" 2>/dev/null || true
    sudo umount "$WORKDIR/newroot/proc" 2>/dev/null || true
    sudo umount "$WORKDIR/newroot/sys" 2>/dev/null || true
    sudo umount "$WORKDIR/newroot" 2>/dev/null || true
    sudo vgchange -an || true
    sudo losetup -D || true
    sudo rm -rf "$WORKDIR"
}
trap cleanup EXIT

echo "[*] Extracting original OVA: $IN_OVA"
cd "$WORKDIR"
tar xvf "$IN_OVA"

VMDK_FILE=$(ls *.vmdk)
VMDK_FILE_BASENAME=$(basename "$VMDK_FILE" .vmdk)
NEW_VMDK_FILE="${VMDK_FILE_BASENAME}-lvm.vmdk"

OVF_FILE=$(ls *.ovf)
OVF_FILE_BASENAME=$(basename "$OVF_FILE" .ovf)
NEW_OVF_FILE="${OVF_FILE_BASENAME}-lvm.ovf"

NEW_MANIFEST_FILE="${OVF_FILE_BASENAME}-lvm.mf"

echo "[*] Converting original VMDK to RAW..."
qemu-img convert -f vmdk -O raw "$VMDK_FILE" "$VMDK_FILE_BASENAME.img"

echo "[*] Mounting original image..."
LOOP_ORIG=$(sudo losetup --find --show --partscan "$VMDK_FILE_BASENAME.img")
mkdir "$WORKDIR/mnt"
sudo mount "${LOOP_ORIG}p1" "$WORKDIR/mnt"

echo "[*] Creating new disk image..."
qemu-img create -f raw "$VMDK_FILE_BASENAME-lvm.img" "$DISK_SIZE"

LOOP_NEW=$(sudo losetup --find --show --partscan "$VMDK_FILE_BASENAME-lvm.img")
echo "[*] Partitioning new disk..."
sudo parted -s "$LOOP_NEW" mklabel msdos
sudo parted -s "$LOOP_NEW" mkpart primary 1MiB 100%
sudo parted -s "$LOOP_NEW" set 1 lvm on

sudo partprobe "$LOOP_NEW"

echo "[*] Creating LVM on new partition..."
PART="${LOOP_NEW}p1"
sudo pvcreate "$PART"
sudo vgcreate vg0 "$PART"
sudo lvcreate -L2G -n swap vg0
sudo lvcreate -l 100%FREE -n root vg0

echo "[*] Formatting volumes..."
sudo mkswap /dev/vg0/swap
sudo mkfs.ext4 /dev/vg0/root

echo "[*] Mounting new root..."
mkdir "$WORKDIR/newroot"
sudo mount /dev/vg0/root "$WORKDIR/newroot"
sudo mkdir -p "$WORKDIR/newroot/boot"

echo "[*] Copying files from original image..."
sudo rsync -aAXH "$WORKDIR/mnt/" "$WORKDIR/newroot/"

echo "[*] Mounting system dirs..."
sudo mount --bind /dev "$WORKDIR/newroot/dev"
sudo mount --bind /proc "$WORKDIR/newroot/proc"
sudo mount --bind /sys "$WORKDIR/newroot/sys"

echo "[*] Generating fstab..."
sudo tee "$WORKDIR/newroot/etc/fstab" > /dev/null <<EOF
/dev/mapper/vg0-root / ext4 defaults 0 1
/dev/mapper/vg0-swap none swap sw 0 0
EOF

echo "[*] Blacklisting floppy kernel module..."
sudo tee "$WORKDIR/newroot/etc/modprobe.d/blacklist-floppy.conf" > /dev/null <<EOF
blacklist floppy
EOF

echo "[*] Installing GRUB and initramfs..."

sudo chroot "$WORKDIR/newroot" update-initramfs -u
sudo chroot "$WORKDIR/newroot" grub-install --target=i386-pc --recheck "$LOOP_NEW"
sudo chroot "$WORKDIR/newroot" update-grub

# TODO: remove output
echo "[*] Removing snapd and cleaning system..."
sudo chroot "$WORKDIR/newroot" bash -c '
    apt-get purge -y snapd 2>&1 >/dev/null && \
    rm -rf /root/snap /snap /var/snap /var/lib/snapd /etc/systemd/system/snap* && \
    apt-get autoremove -y
'

echo "[*] Zero-filling free space for better compression..."
sudo chroot "$WORKDIR/newroot" bash -c '
    dd if=/dev/zero of=/zerofill bs=1M status=progress 2>/dev/null || true
    rm -f /zerofill
    sync
'


echo "[*] Adding cloud-init LVM extension..."
sudo tee "$WORKDIR/newroot/etc/cloud/cloud.cfg.d/99-lvm.cfg" > /dev/null <<EOF
#cloud-config
merge_how:
 - name: list
   settings: [append]
 - name: dict
   settings: [no_replace, recurse_list]

bootcmd:
  - [ growpart, /dev/sda, 1 ]
  - [ pvresize, /dev/sda1 ]
  - [ lvextend, -l, +100%FREE, /dev/mapper/vg0-root ]
  - [ resize2fs, /dev/mapper/vg0-root ]
EOF


echo "[*] Unmount new FS ..."
sudo umount "$WORKDIR/newroot/dev"
sudo umount "$WORKDIR/newroot/proc"
sudo umount "$WORKDIR/newroot/sys"
sudo umount "$WORKDIR/newroot"


echo "[*] Converting image..."
qemu-img convert -f raw -O vmdk -o subformat=streamOptimized "$VMDK_FILE_BASENAME-lvm.img" $NEW_VMDK_FILE


echo "[*] Patching OVF..."
cp "$OVF_FILE" "$NEW_OVF_FILE"
DISK_SIZE=$(stat --format=%s "$NEW_VMDK_FILE")

sed -i -E "s|<File ovf:href=\"(.+\.vmdk)\" ovf:id=\"file1\" ovf:size=\"[0-9]+\"/>|<File ovf:href=\"\1\" ovf:id=\"file1\" ovf:size=\"$DISK_SIZE\"/>|" "$NEW_OVF_FILE"
sed -i -E "s|<Product>(.+)</Product>|<Product>(LVM) \1</Product>|" "$NEW_OVF_FILE"
sed -i -E "s|$VMDK_FILE_BASENAME|$VMDK_FILE_BASENAME-lvm|" "$NEW_OVF_FILE"

echo "[*] Generating checksums..."
sha256sum  $NEW_OVF_FILE $NEW_VMDK_FILE | sed 's|\(^[0-9a-f]*\)\s*\(.*\)|SHA256(\2)= \1|' > $NEW_MANIFEST_FILE

echo "[*] Creating OVA with LVM Root..."
tar cvf "$OUT_OVA" $NEW_OVF_FILE $NEW_MANIFEST_FILE $NEW_VMDK_FILE

echo "[✓] Done: $OUT_OVA"
