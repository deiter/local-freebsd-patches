#!/bin/sh -exu

unset LANG LC_ALL

if [ $# -ne 2 ]; then
	echo "usage: $0 <daX> <gpt | efi>"
	exit 1
fi

_tarball=/var/tmp/base.tbz
_disk=$(basename $1)
_label=$(openssl rand -hex 8)
_boot=${_label}_boot
_data=${_label}_data
_type=$2
_cwd=$(pwd)
_mntpoint=$(mktemp -d)
_tmpdir=$(mktemp -d)

gpart destroy -F $_disk || true
gpart create -s gpt $_disk

cd $_tmpdir
tar pxf $_tarball boot

case "$_type" in
gpt)
	gpart add -t freebsd-boot -l $_boot -s 512k $_disk
	gpart bootcode -b boot/pmbr -p boot/gptboot -i 1 $_disk
	;;
efi)
	gpart add -t efi -l $_boot -s 1M $_disk
	dd if=boot/boot1.efifat of=/dev/gpt/$_boot
	;;
*)
	echo "unknown boot type: $_type"
	exit 2
esac

gpart add -t freebsd-ufs -l $_data $_disk
newfs -O 2 -U -j -l /dev/gpt/$_data
tunefs -a enable /dev/gpt/$_data

mount /dev/gpt/$_data $_mntpoint
cd $_mntpoint
tar pxf $_tarball

cat >etc/fstab <<-EOF
/dev/gpt/$_data	/	ufs	rw	1	1
EOF

cd media
cp $_tarball .
# cp -pR /root/src/local-freebsd-patches .
cd $_cwd
umount $_mntpoint
rmdir $_mntpoint
rm -rf $_tmpdir
