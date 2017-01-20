#!/bin/sh -exu

##root@builder:/var/devel/ports/security/py-certbot # make  TEST_DEPENDS='' package package-recursive

. common.sh

_deps="ports-mgmt/pkg ports-mgmt/dialog4ports"

_list="lang/perl5.24 sysutils/tmux sysutils/smartmontools sysutils/ipmitool"
_list="$_list dns/bind911 net/isc-dhcp43-server sysutils/nut security/openvpn"
_list="$_list editors/vim-lite sysutils/cdrtools net-p2p/transmission-daemon"
_list="$_list databases/gdbm misc/compat9x devel/git shells/mksh"
_list="$_list security/cyrus-sasl2 security/cyrus-sasl2-gssapi"
_list="$_list net/openldap24-sasl-client net/openldap24-server"
_list="$_list security/cyrus-sasl2-saslauthd mail/sendmail mail/cyrus-imapd25"
_list="$_list www/tomcat8 devel/ctags devel/apache-ant"
_list="$_list www/nginx-lite databases/postgresql96-client"
_list="$_list databases/postgresql96-server www/nextcloud"

if [ ! -d $_ports/.svn ]; then
	install -v -d -m 0755 -g wheel -o root $_ports
	$_svn checkout http://svn.freebsd.org/ports/head $_ports
fi

cd $_ports
_update_svn
_update_cfg

for _diff in $_root/ports/patches/patch-*; do
	$_patch <$_diff || exit 1
done

cd $_root/ports
for _dir in *; do
	test -f "$_dir" && continue
	test "$_dir" = "patches" && continue
	cp -pR $_dir $_ports
done

rm -rf /var/cache/pkg/*
test -x $_local/sbin/pkg && $_local/sbin/pkg delete -afy
test -d $_obj$_ports && rm -rf $_obj$_ports
test -d $_pkg && rm -rf $_pkg/*
test -d $_conf && rm -rf $_conf/*
test -d $_local && find $_local -type f

for _port in $_deps $_list; do
	cd $_ports/$_port && make clean
done

for _port in $_deps; do
	cd $_ports/$_port && make install && make package && make package-recursive
done

for _port in $_list; do
	cd $_ports/$_port && make config && make config-recursive
done

for _port in $_list; do
	cd $_ports/$_port && make install && make package && make package-recursive
done

pkg repo $_pkg

exit 0

pkg remove -yx automake autoconf bash binutils bison cmake gmake help2man gmp indexinfo \
	patch texi2html texinfo m4 mpfr nasm yasm python makedepend xproto xorg-macros \
	pkgconf
