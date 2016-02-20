#!/bin/sh -exu

_portsdir=/usr/ports
_script=$(realpath $0)
_workdir=$(dirname $(dirname $_script))

_portslist="lang/perl5.22 sysutils/tmux sysutils/smartmontools sysutils/ipmitool dns/bind910 net/isc-dhcp43-server sysutils/nut security/openvpn net-p2p/transmission-daemon editors/vim-lite net/samba36 multimedia/plexmediaserver-plexpass"

if [ -x /usr/bin/svnlite ]; then
	_svn=/usr/bin/svnlite
elif [ -x /usr/bin/svn ]; then
	_svn=/usr/bin/svn
elif [ -x /usr/local/bin/svn ]; then
	_svn=/usr/local/bin/svn
else
	echo "svn not found"
	exit 1
fi

if [ ! -d $_portsdir/.svn ]; then
	mkdir -p $_portsdir
	$_svn checkout http://svn.freebsd.org/ports/head $_portsdir
fi

cd $_portsdir
$_svn status
$_svn status | awk '/^\?/{print $NF}' | xargs rm -rf
$_svn cleanup
$_svn revert -R .
$_svn diff
$_svn status
$_svn up

for i in $_workdir/patches/patch-*; do
        patch -p0 <$i || exit 1
done

_rejected=$(find . -type f -name '*.rej' -ls ';')
test -n "$_rejected" && false

cp -pR $_workdir/ports/* $_portsdir

read f

for i in $_portslist; do
	cd $_portsdir/$i && make clean config-recursive fetch-recursive install package
done

pkg remove -yx automake autoconf bash binutils bison cmake gmake help2man gmp indexinfo \
	patch texi2html texinfo m4 mpfr nasm yasm python
