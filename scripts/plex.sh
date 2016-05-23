#!/bin/sh -eu

if [ $# -ne 2 ]; then
	echo "$0 <destination_dir> <plex_tarball_url>"
	exit 1
fi

_dir="$1"
_url="$2"

_tarball=$(basename $_url)
_dst=$(basename -s -freebsd-amd64.tar.bz2 $_tarball)

test -d "$_dir" || mkdir -p "$_dir"
cd "$_dir"

fetch "$_url"
tar pxf $_tarball

test -d $_dst
chown -R root:wheel $_dst
find $_dst/Resources -name '*.so' -exec strip -p {} ';'
strip -p $_dst/Resources/rsync $_dst/Resources/Python/bin/python
chmod 0111 $_dst/Plex* $_dst/Resources/rsync $_dst/Resources/Plex* $_dst/Resources/Python/bin/python
chmod 0644 $_dst/Resources/*.db

install -d -v -m 0755 -g wheel -o root bin dev etc lib libexec plex var var/run var/log
install -d -v -m 1777 -g wheel -o root var/tmp tmp
install -d -v -m 0750 -g plex -o plex data var/log/plex var/run/plex
install -v -m 0555 -g wheel -o root /libexec/ld-elf.so.1 libexec/ld-elf.so.1
install -v -m 0111 -g wheel -o root /usr/sbin/daemon bin/daemon
install -v -m 0111 -g wheel -o root /usr/sbin/nologin bin/nologin
install -v -m 0444 -g wheel -o root /etc/localtime etc/localtime

mv $_dst/Resources $_dst/Plex* plex
mv $_dst/lib* lib
chmod 0444 lib/*
ln -s Plex\ Media\ Server plex/Plex_Media_Server
ln -s libpython2.7.so.1 lib/libpython2.7.so

ls -l $_dst
read f
rm -rf $_dst $_tarball

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
	test -f lib/$_lib && continue
        _path=$(find /lib /usr/lib /usr/local/lib -name $_lib | head -1)
        if [ -z "$_path" ]; then
                echo "$_lib: library not found"
		continue
        fi

	install -v -m 0444 -g wheel -o root $_path lib/$_lib
done

ldconfig -s -f var/run/ld-elf.so.hints lib

cat >etc/master.passwd <<-EOF
root:*:0:0::0:0:root:/:/bin/nologin
plex:*:972:972:plex:0:0:Plex Media Server:/data/Plex Media Server:/bin/nologin
EOF

pwd_mkdb -p -d etc etc/master.passwd

cat >etc/group <<-EOF
wheel:*:0:root
plex:*:972:
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

plex:\
	:setenv=PLEX_MEDIA_SERVER_HOME=/plex,PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS=6,PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR=/data,PLEX_MEDIA_SERVER_LOG_DIR=/var/log/plex,PLEX_MEDIA_SERVER_PIDFILE=/var/run/plex/plex.pid,PLEX_MEDIA_SERVER_TMPDIR=/var/tmp,PYTHONHOME=/plex/Resources/Python,TMPDIR=/var/tmp,LC_ALL=en_US.UTF-8:\
	:charset=UTF-8:\
	:lang=en_US.UTF-8:\
	:path=/bin /plex /plex/Resources/Python/bin:\
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

chflags -R simmutable bin etc lib libexec plex var/run/ld-elf.so.hints
