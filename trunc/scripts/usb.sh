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
gpart add -t freebsd-boot -s 512k -l usb-boot $USB
gpart add -t freebsd-ufs -b 1m -l usb-root $USB
gpart bootcode -b /boot/pmbr -p /boot/gptboot -i 1 $USB

newfs -L usb-root -O 2 -U -j -l /dev/gpt/usb-root
tunefs -a enable /dev/gpt/usb-root

mkdir -p /usb-mnt
mount /dev/ufs/usb-root /usb-mnt
cd /usb-mnt
tar pxf /var/tmp/base.tbz
cat >etc/fstab <<-EOF
/dev/ufs/usb-root	/	ufs	rw	1	1
EOF
cp /var/tmp/base.tbz media
cp $SRC/*.sh media
cd $CWD
umount /usb-mnt
rmdir /usb-mnt
