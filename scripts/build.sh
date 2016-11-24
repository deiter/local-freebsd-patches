#!/bin/sh -exu

. common.sh

if [ $# -eq 1 ]; then
	_kernel="$1"
fi

if [ ! -d $_src/.svn ]; then
	install -v -d -m 0755 -g wheel -o root $_src
	$_svn checkout http://svn.freebsd.org/base/head $_src
fi

cd $_src
_update_svn
_update_cfg 

for _diff in $_root/patches/patch-*; do
	$_patch <$_diff || exit 1
done

for _arch in i386 amd64; do
	for _cfg in $_root/conf/$_arch/*; do
		_name=$(basename $_cfg)
		install -v -m 0644 -g wheel -o root $_cfg $_src/sys/$_arch/conf/$_name
	done
done

if [ ! -r $_root/conf/$_target/$_kernel ]; then
	exit 1
fi

_level=$(ls $_root/patches/patch-* | awk 'END {print NR}')
_revision=$($_svn info | awk '/^Last\ Changed\ Rev:/{print $NF}')
_version=$(awk -F'"' '/^REVISION=/{print $2}' $_src/sys/conf/newvers.sh)
_branch=$(awk -F'"' '/^BRANCH=/{print $2}' $_src/sys/conf/newvers.sh)
_triplet="${_branch}-r${_revision}-p${_level}"
_label="${_osname}-${_version}-${_target}-$_triplet"
_dst="$_stage/$_label"

export BRANCH_OVERRIDE="$_triplet"

test -d $_obj$_src && rm -rf $_obj$_src
test -d $_dst && rm -rf $_dst

make -j $_jobs buildworld buildkernel
make DESTDIR=$_dst KERNCONF=$_kernel installworld distribution installkernel

cd $_dst
install -v -o root -g wheel -m 0644 /dev/null etc/fstab
install -v -o root -g wheel -m 0444 /dev/null etc/wall_cmos_clock
install -v -o root -g wheel -m 0444 usr/share/zoneinfo/$_tz etc/localtime
echo $_tz >var/db/zoneinfo

cat >etc/nsswitch.conf <<EOF
group: files
hosts: files dns
networks: files
passwd: files
shells: files
services: files
protocols: files
rpc: files
EOF

cat >etc/host.conf <<EOF
hosts
dns
EOF

cat >etc/rc.conf <<EOF
rc_startmsgs="NO"
rc_debug="NO"
rc_info="NO"
cron_enable="NO"
sendmail_enable="NONE"
fsck_y_enable="YES"
background_fsck="NO"
update_motd="NO"
dumpdev="NO"
hostname="install.deiter.local"
EOF

cat >boot/loader.conf <<EOF
beastie_disable="YES"
autoboot_delay="3"
EOF

rm -f ../$_label.tbz
tar pcfy ../$_label.tbz .

test -z "$_mkisofs" && exit 0

cat >>etc/rc.conf <<EOF
hostid_file="/var/db/hostid"
entropy_file="NO"
entropy_boot_file="NO"
hostid_enable="NO"
root_rw_mount="NO"
EOF

cat >>boot/loader.conf <<EOF
boot_cdrom="YES"
EOF

cp ../$_label.tbz media
cp -pR $_root media

rm -f ../$_label.iso
$_mkisofs -b boot/cdboot -no-emul-boot -r -J -o ../$_label.iso .

exit 0
