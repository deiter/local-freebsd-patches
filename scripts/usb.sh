#!/bin/sh -exu
#
# $Id$
#

if [ $# -ne 2 ]; then
	echo "usage: $0 <daX> <gpt | uefi>"
	exit 1
fi

DISK=$(basename $1)
TYPE=$2
CWD=$(pwd)
SRC=$(dirname $(realpath $0))
DEV=$(glabel list $DISK | awk '/diskid/{print $NF}')
BOOT=${DEV}p1
DATA=${DEV}p2
MNTP=$(mktemp -d)

gpart destroy -F $DEV || true
gpart create -s GPT $DEV

case "$TYPE" in
gpt)
	gpart add -t freebsd-boot -s 512k $DEV
	gpart bootcode -b /boot/pmbr -p /boot/gptboot -i 1 $DEV
	;;
uefi)
	gpart add -t efi -s 1M $DEV
	dd if=/var/tmp/alt/boot/boot1.efifat of=/dev/$BOOT
	;;
*)
	echo "unknown boot type: $TYPE"
	exit 2
esac

gpart add -t freebsd-ufs $DEV
newfs -O 2 -U -j -l /dev/$DATA
tunefs -a enable /dev/$DATA

mount /dev/$DATA $MNTP
cd $MNTP
tar pxf /var/tmp/base.tbz
cat >etc/fstab <<-EOF
/dev/da0p2	/	ufs	rw	1	1
EOF
cd media
cp /var/tmp/base.tbz .
cp -pR /root/src/local-freebsd-patches .
cd $CWD
umount $MNTP
rmdir $MNTP
