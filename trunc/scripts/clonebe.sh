#!/bin/sh -exu
#
# $Id$
#

ROOT_POOL="system"
ROOT_DATASET="$ROOT_POOL/root"
TZ="Europe/Moscow"
TMPDIR="/var/tmp"
SRCDIR="/usr/src"
SCRIPT=$(realpath $0)
WRKDIR=$(dirname $(dirname $SCRIPT))
KERNCONF=$(hostname -s | tr [a-z] [A-Z])

if [ -x /usr/bin/svnlite ]; then
	SVN=/usr/bin/svnlite
elif [ -x /usr/bin/svn ]; then
	SVN=/usr/bin/svn
else
	echo "svn not found"
	exit 1
fi

cd $SRCDIR
LEVEL=$(ls $WRKDIR/patches/patch-* | wc -l | awk '{print $NF}')
REVISION=$($SVN info | awk '/^Last\ Changed\ Rev:/{print $NF}')
RELEASE="r${REVISION}_p${LEVEL}"

NEW_ROOT_FS="$ROOT_DATASET/$RELEASE"
SNAPSHOT=$(date +%F_%T)
CURRENT_ROOT_FS=$(zfs list -H -o name /)
zfs snapshot -r ${CURRENT_ROOT_FS}@${SNAPSHOT}

CURRENT_ROOT_TREE=$(zfs list -r -H -o name / | sort)
for i in $CURRENT_ROOT_TREE; do
	CLONE=$(echo $i | sed "s|^$CURRENT_ROOT_FS|$NEW_ROOT_FS|g")
	zfs clone -o canmount=noauto ${i}@${SNAPSHOT} $CLONE
done

zfs set mountpoint=/ $NEW_ROOT_FS

NEW_ROOT_TREE=$(zfs list -H -o name $NEW_ROOT_FS | sort)
for i in $NEW_ROOT_TREE; do
	MOUNT_POINT=$(zfs get -H -o value mountpoint $i)
	mount -t zfs $i /mnt$MOUNT_POINT
done

zfs set readonly=off $NEW_ROOT_FS/var/empty

cd /usr/src
make installkernel DESTDIR=/mnt KERNCONF=$KERNCONF
make installworld  DESTDIR=/mnt KERNCONF=$KERNCONF

cd /mnt
install -v -o root -g wheel -m 0444 usr/share/zoneinfo/$TZ etc/localtime
install -v -o root -g wheel -m 0444 /dev/null etc/wall_cmos_clock
echo $TZ >var/db/zoneinfo

grep -v ^vfs.root.mountfrom /boot/loader.conf >boot/loader.conf
cat >>boot/loader.conf <<EOF
vfs.root.mountfrom="zfs:$NEW_ROOT_FS"
EOF

cat boot/loader.conf ; read ff

mergemaster -i -F -D /mnt
mergemaster -i -F -D /mnt

zfs set readonly=on $NEW_ROOT_FS/var/empty

cd

zfs umount $NEW_ROOT_FS

echo "change root fs ..." && read done

for i in $CURRENT_ROOT_TREE; do
	zfs set canmount=noauto $i
done

zpool set bootfs=$NEW_ROOT_FS $ROOT_POOL

for i in $NEW_ROOT_TREE; do
	zfs set canmount=on $i
	zfs promote $i
done

echo done
