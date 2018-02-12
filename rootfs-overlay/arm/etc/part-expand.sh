#!/bin/sh
# This should resize the sdcard to its full capacity.

[ -f /etc/part-expanded ] && exit 0

cat <<EOF | fdisk /dev/mmcblk0
d
2
n
p
2


Y
w
EOF

partprobe

mount /dev/mmcblk0p2 /mnt
btrfs fi re max /mnt
umount /mnt

echo yes > /etc/part-expanded
