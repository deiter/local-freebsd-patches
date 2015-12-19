#!/bin/sh -ex
#
# $Id: usb.sh 103 2014-12-23 09:36:52Z alex.deiter@gmail.com $
#

if [ $# -ne 2 ]; then
	echo "usage: $0 <daX> <gpt | uefi>"
	exit 1
else
	USB="$1"
	BOOT="$2"
	CWD="$PWD"
	SRC=$(dirname $(realpath $0))
fi

gpart destroy -F $USB || true
gpart create -s GPT $USB

case "$BOOT" in
gpt)
	gpart add -t freebsd-boot -s 512k -l usb_boot $USB
	gpart bootcode -b /boot/pmbr -p /boot/gptboot -i 1 $USB
	;;
uefi)
	gpart add -t efi -s 1M -l usb_efi $USB
	dd if=/var/tmp/alt/boot/boot1.efifat of=/dev/${USB}p1
	;;
*)
	echo "unknown boot type: $BOOT"
	exit 2
esac

gpart add -t freebsd-ufs -l usb_root $USB
newfs -L usb_root -O 2 -U -j -l /dev/gpt/usb_root
tunefs -a enable /dev/gpt/usb_root

mkdir -p /usb_mnt
mount /dev/ufs/usb_root /usb_mnt
cd /usb_mnt
tar pxf /var/tmp/base.tbz
cat >etc/fstab <<-EOF
/dev/ufs/usb_root	/	ufs	rw	1	1
EOF
cd media
cp /var/tmp/base.tbz .
svn checkout https://local-freebsd-patches.googlecode.com/svn/ local-freebsd-patches --trust-server-cert --non-interactive
cd $CWD
umount /usb_mnt
rmdir /usb_mnt
