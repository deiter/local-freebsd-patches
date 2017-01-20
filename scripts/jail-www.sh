#!/bin/sh -exu

. common.sh

_jail="www"
_parent="alien/jails"
_dataset="$_parent/$_jail"

jls -j $_jail && jail -rv $_jail || true
zfs list $_dataset && zfs destroy -rf $_dataset || true
zfs create $_dataset

_dst=$(zfs get -H -o value mountpoint $_dataset)
test -d "$_dst" || exit 1
make -C $_src DESTDIR=$_dst KERNCONF=$_kernel installworld distribution installkernel >$_dst/install.log 2>&1

cd $_dst
install -v -o root -g wheel -m 0644 /dev/null etc/fstab
install -v -o root -g wheel -m 0444 /dev/null etc/wall_cmos_clock
install -v -o root -g wheel -m 0444 usr/share/zoneinfo/$_tz etc/localtime
echo $_tz >var/db/zoneinfo

cat >etc/rc.conf <<EOF
rc_startmsgs="NO"
rc_debug="NO"
rc_info="NO"
cron_enable="NO"
sshd_enable="NO"
sendmail_enable="NONE"
fsck_y_enable="YES"
background_fsck="NO"
update_motd="NO"
dumpdev="NO"
hostname="www.deiter.local"
ifconfig_www1="inet 172.27.10.25/24"
defaultrouter="172.27.10.1"
php_fpm_enable="YES"
nginx_enable="YES"
EOF

cat >etc/hosts <<EOF
127.0.0.1	localhost.deiter.local	localhost
172.27.10.25	www.deiter.local	www
EOF

cat >etc/resolv.conf <<EOF
search deiter.local
nameserver 172.27.10.2
EOF

cat >root/.k5login <<EOF
tiamat@DEITER.LOCAL
EOF

#kadmin -l ext_keytab --keytab=etc/krb5.keytab host/www.deiter.local
install -v -d -m 0755 -g wheel -o root usr/local/etc/pkg/repos

cat >usr/local/etc/pkg/repos/FreeBSD.conf <<EOF
FreeBSD: {
	enabled: no
}
EOF

cat >usr/local/etc/pkg/repos/local.conf <<EOF
local: {
	url: "file:///var/devel/pkg",
	enabled: yes
}
EOF

_list=$(awk '/^\//{print $1}' /etc/fstab.www | sort)
for _fs in $_list; do
	install -v -d -m 0755 -g wheel -o root $_dst$_fs
done

exit 0
