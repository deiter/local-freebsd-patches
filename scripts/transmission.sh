#!/bin/sh -eu

if [ $# -ne 1 ]; then
	echo "$0 <destination_dir>"
	exit 1
fi

_dir="$1"

test -d "$_dir" || mkdir -p "$_dir"
cd "$_dir"

install -d -m 0755 -g wheel -o root -v bin dev etc lib libexec var var/db var/log var/run
install -d -m 1777 -g wheel -o root -v var/tmp tmp
install -d -m 0750 -g transmission -o transmission -v var/db/transmission var/run/transmission var/log/transmission
install -m 0555 -g wheel -o root -v /libexec/ld-elf.so.1 libexec/ld-elf.so.1
install -m 0111 -g wheel -o root -v /usr/sbin/daemon bin/daemon
install -m 0111 -g wheel -o root -v /usr/sbin/nologin bin/nologin
install -m 0444 -g wheel -o root -v /etc/localtime etc/localtime

install -m 0111 -g wheel -o root -v /usr/local/bin/transmission-daemon bin/transmission
cp -pR /usr/local/share/transmission/web var/db
chown -R root:wheel var/db/web
find var/db/web -type d -exec chmod 0755 {} ';'
find var/db/web -type f -exec chmod 0444 {} ';'


for _file in $(find . -type f); do
	_type=$(file -b $_file)
	case $_type in
	ELF*)
		;;
	*)
		continue
		;;
	esac

	ldd $_file >/dev/null 2>&1 || continue
	ldd -a $_file | grep -v ':$' | awk '{print $1}'
done | sort | uniq | while read _lib; do
        _path=$(find /lib /usr/lib /usr/local/lib -name $_lib | head -1)
        if [ -z "$_path" ]; then
                echo "$_lib: library not found"
		continue
        fi

	install -m 0444 -g wheel -o root -v $_path lib/$_lib
done

ldconfig -s -f var/run/ld-elf.so.hints lib

cat >etc/master.passwd <<-EOF
root:*:0:0::0:0:root:/:/bin/nologin
transmission:*:921:921:transmission:0:0:Transmission Daemon User:/var/db/transmission:/bin/nologin
EOF

pwd_mkdb -p -d etc etc/master.passwd

cat >etc/group <<-EOF
wheel:*:0:root
transmission:*:921:
EOF

cat >etc/login.conf <<-EOF
default:\
	:path=/bin:\
	:cputime=unlimited:\
	:datasize=unlimited:\
	:stacksize=unlimited:\
	:memorylocked=64K:\
	:memoryuse=unlimited:\
	:filesize=unlimited:\
	:coredumpsize=unlimited:\
	:openfiles=unlimited:\
	:maxproc=unlimited:\
	:sbsize=unlimited:\
	:vmemoryuse=unlimited:\
	:swapuse=unlimited:\
	:pseudoterminals=unlimited:\
	:kqueues=unlimited:\
	:umtxp=unlimited:\
	:priority=0:\
	:ignoretime@:\
	:umask=022:

transmission:\
	:setenv=TRANSMISSION_HOME=/var/db/transmission,TRANSMISSION_WEB_HOME=/var/db/web,TMPDIR=/var/tmp,LC_ALL=en_US.UTF-8:\
	:charset=UTF-8:\
	:lang=en_US.UTF-8:\
	:tc=default:
EOF

cap_mkdb etc/login.conf

cat >etc/resolv.conf <<-EOF
search deiter.local
nameserver 172.27.10.2
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

cat >etc/nsswitch.conf <<-EOF
group: files
hosts: files dns
networks: files
passwd: files
shells: files
services: files
protocols: files
rpc: files
EOF

chflags -R simmutable bin etc lib libexec var/db/web var/run/ld-elf.so.hints
