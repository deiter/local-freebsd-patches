#!/bin/sh -exu
#
# $Id$
#

TZ="Europe/Moscow"
TMPDIR="/var/tmp"
ALTDIR="$TMPDIR/arm"
SRCDIR="/usr/src"
OBJDIR="/usr/obj"
SCRIPT=$(realpath $0)
WRKDIR=$(dirname $(dirname $SCRIPT))
JOBS=$(( $(sysctl -n kern.smp.cpus) * 4 ))
KERNCONF=RADXA
IMAGE=$TMPDIR/$KERNCONF.img

if [ -x /usr/bin/svnlite ]; then
	SVN=/usr/bin/svnlite
elif [ -x /usr/bin/svn ]; then
	SVN=/usr/bin/svn
else
	echo "svn not found"
	exit 1
fi

if [ ! -d $SRCDIR/.svn ]; then
	mkdir -p $SRCDIR
	$SVN checkout http://svn.freebsd.org/base/head $SRCDIR
fi

cd $SRCDIR
$SVN cleanup
$SVN revert -R .
rm -rf sys/dev/viatemp sys/modules/viatemp
$SVN diff
$SVN status
$SVN up

for i in $WRKDIR/patches/patch-arm*; do patch -p0 <$i || exit 1; done
read f
#for i in make.conf src.conf; do cat $WRKDIR/conf/$i >/etc/$i; done
#for i in i386 amd64; do cp $WRKDIR/conf/$i/* $SRCDIR/sys/$i/conf/; done

LEVEL=$(ls $WRKDIR/patches/patch-* | wc -l | awk '{print $NF}')
REVISION=$($SVN info | awk '/^Last\ Changed\ Rev:/{print $NF}')
VERSION=$(awk -F'"' '/^REVISION=/{print $2}' $SRCDIR/sys/conf/newvers.sh)
BRANCH=$(awk -F'"' '/^BRANCH=/{print $2}' $SRCDIR/sys/conf/newvers.sh)
export BRANCH_OVERRIDE="${BRANCH}-r${REVISION}-p${LEVEL}"

find . -type f -name '*.orig' -exec rm -fv {} ';'
REJECTED=$(find . -type f -name '*.rej' -exec ls {} ';')
test -n "$REJECTED" && false

rm -rf $OBJDIR/*
make -j $JOBS TARGET_ARCH=armv6 kernel-toolchain
make -j $JOBS TARGET_ARCH=armv6 KERNCONF=$KERNCONF buildkernel
make -j $JOBS TARGET_ARCH=armv6 buildworld

if [ -d $ALTDIR ]; then
	umount $ALTDIR || true
	mdconfig -d -u0 || true
	chflags -R noschg $ALTDIR
	rm -rf $ALTDIR
fi

rm -f $IMAGE
truncate -s 1024M $IMAGE
mdconfig -f $IMAGE -u0
newfs /dev/md0
mkdir -p $ALTDIR
mount /dev/md0 $ALTDIR

make TARGET_ARCH=armv6 DESTDIR=$ALTDIR KERNCONF=$KERNCONF installworld distribution installkernel

cd $ALTDIR
install -v -o root -g wheel -m 0644 /dev/null etc/fstab
install -v -o root -g wheel -m 0444 usr/share/zoneinfo/$TZ etc/localtime
install -v -o root -g wheel -m 0444 /dev/null etc/wall_cmos_clock
echo $TZ >var/db/zoneinfo
mv COPYRIGHT etc/COPYRIGHT
cat /dev/null >etc/COPYRIGHT
cat /dev/null >etc/motd

cat >etc/host.conf <<-EOF
hosts
dns
EOF

cat >etc/rc.conf <<-EOF
cron_enable="NO"
sendmail_enable="NONE"
fsck_y_enable="YES"
background_fsck="NO"
blanktime="NO"
update_motd="NO"
entropy_file="NO"
dumpdev="NO"
hostname="arm.deiter.ru"
EOF

sync; sync; sync
umount $ALTDIR
mdconfig -d -u0
