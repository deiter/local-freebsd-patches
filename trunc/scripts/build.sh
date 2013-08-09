#!/bin/sh -xe
#
# $Id$
#

DEVDIR="/var/devel"
ALTDIR="$DEVDIR/alt"
SRCDIR="/usr/src"
OBJDIR="/usr/obj"
JOBS=$(sysctl -n kern.smp.cpus)
KERNCONF=$(hostname -s | tr [a-z] [A-Z])
TARGET=$(uname -m)

cd $SRCDIR
find . -type f -name '*.orig' -delete
svn revert -R .
svn diff
svn status
svn up

for i in $DEVDIR/patches/patch-*; do patch -p0 <$i || exit 1; done
LEVEL=$(ls $DEVDIR/patches/patch-* | wc -l | awk '{print $NF}')
REVISION=$(svn info | awk '/^Revision:/{print $2}')
VERSION=$(awk -F'"' '/^REVISION=/{print $2}' $SRCDIR/sys/conf/newvers.sh)
BRANCH=$(awk -F'"' '/^BRANCH=/{print $2}' $SRCDIR/sys/conf/newvers.sh)
export BRANCH_OVERRIDE="${BRANCH}-r${REVISION}-p${LEVEL}"

find . -type f -name '*.orig'
find . -type f -name '*.orig' -delete
read x

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
install -v -o root -g wheel -m 0444 usr/share/zoneinfo/Europe/Moscow etc/localtime
install -v -o root -g wheel -m 0444 /dev/null etc/wall_cmos_clock
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
powerd_enable="YES"
powerd_flags="-a adaptive"
fsck_y_enable="YES"
background_fsck="NO"
blanktime="NO"
update_motd="NO"
entropy_file="NO"
hostname="install.deiter.ru"
EOF

cat >>boot/loader.conf <<-EOF
beastie_disable="YES"
autoboot_delay="3"
EOF

rm -f $DEVDIR/base.tbz
tar pcfy $DEVDIR/base.tbz .

cat >>etc/rc.conf <<-EOF
root_rw_mount="NO"
hostid_file="/var/db/hostid"
EOF

cat >>boot/loader.conf <<-EOF
boot_cdrom="YES"
EOF

mv $DEVDIR/base.tbz media
mkisofs -b boot/cdboot -no-emul-boot -r -J \
	-V "${TARGET}-${VERSION}-${BRANCH_OVERRIDE}" \
	-o $DEVDIR/FreeBSD-${TARGET}-${VERSION}-${BRANCH_OVERRIDE}.iso .
