#!/bin/sh -ex
#
# $Id$
#

if [ $# -ne 1 ]; then
	echo "usage: $0 <daX>"
	exit 1
else
	USB="$1"
	CWD="$PWD"
	SRC=$(dirname $(realpath $0))
fi

gpart destroy -F $USB || true
gpart create -s GPT $USB
gpart add -t freebsd-boot -s 512k -l usb_boot $USB
gpart add -t freebsd-ufs -b 1m -l usb_root $USB
gpart bootcode -b /boot/pmbr -p /boot/gptboot -i 1 $USB

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
