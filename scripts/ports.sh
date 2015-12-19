#!/bin/sh -exu
#
# $Id$
#

PORTSDIR=/usr/ports
SCRIPT=$(realpath $0)
WRKDIR=$(dirname $(dirname $SCRIPT))

PORTS="lang/perl5.22 devel/m4 sysutils/tmux sysutils/smartmontools sysutils/ipmitool dns/bind910 net/isc-dhcp43-server sysutils/nut security/openvpn net-p2p/transmission-daemon editors/vim-lite net/samba36 multimedia/plexmediaserver-plexpass"

# multimedia/ffmpegthumbnailer net/minidlna net/samba36"

if [ -x /usr/bin/svnlite ]; then
	SVN=/usr/bin/svnlite
elif [ -x /usr/bin/svn ]; then
	SVN=/usr/bin/svn
else
	echo "svn not found"
	exit 1
fi

if [ ! -d $PORTSDIR/.svn ]; then
	mkdir -p $PORTSDIR
	$SVN checkout http://svn.freebsd.org/ports/head $PORTSDIR
fi

cd $PORTSDIR
$SVN status
$SVN status | awk '/^\?/{print $NF}' | xargs rm -rf
$SVN cleanup
$SVN revert -R .
$SVN diff
$SVN status
$SVN up

patch -p0 < $WRKDIR/ports/patch.diff
REJECTED=$(find . -type f -name '*.rej' -exec ls {} ';')
test -n "$REJECTED" && false

cp -pR $WRKDIR/ports/* $PORTSDIR

read f

for i in $PORTS; do
	cd $PORTSDIR/$i && make clean config-recursive fetch-recursive install clean
done

pkg remove -yx automake autoconf bash binutils bison cmake gmake help2man gmp indexinfo patch texi2html texinfo m4 mpfr nasm yasm python
