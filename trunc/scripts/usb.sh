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
fi

gpart destroy -F $USB || true
gpart create -s GPT $USB
gpart bootcode -b /boot/pmbr $USB
gpart add -t freebsd-boot -s 512k -a 4k -l usb4boot $USB
gpart bootcode -p /boot/gptboot -i 1 $USB
gpart add -t freebsd-ufs -b 1m -l usb4root $USB
newfs -j -L usb4root -O 2 -U /dev/gpt/usb4root
mkdir /usb4mnt
mount /dev/gpt/usb4root /usb4mnt
cd /usb4mnt
tar pxf /var/tmp/base.tbz
cat >etc/fstab <<-EOF
/dev/gpt/usb4root	/	ufs	rw	1	1
EOF
cp /var/tmp/base.tbz media
cd $CWD
umount /usb4mnt
rmdir /usb4mnt
