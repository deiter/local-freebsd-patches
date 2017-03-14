#!/bin/sh -eu

_list="alien/www alien/media/foto alien/media/video"
_snapshot=$(date +%F_%T)

for _dataset in $_list; do
	/sbin/zfs snapshot -r $_dataset@$_snapshot
done
