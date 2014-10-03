#!/bin/sh -ex

rm -f /boot/zfs/zpool.cache

RELEASE=$(uname -r)

# ada0: <INTEL SSDSC2BW120A4 DC22> ATA-9 SATA 3.x device
# ada1: <INTEL SSDSC2CW120A3 400i> ATA-9 SATA 3.x device
# ada2: <Hitachi HDS5C3020ALA632 ML6OA580> ATA-8 SATA 3.x device
# ada3: <ST4000VN000-1H4168 SC43> ATA-9 SATA 3.x device
# ada4: <WD2003FYYS-23W0B0 42D0788 42D0791IBM WA32> ATA-8 SATA 2.x device
# ada5: <WD2003FYYS-23W0B0 42D0788 42D0791IBM WA32> ATA-8 SATA 2.x device
# ada6: <WD2003FYYS-23W0B0 42D0788 42D0791IBM WA32> ATA-8 SATA 2.x device
# ada7: <WD2003FYYS-23W0B0 42D0788 42D0791IBM WA32> ATA-8 SATA 2.x device

SSD="ada0 ada1"
HDD="ada2 ada3 ada4 ada5 ada6 ada7"

for i in $HDD $SSD; do
	gpart destroy -F $i || true
	gpart create -s gpt $i
done

#
# system - pool for base system, critical user data, etc
# shared - pool for shared data
# backup - pool for backups
# 

# SSD
gpart add -a 4k -s 64g -t freebsd-zfs -l system_cache_0 ada1
gpart add -a 4k -s 16g -t freebsd-zfs -l system_log_0   ada1

gpart add -a 4k -s 64g -t freebsd-zfs -l shared_cache_0 ada0
gpart add -a 4k -s 16g -t freebsd-zfs -l shared_log_0   ada0

# HDD
n=0
for i in ada4 ada5 ada6 ada7; do
	gpart add -a 4k -s 512k -t freebsd-boot -l system_boot_$n $i
	gpart add -a 4k         -t freebsd-zfs  -l system_data_$n $i
	gpart bootcode -b /boot/pmbr -p /boot/gptzfsboot -i 1 $i
	n=$(( $n + 1 ))
done

for i in shared_cache_0 tank_log_0 system_cache_0 system_log_0; do
	gnop create -S 4096 /dev/gpt/$i
done

zpool create \
	-O compression=lz4 \
	-O atime=off \
	-O mountpoint=none \
	system raidz \
	/dev/gpt/system_data_0 \
	/dev/gpt/system_data_1 \
	/dev/gpt/system_data_2 \
	/dev/gpt/system_data_3 \
	cache /dev/gpt/system_cache_0.nop \
	log /dev/gpt/system_log_0.nop

gpart add -a 4k -s 512k -t freebsd-boot -l shared_boot ada3
gpart add -a 4k -t freebsd-zfs -l shared_data_0 ada3
gpart bootcode -b /boot/pmbr -p /boot/gptzfsboot -i 1 ada3
gnop create -S 4096 /dev/gpt/shared_data_0

gpart add -a 4k -s 512k -t freebsd-boot -l backup_boot ada2
gpart add -a 4k -t freebsd-zfs -l backup_data_0 ada2
gpart bootcode -b /boot/pmbr -p /boot/gptzfsboot -i 1 ada2

zpool create \
	-O compression=lz4 \
	-O atime=off \
	-O mountpoint=none \
	shared \
	/dev/gpt/shared_data_0.nop \
	cache /dev/gpt/shared_cache_0.nop \
	log /dev/gpt/shared_log_0.nop

zpool create \
	-O compression=lz4 \
	-O atime=off \
	-O mountpoint=none \
	backup \
	/dev/gpt/backup_data_0

for k in system shared; do
	zpool export $k
	for i in cache log; do
		test -f /dev/gpt/${k}_${i}_0.nop && gnop destroy /dev/gpt/${k}_${i}_0.nop
	done
	for n in 0 1 2 3 4 5 6 7 8 9; do
		test -f /dev/gpt/${k}_data_${n}.nop && gnop destroy /dev/gpt/${k}_data_${n}.nop
	done
	zpool import $k
done

ROOT="root_$RELEASE"
zfs create -o mountpoint=/mnt system/root
zfs create system/root/$ROOT
zfs create system/root/$ROOT/usr
zfs create system/root/$ROOT/usr/local
zfs create -o exec=off -o setuid=off system/root/$ROOT/var
zfs create system/root/$ROOT/var/backups
zfs create system/root/$ROOT/var/crash
zfs create system/root/$ROOT/var/db
zfs create -o exec=on system/root/$ROOT/var/db/pkg
zfs create system/root/$ROOT/var/empty
zfs create system/root/$ROOT/var/log
zfs create system/root/$ROOT/var/mail
zfs create system/root/$ROOT/var/run
zfs create system/$ROOT/var/spool
zfs create system/$ROOT/var/tmp
chmod 1777 /mnt/var/tmp

zpool set bootfs=system/$ROOT system

cd /mnt
tar pxf /media/base.tbz

zfs set readonly=on system/root/$ROOT/var/empty

cp -p /etc/hostid etc/hostid

cat >>etc/fstab <<-EOF
tmpfs	/tmp	tmpfs	rw,nosuid,mode=1777	0	0
EOF

cat >>etc/rc.conf <<-EOF
zfs_enable="YES"
EOF

cat >>boot/loader.conf <<-EOF
zfs_load="YES"
vfs.root.mountfrom="zfs:system/$ROOT"
EOF

cp -p /boot/zfs/zpool.cache /mnt/boot/zfs/zpool.cache
zfs umount -a
zfs set mountpoint=/ system/$ROOT
