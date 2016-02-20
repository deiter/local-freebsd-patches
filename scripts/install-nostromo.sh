#!/bin/sh -exu

RELEASE=$(uname -r | awk -F- '{printf "%s_%s", $3, $4}')
DRIVER="ada"
DISKS="2 3"
RPOOL="zroot"
BOOT="boot"
DATA="data"

# rm -f /boot/zfs/zpool.cache

PART=0
for DISK in $DISKS; do
	gpart show ${DRIVER}${DISK} >/dev/null 2>&1 && gpart destroy -F ${DRIVER}${DISK} || true
	dd if=/dev/zero of=/dev/${DRIVER}${DISK} bs=1M count=100
	SEEK=$(diskinfo ${DRIVER}${DISK} | awk '{printf "%d", $3/1024/1024-100}')
	dd if=/dev/zero of=/dev/${DRIVER}${DISK} bs=1M seek=$SEEK || true
	gpart create -s gpt ${DRIVER}${DISK}
	gpart add -a 4k -s 1M -t efi          -l ${RPOOL}_${BOOT}_${PART} ${DRIVER}${DISK}
	gpart add -a 4k       -t freebsd-zfs  -l ${RPOOL}_${DATA}_${PART} ${DRIVER}${DISK}
	dd if=/var/tmp/nostromo-amd64.zsOsGSpg/boot/boot1.efifat of=/dev/gpt/${RPOOL}_${BOOT}_${PART}
	PART=$(( $PART + 1 ))
	read debug
done

zpool create -f \
	-O compression=lz4 \
	-O atime=off \
	-O mountpoint=none \
	$RPOOL mirror \
	/dev/gpt/${RPOOL}_${DATA}_0 \
	/dev/gpt/${RPOOL}_${DATA}_1

RFS="$RELEASE"
zfs create -o mountpoint=/mnt $RPOOL/$RFS
zfs create $RPOOL/$RFS/usr
zfs create $RPOOL/$RFS/usr/local
zfs create -o exec=off -o setuid=off $RPOOL/$RFS/var
zfs create $RPOOL/$RFS/var/backups
zfs create $RPOOL/$RFS/var/crash
zfs create $RPOOL/$RFS/var/db
zfs create -o exec=on $RPOOL/$RFS/var/db/pkg
zfs create $RPOOL/$RFS/var/empty
zfs create $RPOOL/$RFS/var/log
zfs create $RPOOL/$RFS/var/mail
zfs create $RPOOL/$RFS/var/run
zfs create $RPOOL/$RFS/var/spool
zfs create $RPOOL/$RFS/var/cores
zfs create $RPOOL/$RFS/var/tmp
chmod 1777 /mnt/var/tmp
chmod 0700 /mnt/var/cores

zfs create -V 64G $RPOOL/swap
zfs set org.freebsd:swap=on $RPOOL/swap

zpool set bootfs=$RPOOL/$RFS $RPOOL

cd /mnt
tar pxf /var/tmp/base.tbz

zfs set readonly=on $RPOOL/$RFS/var/empty

cp -p /etc/hostid etc/
cp -p /etc/rc.conf etc/
cp -p /boot/loader.conf boot/

cat >>etc/fstab <<-EOF
tmpfs	/tmp	tmpfs	rw,nosuid,mode=1777	0	0
EOF

cat >>etc/rc.conf <<-EOF
zfs_enable="YES"
EOF

cat >>boot/loader.conf <<-EOF
vfs.root.mountfrom="zfs:$RPOOL/$RFS"
EOF

cp -p /boot/zfs/zpool.cache boot/zfs/zpool.cache

cd
zfs umount $RPOOL/$RFS
zfs set mountpoint=/ $RPOOL/$RFS
