#!/bin/sh -xe
#
# $Id$
#

DEVEL=/var/devel
ALT=$DEVEL/alt
SRC=/usr/src
JOBS=$(sysctl -n kern.smp.cpus)

cd $SRC
find . -type f -name '*.orig' -delete
svn revert -R .
svn diff
svn status
read x
svn up

for i in $DEVEL/patches/patch-*; do patch -p0 <$i || exit 1; done
LEVEL=$(ls $DEVEL/patches/patch-* | wc -l | awk '{print $NF}')
REVISION=$(svn info | awk '/^Revision:/{print $2}')
export BRANCH_OVERRIDE="CURRENT-r${REVISION}-p${LEVEL}"

read x
find . -type f -name '*.orig'
find . -type f -name '*.orig' -delete
read x

rm -rf /usr/obj/*
make -j $JOBS buildworld
make -j $JOBS buildkernel

if [ -d $ALT ]; then
	chflags -R noschg $ALT
	rm -rf $ALT
fi

mkdir -p $ALT

for i in installworld distribution installkernel; do
	make $i DESTDIR=$ALT
done

cd $ALT
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
root_rw_mount="NO"
hostid_enable="NO"
hostname="cdrom.deiter.ru"
EOF

cat >>boot/loader.conf <<-EOF
boot_cdrom="YES"
beastie_disable="YES"
autoboot_delay="3"
EOF

mkdir -p dist
cd dist
cp -pR $DEVEL/patches .
cp -pR /root/bin .
cp /etc/src.conf /etc/make.conf .
cp $SRC/sys/amd64/conf/LENOVO* $SRC/sys/amd64/conf/B* .

mkisofs -b boot/cdboot -no-emul-boot -r -J -V "$BRANCH_OVERRIDE" -o ../FreeBSD-10-$BRANCH_OVERRIDE.iso .
