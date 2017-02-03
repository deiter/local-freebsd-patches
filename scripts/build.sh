#!/bin/sh -exu

_script=$(realpath $0)
_base=$(dirname $_script)

. $_base/common.sh

if [ $# -eq 1 ]; then
	_kernel=$1
fi

if [ ! -d $_src/.svn ]; then
	install -v -d -m 0755 -g wheel -o root $_src
	$_svn checkout http://svn.freebsd.org/base/head $_src
fi

cd $_src
_update_svn
_update_cfg 

for _file in $(find $_root/patches/src -type f); do
	if ! cat $_file | $_patch; then
		_exit "Unable to apply patch $_file"
	fi
done

_dir=$_root/files/src

for _file in $(find $_dir -type f); do
	install -v -m 0644 -g wheel -o root $_file $_src/${_file#$_dir/}
done

if [ ! -r $_src/sys/$_target/conf/$_kernel ]; then
	_exit "Kernel config file $_kernel not found"
fi

_level=$(ls $_root/patches/src | awk 'END {print NR}')
_revision=$($_svn info --show-item revision)
_version=$(awk -F'"' '/^REVISION=/{print $2}' $_src/sys/conf/newvers.sh)
_branch=$(awk -F'"' '/^BRANCH=/{print $2}' $_src/sys/conf/newvers.sh)
_triplet="${_branch}-r${_revision}-p${_level}"
_label="${_osname}-${_version}-${_target}-$_triplet"
_dst="$_stage/$_label"

export BRANCH_OVERRIDE="$_triplet"

if [ ! -d $_obj ]; then
	install -v -d -m 0755 -g wheel -o root $_obj
fi

if [ -d $_obj$_src ]; then
	rm -rf $_obj$_src
fi

if [ -d $_dst ]; then
	chflags -R noschg $_dst
	rm -rf $_dst
fi

make -j $_jobs buildworld buildkernel >/tmp/build.log 2>&1
make DESTDIR=$_dst KERNCONF=$_kernel installworld distribution installkernel >/tmp/install.log 2>&1

cd $_dst
install -v -o root -g wheel -m 0644 /dev/null etc/fstab
install -v -o root -g wheel -m 0444 /dev/null etc/wall_cmos_clock
install -v -o root -g wheel -m 0444 usr/share/zoneinfo/$_tz etc/localtime

cat >var/db/zoneinfo <<EOF
$_tz
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
hostname="install.$_domain"
EOF

cat >boot/loader.conf <<EOF
beastie_disable="YES"
autoboot_delay="3"
EOF

rm -f $_stage/$_label.tbz $_stage/latest.tbz
tar pcfy $_stage/$_label.tbz .
ln -s $_label.tbz $_stage/latest.tbz

if [ -z "$_mkisofs" ]; then
	exit 0
fi

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

cp $_stage/$_label.tbz media/base.tbz
cp -pR $_root media/devel

rm -f $_stage/$_label.iso
$_mkisofs -b boot/cdboot -no-emul-boot -r -J -o $_stage/$_label.iso .
