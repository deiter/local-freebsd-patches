#!/bin/sh -exu

_media="/export/media"
_books="$_media/books"
_export="-ro"

_usage()
{
	echo "$0 <start | stop>"
	exit 1
}

_mount_iso()
{
	local _name _md _iso

	_iso="$1"
	_name=$(basename -s .iso $_iso)
	_md=$(mdconfig -f $_books/$_iso)

	test -d $_media/$_name || mkdir -p $_media/$_name
	mount_udf -v -o ro -C UTF-8 /dev/$_md $_media/$_name

	cat >>/etc/exports.md <<-EOF
	$_media/$_name	$_export
	EOF
}

_umount_iso()
{
	local _name _md _iso

	_iso="$1"
	_name=$(basename -s .iso $_iso)
	_md=$(df -h | grep -E "^/dev/md[0-9]+.*$_media/$_name\$" | awk '{print $1}')

	if [ -z "$_md" ]; then
		return
	fi

	umount -f $_media/$_name
	rmdir $_media/$_name
	mdconfig -d -u $_md
	
}

if [ $# -ne 1 ]; then
	_usage
fi

_action="$1"

case "$_action" in
start)
	_mount_iso traum_ru.iso
	_mount_iso traum_en.iso
	service mountd reload
	;;
stop)
	cat /dev/null >/etc/exports.md
	service mountd reload
	_umount_iso traum_ru.iso
	_umount_iso traum_en.iso
	;;
*)
	usage
	;;
esac
