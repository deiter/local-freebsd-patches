#!/bin/sh -eux

. common.sh

_update_cfg
_mount_fs

_force="$@"
_ver="$_obj$_src/sys/$_kernel/vers.c"

if [ ! -r "$_ver" ]; then
	_exit " ==> File '$_ver' not found or not readable"
fi

_rel=$(awk -F'"' '/^#define.*RELSTR/{split($2, a, "-"); printf "%s-%s\n", a[3], a[4]}' $_ver)

if [ -z "$_rel" ]; then
	_exit " ==> Release version string is empty"
fi

echo " ==> Update system up to release version $_rel"

_dst="/tmp/$_rel"
_log="/var/log/$_rel.log"

if [ -d $_dst ]; then
	_name=$(zfs list -H -o name $_dst 2>/dev/null)
	if [ -n "$_name" ]; then
		zfs umount -f $_name
	fi
	rmdir  $_dst
fi

_old_root=$(zfs list -H -o name /)
if [ -z "$_old_root" ]; then
	_exit " ==> Current root filesystem is empty"
fi

echo " ==> Current root filesystem $_old_root"

_new_root="${_pool}/${_rel}"
if [ -z "$_new_root" ]; then
	_exit " ==> New root filesystem is empty"
fi

echo " ==> New root filesystem $_new_root"

if [ "$_old_root" = "$_new_root" ]; then
	_exit " ==> New root filesystem is equal to the current root filesystem"
fi

_snapshot=$(date +%F_%T)
echo " ==> Create recursive snapshot $_snapshot"
zfs snapshot -r $_old_root@$_snapshot
install -d -m 0755 -g wheel -o root $_dst

_old_tree=$(zfs list -r -H -t filesystem -o name / | sort)
echo " ==> Clone current root filesystem tree"
for _fs in $_old_tree; do
	_clone=$(echo $_fs | sed "s|^$_old_root|$_new_root|g")
	if zfs list $_clone >/dev/null 2>&1; then
		if [ -n "$_force" ]; then
			echo "  ==> Destroy cloned filesystem $_clone"
			zfs destroy -Rf $_clone
		else
			_exit "  ==> Cloned filesystem $_clone already exist"
		fi
	fi
	echo "  ==> Clone snapshot $_fs@$_snapshot to filesystem $_clone"
	zfs clone -o canmount=noauto $_fs@$_snapshot $_clone
done

echo " ==> Set mountpoint for new root filesystem tree"
zfs set mountpoint=/ $_new_root
install -v -d -m 0755 -g wheel -o root $_dst

_new_tree=$(zfs list -r -H -t filesystem -o name $_new_root | sort)
echo " ==> Mount new root filesystem tree"
for _fs in $_new_tree; do
	_mount_point=$(zfs get -H -o value mountpoint $_fs)
	echo "  ==> Mount filesystem $_fs into $_dst$_mount_point"
	mount -t zfs $_fs $_dst$_mount_point
done

zfs set readonly=off $_new_root/var/empty

cd $_src
echo " ==> Install release version $_rel into $_dst"
make DESTDIR=$_dst KERNCONF=$_kernel installworld installkernel >>$_log 2>&1

cd $_dst
install -v -o root -g wheel -m 0444 usr/share/zoneinfo/$_tz etc/localtime
install -v -o root -g wheel -m 0444 /dev/null etc/wall_cmos_clock
echo $_tz >var/db/zoneinfo

grep -v '^vfs.root.mountfrom=' /boot/loader.conf >boot/loader.conf
cat >>boot/loader.conf <<EOF
vfs.root.mountfrom="zfs:$_new_root"
EOF

echo " ==> Merge config files into $_dst"
mergemaster -s -i -F -d --run-updates=always -m $_src -D $_dst
mergemaster -s -i -F -d --run-updates=always -m $_src -D $_dst

zfs set readonly=on $_new_root/var/empty

cd $_root

echo " ==> Umount $_new_root tree"
zfs umount $_new_root
rmdir $_dst

echo " ==> Disable canmount propery for $_old_root tree"
for _fs in $_old_tree; do
	echo "  ==> Disable canmount propery for filesystem $_fs"
	zfs set canmount=noauto $_fs
done

echo " ==> Update bootfs for $_pool: $_new_root"
zpool set bootfs=$_new_root $_pool

echo " ==> Promote and enable canmount propery for $_new_root tree"
for _fs in $_new_tree; do
	echo "  ==> Enable canmount propery for filesystem $_fs"
	zfs set canmount=on $_fs
	echo "  ==> Promote filesystem $_fs"
	zfs promote $_fs
done

cd
_umount_fs

echo " ==> Update UEFI boot loader"
_list=$(glabel status | awk '/'$_pool'_boot_/{print $NF}')
for _part in $_list; do
	echo "  ==> Partition $_part"
	dd if=$_obj$_src/sys/boot/efi/boot1/boot1.efifat of=/dev/$_part
done

echo " ==> Done"
