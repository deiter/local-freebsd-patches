#!/bin/sh -exu

_script=$(realpath $0)
_base=$(dirname $_script)

. $_base/common.sh

if [ $# -ne 2 ]; then
	_exit "Usage: $0 <daX> <gpt | efi>"
fi

_tarball=$_stage/latest.tbz
_tarball=$_stage/latest.tbz
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
	_exit "Unknown boot type: $_type"
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
cp -pR $_root devel
cd $_cwd
umount $_mntpoint
rmdir $_mntpoint
rm -rf $_tmpdir
