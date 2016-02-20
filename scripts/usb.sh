#!/bin/sh -exu

if [ $# -ne 2 ]; then
	echo "usage: $0 <daX> <gpt | efi>"
	exit 1
fi

_tarball=/var/tmp/base.tbz
_disk=$(basename $1)
_type=$2
_cwd=$(pwd)
_dev=$(glabel list $_disk | awk '/diskid/{print $NF}')
_boot=${_dev}p1
_data=${_dev}p2
_mntpoint=$(mktemp -d)
_tmpdir=$(mktemp -d)

gpart destroy -F $_dev || true
gpart create -s gpt $_dev

cd $_tmpdir
tar pxf $_tarball boot

case "$_type" in
gpt)
	gpart add -t freebsd-boot -s 512k $_dev
	gpart bootcode -b boot/pmbr -p boot/gptboot -i 1 $_dev
	;;
efi)
	gpart add -t efi -s 1M $_dev
	dd if=boot/boot1.efifat of=/dev/$_boot
	;;
*)
	echo "unknown boot type: $_type"
	exit 2
esac

gpart add -t freebsd-ufs $_dev
newfs -O 2 -U -j -l /dev/$_data
tunefs -a enable /dev/$_data

mount /dev/$_data $_mntpoint
cd $_mntpoint
tar pxf $_tarball

cat >etc/fstab <<-EOF
/dev/$_data	/	ufs	rw	1	1
EOF

cd media
cp $_tarball .
cp -pR /root/src/local-freebsd-patches .
cd $_cwd
umount $_mntpoint
rmdir $_mntpoint
rm -rf $_tmpdir
