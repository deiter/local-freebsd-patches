#!/bin/sh -exu

_script=$(realpath $0)
_base=$(dirname $_script)

. $_base/common.sh

_deps="ports-mgmt/pkg ports-mgmt/dialog4ports"

_list="lang/perl5.24 sysutils/tmux sysutils/smartmontools sysutils/ipmitool"
_list="$_list dns/bind911 net/isc-dhcp43-server sysutils/nut security/openvpn"
_list="$_list editors/vim-lite sysutils/cdrtools net-p2p/transmission-daemon"
_list="$_list security/ca_root_nss devel/git shells/mksh"
_list="$_list security/cyrus-sasl2 security/cyrus-sasl2-gssapi"
_list="$_list net/openldap24-sasl-client net/openldap24-server"
_list="$_list security/cyrus-sasl2-saslauthd mail/sendmail mail/cyrus-imapd25"
_list="$_list www/tomcat8 devel/ctags devel/apache-ant"
_list="$_list www/apache24 www/mod_auth_kerb2"
_list="$_list lang/php71 www/mod_php71 security/php71-mcrypt"
_list="$_list www/nginx-lite databases/postgresql96-client"
_list="$_list databases/postgresql96-server www/nextcloud"
_list="$_list databases/gdbm misc/compat9x security/acme-client"

if [ ! -d $_ports/.svn ]; then
	install -v -d -m 0755 -g wheel -o root $_ports
	$_svn checkout http://svn.freebsd.org/ports/head $_ports
fi

cd $_ports
_update_svn
_update_cfg

for _file in $(find $_root/patches/ports -type f); do
	if ! cat $_file | $_patch; then
		_exit "Unable to apply patch $_file"
	fi
done

_dir=$_root/files/ports

for _file in $(find $_dir -type f); do
        install -v -m 0644 -g wheel -o root $_file $_ports/${_file#$_dir/}
done

if [ -d /var/cache ]; then
	rm -rf /var/cache
fi

if [ -x $_local/sbin/pkg ]; then
	pkg delete -afy
fi

if [ -d $_obj$_ports ]; then
	rm -rf $_obj$_ports
fi

if [ -d $_pkg ]; then
	rm -rf $_pkg/*
fi

if [ -d $_conf ]; then
	rm -rf $_conf/*
fi

if [ -d $_local ]; then
	find $_local -type f
fi

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
