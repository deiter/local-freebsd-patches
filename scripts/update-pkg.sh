#!/bin/sh -exu

. common.sh

_update_cfg

case $_hostname in
nostromo)
	_list="bind911 cdrtools git ipmitool isc-dhcp43-server mksh nut perl5 smartmontools tmux vim-lite"
	;;
blackbird)
	_list="mksh smartmontools tmux vim-lite"
	;;
mail)
	_list="mksh tmux vim-lite sendmail+tls+sasl2 cyrus-sasl cyrus-sasl-gssapi cyrus-sasl-saslauthd cyrus-imapd25"
	;;
opengrok)
	_list="mksh tmux vim-lite openjdk8 tomcat8 ctags git apache-ant"
	;;
www)
	_list="mksh tmux vim-lite nginx-lite nextcloud"
	;;
*)
	_list="mksh tmux vim-lite"
	;;
esac

pkg install -y $_list

if [ -x $_local/bin/mksh ]; then
	install -m 0555 -g wheel -o root -v $_local/bin/mksh /bin/ksh
	if ! grep -q /bin/ksh /etc/shells; then
		cat >>/etc/shells <<-EOF
		/bin/ksh
		EOF
	fi
fi
