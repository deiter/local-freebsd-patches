#!/bin/sh -eu

_root_pool='zroot'
_tz='Europe/Moscow'
_tmpdir='/var/tmp'
_srcdir='/usr/src'
_objdir='/usr/obj'
_kernconf=$(uname -i)
_dstdir=$(TMPDIR=$_tmpdir mktemp -d -t $_kernconf)
_log=$(TMPDIR=$_tmpdir mktemp -t $_kernconf)
_relfile="$_objdir/usr/src/sys/${_kernconf}/vers.c"
_timeout=30
_prompt='...'
_force=''

if [ -r $_relfile ]; then
	_release=$(awk -F'"' '/^#define.*RELSTR/{split($2, a, "-"); printf "%s-%s\n", a[3], a[4]}' $_relfile)
else
	exit 1
fi

if [ -n "$_release" ]; then
	echo " ==> Update system up to $_release."
else
	exit 1
fi

_old_root=$(zfs list -H -o name /)
if [ -n "$_old_root" ]; then
	echo " ==> Old root $_old_root."
else
	exit 1
fi

_new_root="${_root_pool}/${_release}"
if [ -n "$_new_root" ]; then
	echo " ==> New root $_new_root."
else
	exit 1
fi

_snapshot=$(date +%F_%T)
echo " ==> Creating snapshot $_snapshot."
zfs snapshot -r ${_old_root}@${_snapshot}

_old_root_tree=$(zfs list -r -H -t filesystem -o name / | sort)
echo " ==> Cloning old root tree."
for _fs in $_old_root_tree; do
	_clone=$(echo $_fs | sed "s|^$_old_root|$_new_root|g")
	if zfs list $_clone >/dev/null 2>&1; then
		if [ -n "$_force" ]; then
			echo "  ==> Destroing cloned filesystem $_clone."
			zfs destroy -Rv $_clone
		fi
	fi
	echo "  ==> Cloning snapshot ${_fs}@${_snapshot} to filesystem $_clone."
	zfs clone -o canmount=noauto ${_fs}@${_snapshot} $_clone
done

echo " ==> Set mountpoint for new root tree."
zfs set mountpoint=/ $_new_root

_new_root_tree=$(zfs list -r -H -t filesystem -o name $_new_root | sort)
echo " ==> Mount new root tree:"
for _fs in $_new_root_tree; do
	_mount_point=$(zfs get -H -o value mountpoint $_fs)
	echo "  ==> Mount filesystem $_fs into ${_dstdir}${_mount_point}."
	mount -t zfs $_fs ${_dstdir}${_mount_point}
done

zfs set readonly=off $_new_root/var/empty

cd $_srcdir
echo " ==> Install $_release into $_dstdir."
make installworld  DESTDIR=$_dstdir >>$_log 2>&1
make installkernel DESTDIR=$_dstdir KERNCONF=$_kernconf >>$_log 2>&1

cd $_dstdir
install -v -o root -g wheel -m 0444 usr/share/zoneinfo/$_tz etc/localtime
install -v -o root -g wheel -m 0444 /dev/null etc/wall_cmos_clock
echo $_tz >var/db/zoneinfo

grep -v '^vfs.root.mountfrom=' /boot/loader.conf >boot/loader.conf
cat >>boot/loader.conf <<EOF
vfs.root.mountfrom="zfs:$_new_root"
EOF

cat boot/loader.conf && read -p $_prompt -t $_timeout done

echo " ==> Merge config files into $_dstdir."
rm -f etc/COPYRIGHT
mergemaster -s -i -F --run-updates=always -D $_dstdir
mergemaster -s -i -F --run-updates=always -D $_dstdir

zfs set readonly=on $_new_root/var/empty

cd

echo " ==> Umount $_new_root tree."
zfs umount $_new_root

echo " ==> Disable canmount propery for $_old_root tree."
for _fs in $_old_root_tree; do
	echo "  ==> Disable canmount propery for filesystem $_fs."
	zfs set canmount=noauto $_fs
done

echo " ==> Update bootfs for $_root_pool: $_new_root."
zpool set bootfs=$_new_root $_root_pool

echo " ==> Enable canmount propery for $_new_root tree."
for _fs in $_new_root_tree; do
	echo "  ==> Enable canmount propery for filesystem $_fs."
	zfs set canmount=on $_fs
	echo "  ==> Promote filesystem $_fs."
	zfs promote $_fs
done

rmdir $_dstdir
rm $_log

echo " ==> Done."
