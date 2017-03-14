#!/bin/sh -exu

_script=$(realpath $0)
_base=$(dirname $_script)

. $_base/common.sh

_update_cfg
_update_repos
_mount_fs

case $_hostname in
nostromo)
	_list="bind911 cdrtools git ipmitool isc-dhcp43-server mksh nut perl5 smartmontools tmux vim-lite acme-client postgresql96-server openldap-sasl-server"
	;;
serenity)
	_list="mksh smartmontools tmux vim-lite"
	;;
blackbird)
	_list="mksh smartmontools tmux vim-lite"
	;;
builder)
	_list=""
	;;
mail)
	_list="mksh tmux vim-lite sendmail+tls+sasl2+ldap cyrus-sasl cyrus-sasl-gssapi cyrus-sasl-saslauthd cyrus-imapd25"
	;;
opengrok)
	_list="mksh tmux vim-lite openjdk8 tomcat8 ctags git apache-ant"
	;;
www)
	_list="mksh tmux vim-lite apache24 ap24-mod_auth_kerb2 mod_php71 php71-mcrypt nextcloud"
	;;
*)
	_list="mksh smartmontools tmux vim-lite"
	;;
esac

if [ -n "$_list" ]; then
	ASSUME_ALWAYS_YES=yes pkg bootstrap
	pkg install -y $_list
fi

if [ -x $_local/bin/mksh ]; then
	install -m 0555 -g wheel -o root -v $_local/bin/mksh /bin/ksh
	if ! grep -q /bin/ksh /etc/shells; then
		cat >>/etc/shells <<-EOF
		/bin/ksh
		EOF
	fi
fi

case $_hostname in
nostromo)
	service smartd restart
	service named restart
	service isc-dhcpd restart
	;;
www)
	for _module in rewrite socache_shmcb ssl auth_kerb; do
		apxs -e -a -n $_module libexec/apache24/mod_${_module}.so
	done
	service apache24 restart
	;;
opengrok)
	$_base/update-opengrok.sh
	;;
*)
	;;
esac

_umount_fs
