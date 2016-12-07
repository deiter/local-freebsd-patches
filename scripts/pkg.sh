#!/bin/sh -exu

_host=$(hostname -s)
_list='mksh tmux ipmitool nut smartmontools vim-lite'

case $_host in
nostromo)
	_list="$_list bind911 isc-dhcp43-server git"
	;;
*)
	;;
esac

pkg install -y $_list
if [ -x /usr/local/bin/mksh ]; then
	install -m 0555 -g wheel -o root -v /usr/local/bin/mksh /bin/ksh
fi
