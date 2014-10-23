#!/bin/sh -xe
#
# $Id$
#

TMPDIR="/var/tmp"
SRCDIR="/usr/src"
SCRIPT=$(realpath $0)
WRKDIR=$(dirname $(dirname $SCRIPT))

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
RELEASE="r${REVISION}_${LEVEL}"

ROOT="$RELEASE"

#false

zfs list system/root/$ROOT && zfs destroy -r system/root/$ROOT || true

zfs create -o mountpoint=/mnt system/root/$ROOT
zfs create system/root/$ROOT/usr
zfs create system/root/$ROOT/usr/local
zfs create -o exec=off -o setuid=off system/root/$ROOT/var
zfs create system/root/$ROOT/var/db
zfs create system/root/$ROOT/var/empty
zfs create system/root/$ROOT/var/log
zfs create system/root/$ROOT/var/mail
zfs create system/root/$ROOT/var/run
zfs create system/root/$ROOT/var/spool
zfs create system/root/$ROOT/var/tmp
chmod 1777 /mnt/var/tmp

cd /mnt
tar pxf $TMPDIR/base.tbz
pw -V etc usermod root -w yes

install -d -v -o root -g wheel -m 0755 usr/local/etc
install -d -v -o root -g wheel -m 0755 usr/local/etc/namedb
install -d -v -o bind -g bind  -m 0755 usr/local/etc/namedb/dynamic

for i in loader.conf zfs/zpool.cache ; do
	cp -pfv /boot/$i boot/$i
done

grep -v ^vfs.root.mountfrom /boot/loader.conf >boot/loader.conf
cat >>boot/loader.conf <<EOF
vfs.root.mountfrom="zfs:system/root/$ROOT"
EOF

for i in hostid fstab src.conf make.conf rc.conf \
	hostapd-wlan2.conf hostapd-wlan3.conf hostapd-wlan5.conf \
	pf.conf hosts nsswitch.conf ntp.conf sysctl.conf \
	syslog.conf netconfig ssh/sshd_config ; do
	cp -pfv /etc/$i etc/$i
done

for i in dhcpd.conf namedb/named.conf namedb/rndc.conf \
	namedb/dynamic/deiter.local.db \
	namedb/dynamic/10.27.172.in-addr.arpa.db ; do
	cp -pfv /usr/local/etc/$i usr/local/etc/$i
done

zfs set readonly=on system/root/$ROOT/var/empty

cd

cat <<EOF
*********************************************************************
zfs umount system/root/$ROOT
zfs set canmount=noauto system/root/$ROOT
zfs set mountpoint=/ system/root/$ROOT
zpool set bootfs=system/root/$ROOT system
zfs set canmount=noauto $(zpool get -H -o value bootfs system)
zfs set canmount=on system/root/$ROOT
*********************************************************************
EOF
