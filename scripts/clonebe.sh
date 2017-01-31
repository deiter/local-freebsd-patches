#!/bin/sh -exu

_script=$(realpath $0)
_base=$(dirname $_script)

. $_base/common.sh

_update_cfg
_mount_fs

if [ $# -eq 1 ]; then
	_kernel=$1
fi

_force="yes"
_version="$_obj$_src/sys/$_kernel/vers.c"

if [ ! -r "$_version" ]; then
	_exit "File '$_version' not found"
fi

_release=$(awk -F'"' '/^#define.*RELSTR/{split($2, a, "-"); printf "%s-%s\n", a[3], a[4]}' $_version)

if [ -z "$_release" ]; then
	_exit "Release version string is empty"
fi

_amsg "Update system up to release $_release"

_active_be=$(kenv zfs_be_active | awk -F: '{print $NF}')

if [ -z "$_active_be" ]; then
	_exit "Active boot environment not found"
fi

_amsg "Active boot environment $_active_be"

_cloned_be="${_pool}/be/${_release}"

_amsg "Cloned boot environment $_cloned_be"

if [ "$_active_be" = "$_cloned_be" ]; then
	_exit "Cloned boot environment $_cloned_be is equal to the active boot environment $_active_be"
fi

_snapshot=$(date +%F_%T)
_amsg "Create recursive snapshot $_snapshot for active boot environment $_active_be"
zfs snapshot -r ${_active_be}@${_snapshot}

_destination=$(mktemp -d)

if [ ! -d "$_destination" ]; then
	_exit "Destination mount point for cloned boot environment $_cloned_be not found"
fi

_active_datasets=$(zfs list -H -r -t filesystem -o name $_active_be | sort)
_amsg "Clone active boot environment $_active_be -> $_cloned_be"
for _dataset in $_active_datasets; do
	_clone=${_cloned_be}${_dataset#$_active_be}
	if zfs list $_clone >/dev/null 2>&1; then
		if [ -n "$_force" ]; then
			zfs destroy -Rf $_clone
		else
			_exit "Cloned filesystem $_clone already exist"
		fi
	fi
	zfs clone -p -o canmount=noauto ${_dataset}@${_snapshot} $_clone
done

_amsg "Set temporary mountpoint for cloned boot environment $_cloned_be"
zfs set mountpoint=$_destination $_cloned_be
zfs set readonly=off $_cloned_be/var/empty

_cloned_datasets=$(zfs list -H -r -t filesystem -o name $_cloned_be | sort)
_amsg "Mount cloned boot environment $_cloned_be into $_destination directory"
install -v -d -m 0755 -g wheel -o root $_destination
for _dataset in $_cloned_datasets; do
	zfs mount $_dataset
done

_log="/var/log/$_release.log"

cd $_src
_amsg "Install release $_release into $_destination"
make DESTDIR=$_destination KERNCONF=$_kernel installworld installkernel >>$_log 2>&1

cd $_destination
install -v -o root -g wheel -m 0444 usr/share/zoneinfo/$_tz etc/localtime
install -v -o root -g wheel -m 0444 /dev/null etc/wall_cmos_clock

cat >var/db/zoneinfo <<EOF
$_tz
EOF

grep -v '^vfs.root.mountfrom=' /boot/loader.conf >boot/loader.conf

cat >>boot/loader.conf <<EOF
vfs.root.mountfrom="zfs:$_cloned_be"
EOF

_amsg "Update config files for cloned boot environment $_cloned_be"
mergemaster -d -m $_src -D $_destination
mergemaster -d -m $_src -D $_destination
cd $_root

_amsg "Umount cloned boot environment $_cloned_be"
zfs umount $_cloned_be
zfs set readonly=on $_cloned_be/var/empty
rmdir $_destination

_amsg "Disable canmount propery for active boot environment $_active_be"
for _dataset in $_active_datasets; do
	zfs set canmount=noauto $_dataset
done

_amsg "Enable canmount propery for cloned boot environment $_cloned_be"
for _dataset in $_cloned_datasets; do
	zfs promote $_dataset
	zfs set canmount=on $_dataset
done

_amsg "Set mountpoint for cloned boot environment $_cloned_be"
zfs set mountpoint=/ $_cloned_be

_amsg "Set boot filesystem $_cloned_be for pool $_pool"
zpool set bootfs=$_cloned_be $_pool

_amsg "Update UEFI boot loader for root pool $_pool"
_partitions=$(glabel status | awk '/'$_pool'_boot_/{print $NF}')
for _partition in $_partitions; do
	_amsg "Partition $_partition"
	dd if=$_obj$_src/sys/boot/efi/boot1/boot1.efifat of=/dev/$_partition
done

_umount_fs
_amsg "Done"
