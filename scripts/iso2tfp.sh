#!/bin/sh -exu

if [ $# -lt 1 ]; then
	echo "$0 <iso>"
	exit 1
fi

_host="172.27.10.2"
_json="autoinstall.json"
_tftp="/export/tftp"
_menu="$_tftp/boot/grub/menu.lst"

cd $_tftp

for _iso in $@; do
	echo " ==> $_iso"
	_md5=$_iso.md5
	_sum=$(awk '{print $1}' $_md5)
	_item=$(basename $_iso .iso)

	if [ -d $_item ]; then
		echo "$_item already exist"
		continue
	fi

	if ! md5 -c $_sum $_iso; then
		echo "invalid MD5 digest for $_iso"
		continue
	fi

	mkdir $_item
	tar xpf $_iso -C $_item
	chmod 0755 $_item
	chown -R root:wheel $_item

	if [ ! -r $_menu ]; then
		echo "grub menu '$_menu' dows not exist"
		continue
	fi

	case "$_item" in
	NexentaStor-Enterprise*)
		cat >>$_menu <<-EOF
		title $_item
		    kernel /$_item/platform/i86pc/kernel/amd64/unix -B iso_nfs_path=$_host:$_tftp/$_item
		    module /$_item/platform/i86pc/amd64/miniroot

		EOF
		;;
	NexentaStor5*)
		ln $_json $_item/$_json
		cat >>$_menu <<-EOF
		title $_item
		    kernel /$_item/platform/i86pc/kernel/amd64/unix -B iso_nfs_path=$_host:$_tftp/$_item -B install_profile=$_json
		    module /$_item/platform/i86pc/amd64/boot_archive

		EOF
		;;
	*)
		echo "skip grub menu config for $_item"
		;;
	esac
done
