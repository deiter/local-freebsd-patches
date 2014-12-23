#!/bin/sh -ex

rm -f /boot/zfs/zpool.cache
mkdir -p /boot/geli

RELEASE=$(uname -r | awk -F- '{printf "%s_%s", $3, $4}')

# ada0: <ST9500420AS 0003LVM1> ATA-8 SATA 2.x device
# ada1: <ST9500420AS 0003LVM1> ATA-8 SATA 2.x device

HDD="ada0 ada1"

for i in $HDD; do
	gpart show $i >/dev/null 2>&1 && gpart destroy -F $i || true
	dd if=/dev/zero of=/dev/$i bs=1M count=100
	SEEK=$(diskinfo $i | awk '{printf "%d", $3/1024/1024-100}')
	dd if=/dev/zero of=/dev/$i bs=1M seek=$SEEK || true
	gpart create -s gpt $i
done

n=0
for i in $HDD; do
	gpart add -a 4k -s 1M -t efi         -l efi_$n  $i
	gpart add -a 4k -s 1G -t freebsd-ufs -l boot_$n $i
	gpart add -a 4k       -t freebsd-zfs -l data_$n $i

	dd if=/boot/boot1.efifat of=/dev/${i}p1
	dd if=/dev/random of=/boot/geli/$i.key bs=1k count=128
	geli init -b -K /boot/geli/$i.key -l 256 -e AES-CBC -s 4096 gpt/data_$n
	geli attach -k /boot/geli/$i.key gpt/data_$n
	n=$(( $n + 1 ))
done

gmirror label -v boot gpt/boot_0 gpt/boot_1
newfs -L boot -O 2 -U -j -l gpt/boot
tunefs -a enable gpt/boot

zpool create -f -O compression=lz4 -O atime=off -O mountpoint=none \
	data gpt/data_0.eli gpt/data_1.eli

ROOT="$RELEASE"
zfs create data/root
zfs create -o mountpoint=/mnt data/root/$ROOT
mount /dev/ufs/boot /mnt/boot
zfs create data/root/$ROOT/usr
zfs create data/root/$ROOT/usr/local
zfs create -o exec=off -o setuid=off data/root/$ROOT/var
zfs create data/root/$ROOT/var/backups
zfs create data/root/$ROOT/var/crash
zfs create data/root/$ROOT/var/db
zfs create -o exec=on data/root/$ROOT/var/db/pkg
zfs create data/root/$ROOT/var/empty
zfs create data/root/$ROOT/var/log
zfs create data/root/$ROOT/var/mail
zfs create data/root/$ROOT/var/run
zfs create data/root/$ROOT/var/spool
zfs create data/root/$ROOT/var/tmp
zfs create -V 32G data/swap
zfs set org.freebsd:swap=on data/swap
chmod 1777 /mnt/var/tmp

cd /mnt
tar pxf /media/base.tbz

zfs set readonly=on data/root/$ROOT/var/empty
cp -p /boot/zfs/zpool.cache /mnt/boot/zfs/zpool.cache
cp -pR /boot/geli /mnt/boot/geli
cp -p /etc/hostid etc/hostid

cat >>etc/fstab <<-EOF
/dev/ufs/boot	/boot	ufs	rw			2	2
tmpfs		/tmp	tmpfs	rw,nosuid,mode=1777	0	0
EOF

cat >>etc/rc.conf <<-EOF
zfs_enable="YES"
EOF

cat >>boot/loader.conf <<-EOF
beastie_disable="YES"
autoboot_delay="3"
geom_mirror_load="YES"
opensolaris_load="YES"
zfs_load="YES"
vfs.root.mountfrom="zfs:data/root/$ROOT"

geli_ada0_keyfile0_load="YES"
geli_ada0_keyfile0_type="ada0:geli_keyfile0"
geli_ada0_keyfile0_name="/boot/geli/ada0.key"

geli_ada1_keyfile0_load="YES"
geli_ada1_keyfile0_type="ada1:geli_keyfile0"
geli_ada1_keyfile0_name="/boot/geli/ada1.key"
EOF

cd
zfs umount -a
zfs set mountpoint=/ data/root/$ROOT
zfs set mountpoint=/boot boot/$ROOT
