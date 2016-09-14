#!/bin/sh -eu

if [ $# -ne 2 ]; then
	echo "$0 <destination_dir> <plex_tarball_url>"
	exit 1
fi

_dir="$1"
_url="$2"

_osname=$(uname -o | tr '[:upper:]' '[:lower:]')
_target=$(uname -m)
_tarball=$(basename $_url)
_dst=$(basename -s -$_osname-$_target.tar.bz2 $_tarball)

mkdir -p "$_dir"
cd "$_dir"

fetch --no-verify-peer "$_url"
tar pxf $_tarball

test -d $_dst
chown -R root:wheel $_dst
find $_dst/Resources -name '*.so' -exec strip -p {} ';'
chmod 0111 $_dst/Plex*
chmod 0644 $_dst/Resources/*.db

install -d -v -m 0755 -g wheel -o root bin sbin dev etc lib libexec plex var var/run var/log media media/series media/films
install -d -v -m 1777 -g wheel -o root var/tmp tmp
install -d -v -m 0750 -g plex -o plex data var/log/plex var/run/plex
install -v -m 0555 -g wheel -o root /libexec/ld-elf.so.1 libexec/ld-elf.so.1
install -v -m 0111 -g wheel -o root /usr/sbin/nologin bin/nologin
install -v -m 0444 -g wheel -o root /etc/localtime etc/localtime
install -v -m 0444 -g wheel -o root /usr/local/lib/compat/libsupc++.so.1 lib

mv -i $_dst/Resources $_dst/Plex* plex
mv -i $_dst/lib* lib
chmod 0444 lib/*
ln -s Plex\ Media\ Server plex/Plex_Media_Server
rm -f lib/libpython2.7.so
ln -s libpython2.7.so.1 lib/libpython2.7.so

find $_dst
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

cat >etc/master.passwd <<'EOF'
root:*:0:0::0:0:root:/:/bin/nologin
plex:*:972:972:plex:0:0:Plex Media Server:/data/Plex Media Server:/bin/nologin
EOF

pwd_mkdb -p -d etc etc/master.passwd

cat >etc/group <<'EOF'
wheel:*:0:root
plex:*:972:
EOF

cat >etc/login.conf <<'EOF'
default:\
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
	:setenv=PLEX_MEDIA_SERVER_HOME=/plex,PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS=6,SUPPORT_PATH=/data,PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR=/data,PLEX_MEDIA_SERVER_LOG_DIR=/var/log/plex,PLEX_MEDIA_SERVER_PIDFILE=/var/run/plex/plex.pid,PLEX_MEDIA_SERVER_TMPDIR=/var/tmp,PYTHONHOME=/plex/Resources/Python,TMPDIR=/var/tmp,LC_ALL=en_US.UTF-8:\
	:charset=UTF-8:\
	:lang=en_US.UTF-8:\
	:path=/bin /plex:\
	:tc=default:
EOF

cap_mkdb etc/login.conf

cat >etc/hosts <<'EOF'
127.0.0.1	localhost.deiter.local	localhost
172.27.10.20	plex.deiter.local	plex
EOF

cat >etc/resolv.conf <<'EOF'
search deiter.local
nameserver 172.27.10.2
EOF

cat >etc/nsswitch.conf <<'EOF'
group: files
hosts: files dns
networks: files
passwd: files
shells: files
services: files
protocols: files
rpc: files
EOF

chflags -R simmutable bin sbin etc lib libexec plex var/run/ld-elf.so.hints

echo "done."
