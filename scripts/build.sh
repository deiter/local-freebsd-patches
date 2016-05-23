#!/bin/sh -xeu

if [ $# -eq 0 ]; then
	_kernconf=$(uname -i)
else
	_kernconf="$1"
fi

_tz='Europe/Moscow'
_tmpdir='/var/tmp'
_srcdir='/usr/src'
_objdir='/usr/obj'

_osname=$(uname -o)
_target=$(uname -m)
_script=$(realpath $0)
_bindir=$(dirname $_script)
_svndir=$(dirname $_bindir)
_jobs=$(sysctl -n kern.smp.cpus)
_template=$(echo $_kernconf-$_target | tr '[:upper:]' '[:lower:]')
_dstdir=$(TMPDIR=$_tmpdir mktemp -d -t $_template)

if [ -x /usr/bin/svnlite ]; then
	_svn=/usr/bin/svnlite
elif [ -x /usr/bin/svn ]; then
	_svn=/usr/bin/svn
elif [ -x /usr/local/bin/svn ]; then
	_svn=/usr/local/bin/svn
else
	exit 1
fi

if [ ! -r $_svndir/conf/$_target/$_kernconf ]; then
	exit 1
fi

if [ ! -d $_srcdir/.svn ]; then
	mkdir -p $_srcdir
	$_svn checkout http://svn.freebsd.org/base/head $_srcdir
fi

cd $_srcdir
rm -rf sys/dev/viatemp sys/modules/viatemp
$_svn cleanup
$_svn revert -R .
$_svn diff
$_svn status
$_svn up

read f

for i in $_svndir/patches/patch-*; do
	patch -p0 <$i || exit 1
done

for i in make.conf src.conf; do
	cat $_svndir/conf/$i >/etc/$i
done

for i in i386 amd64; do
	cp $_svndir/conf/$i/* $_srcdir/sys/$i/conf/
done

_plevel=$(ls $_svndir/patches/patch-* | wc -l | awk '{print $NF}')
_revision=$($_svn info | awk '/^Last\ Changed\ Rev:/{print $NF}')
_version=$(awk -F'"' '/^REVISION=/{print $2}' $_srcdir/sys/conf/newvers.sh)
_branch=$(awk -F'"' '/^BRANCH=/{print $2}' $_srcdir/sys/conf/newvers.sh)

export BRANCH_OVERRIDE="${_branch}-r${_revision}-p${_plevel}"

_label="${_osname}-${_version}-${_target}-${BRANCH_OVERRIDE}"

find . -type f -name '*.orig' -exec rm -fv {} ';'
_rejected=$(find . -type f -name '*.rej' -exec ls {} ';')

if [ -n "$_rejected" ]; then
	exit 1
fi

cd $_objdir
rm -rf *

cd $_srcdir
make -j $_jobs buildworld
for _config in NOSTROMO SERENITY BLACKBIRD; do
	make -j $_jobs buildkernel KERNCONF=$_config
done

make DESTDIR=$_dstdir installworld
make DESTDIR=$_dstdir distribution
make DESTDIR=$_dstdir KERNCONF=$_kernconf installkernel

cd $_dstdir
install -v -o root -g wheel -m 0644 /dev/null etc/fstab
install -v -o root -g wheel -m 0444 /dev/null etc/wall_cmos_clock
install -v -o root -g wheel -m 0444 usr/share/zoneinfo/$_tz etc/localtime
echo $_tz >var/db/zoneinfo
rm -f COPYRIGHT

cat >etc/host.conf <<-EOF
hosts
dns
EOF

cat >etc/rc.conf <<-EOF
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

cat >>boot/loader.conf <<-EOF
beastie_disable="YES"
autoboot_delay="3"
EOF

rm -f $_tmpdir/$_label.tbz $_tmpdir/base.tbz
tar pcfy $_tmpdir/$_label.tbz .
ln -s $_tmpdir/$_label.tbz $_tmpdir/base.tbz

# cat >>etc/rc.conf <<-EOF
# hostid_file="/var/db/hostid"
# entropy_file="NO"
# entropy_boot_file="NO"
# hostid_enable="NO"
# root_rw_mount="NO"
# EOF

# cat >>boot/loader.conf <<-EOF
# boot_cdrom="YES"
# EOF

# cp $_tmpdir/base.tbz media
# cp -pR $_svndir media

# rm -f $_tmpdir/$_label.iso
# mkisofs -b boot/cdboot -no-emul-boot -r -J -o $_tmpdir/$_label.iso .
