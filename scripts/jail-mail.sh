#!/bin/sh -exu

. common.sh

_jail="mail"
_parent="alien/jails"
_dataset="$_parent/$_jail"

jls -j $_jail && jail -rv $_jail || true
zfs list $_dataset && zfs destroy -rf $_dataset || true
zfs create $_dataset

_dst=$(zfs get -H -o value mountpoint $_dataset)
test -d "$_dst" || exit 1

make -C $_src/etc MK_MAILWRAPPER=yes MK_MAIL=yes MK_SENDMAIL=yes obj depend all
make -C $_src/usr.sbin/mailwrapper MK_MAILWRAPPER=yes obj depend all
make -C $_src DESTDIR=$_dst KERNCONF=$_kernel installworld distribution installkernel >$_dst/install.log 2>&1
make -C $_src/usr.sbin/mailwrapper DESTDIR=$_dst MK_MAILWRAPPER=yes install >>$_dst/install.log 2>&1
make -C $_src DESTDIR=$_dst KERNCONF=$_kernel MK_MAIL=yes MK_SENDMAIL=yes MK_MAILWRAPPER=yes distribution >>$_dst/install.log 2>&1

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
sendmail_enable="YES"
fsck_y_enable="YES"
background_fsck="NO"
update_motd="NO"
dumpdev="NO"
hostname="mail.deiter.local"
ifconfig_mail1="inet 172.27.10.24/24"
defaultrouter="172.27.10.1"
EOF

cat >etc/hosts <<EOF
127.0.0.1	localhost.deiter.local	localhost
172.27.10.24	mail.deiter.local	mail
EOF

cat >etc/resolv.conf <<EOF
search deiter.local
nameserver 172.27.10.2
EOF

cat >etc/mail/mailer.conf <<EOF
sendmail	/usr/local/sbin/sendmail
send-mail	/usr/local/sbin/sendmail
mailq		/usr/local/sbin/sendmail
newaliases	/usr/local/sbin/sendmail
hoststat	/usr/local/sbin/sendmail
purgestat	/usr/local/sbin/sendmail
EOF

install -v -d -m 0755 -g wheel -o root usr/local/etc/pkg/repos
install -v -d -m 0755 -g wheel -o root var/devel/pkg
install -v -d -m 0755 -g wheel -o root var/devel/local

cat >usr/local/etc/pkg/repos/FreeBSD.conf <<EOF
FreeBSD: { enabled: no }
EOF

cat >usr/local/etc/pkg/repos/local.conf <<EOF
local: {
	url: "file:///var/devel/pkg",
	enabled: yes
}
EOF

pkg -r $_dst install -y pkg mksh sendmail+tls+sasl2 cyrus-sasl cyrus-sasl-gssapi

exit 0
