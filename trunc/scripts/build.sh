#!/bin/sh -xe
#
# $Id$
#

TZ="Europe/Moscow"
TMPDIR="/var/tmp"
ALTDIR="$TMPDIR/alt"
SRCDIR="/usr/src"
OBJDIR="/usr/obj"
SCRIPT=$(realpath $0)
WRKDIR=$(dirname $(dirname $SCRIPT))
JOBS=$(( $(sysctl -n kern.smp.cpus) * 2 ))
KERNCONF=$(hostname -s | tr [a-z] [A-Z])
TARGET=$(uname -m)

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

for i in $WRKDIR/patches/patch-*; do patch -p0 <$i || exit 1; done
for i in make.conf src.conf; do cat $WRKDIR/conf/$i >/etc/$i; done
for i in i386 amd64; do cp $WRKDIR/conf/$i/* $SRCDIR/sys/$i/conf/; done

LEVEL=$(ls $WRKDIR/patches/patch-* | wc -l | awk '{print $NF}')
REVISION=$($SVN info | awk '/^Revision:/{print $2}')
VERSION=$(awk -F'"' '/^REVISION=/{print $2}' $SRCDIR/sys/conf/newvers.sh)
BRANCH=$(awk -F'"' '/^BRANCH=/{print $2}' $SRCDIR/sys/conf/newvers.sh)
export BRANCH_OVERRIDE="${BRANCH}-r${REVISION}-p${LEVEL}"

find . -type f -name '*.orig' -exec rm -fv {} ';'
REJECTED=$(find . -type f -name '*.rej' -exec ls {} ';')
test -n "$REJECTED" && false

rm -rf $OBJDIR/*
make -j $JOBS buildworld
make -j $JOBS buildkernel KERNCONF=$KERNCONF

if [ -d $ALTDIR ]; then
	chflags -R noschg $ALTDIR
	rm -rf $ALTDIR
fi

mkdir -p $ALTDIR

for i in installworld distribution installkernel; do
	make $i DESTDIR=$ALTDIR KERNCONF=$KERNCONF
done

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
hostname="install.deiter.local"
EOF

cat >>boot/loader.conf <<-EOF
beastie_disable="YES"
autoboot_delay="3"
EOF

rm -f $TMPDIR/base.tbz
tar pcfy $TMPDIR/base.tbz .

# ISO
#cat >>etc/rc.conf <<-EOF
#root_rw_mount="NO"
#EOF
#
#cat >>boot/loader.conf <<-EOF
#boot_cdrom="YES"
#EOF

#mv $TMPDIR/base.tbz media
#mkisofs -b boot/cdboot -no-emul-boot -r -J \
#	-V "${TARGET}-${VERSION}-${BRANCH_OVERRIDE}" \
#	-o $TMPDIR/FreeBSD-${TARGET}-${VERSION}-${BRANCH_OVERRIDE}.iso .
