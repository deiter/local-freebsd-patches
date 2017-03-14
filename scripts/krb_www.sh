#!/bin/sh -eu

_keytab="/etc/www.keytab"
_tmp="/export/jails/www/tmp"
_cache="$_tmp/krb5cc_80"

if /sbin/mount -p | /usr/bin/awk '{print $2}' | /usr/bin/grep -q "^$_tmp$"; then
	/usr/bin/su -m www -c "/usr/bin/kinit --keytab=$_keytab --cache=$_cache www"
fi
