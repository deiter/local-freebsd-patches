#!/bin/sh -eu

# pkg install -y gdbm compat9x-amd64 compat10x-amd64

if jls -j plex >/dev/null 2>&1; then
	echo "Jail 'plex' must be stopped."
	exit 1
fi

for _package in gdbm compat9x-amd64 compat10x-amd64; do
	if ! pkg info $_package >/dev/null 2>&1; then
		echo "Package $_package must be installed."
		exit 1
	fi
done

if [ $# -ne 2 ]; then
	echo "$0 <destination_dir> <plex_tarball_url>"
	exit 1
fi

_dst="$1"
_url="$2"
_osname=$(uname -o | tr '[:upper:]' '[:lower:]')
_target=$(uname -m)
_tarball=$(basename $_url)
_src=$(basename -s -$_osname-$_target.tar.bz2 $_tarball)

install -d -m 0755 -g wheel -o root -v "$_dst"

cd "$_dst"

for _dir in bin sbin dev etc lib libexec plex var/run; do
	if [ ! -d $_dir ]; then
		continue
	fi
	chflags -R nosimmutable $_dir
	rm -rf $_dir
done

fetch --no-verify-peer $_url
tar pxf $_tarball

if [ ! -d $_src ]; then
	echo "Check source plex tarball:"
	ls -la
	exit 1
fi

chown -R root:wheel $_src
rm -f $_src/start.sh
find $_src/Resources -name '*.so' -exec strip -p {} ';'
chmod 0111 $_src/Plex* $_src/CrashUploader
chmod 0644 $_src/Resources/*.db

for _dir in bin sbin dev etc etc/ssl lib libexec plex var var/run var/log \
	media media/films media/music media/series media/video; do
	install -d -m 0755 -g wheel -o root -v $_dir
done

for _dir in tmp var/tmp; do
	install -d -m 1777 -g wheel -o root -v $_dir
done

for _dir in data var/log/plex var/run/plex; do
	install -d -m 0750 -g plex -o plex -v $_dir
done

install -m 0555 -g wheel -o root -v /libexec/ld-elf.so.1 libexec/ld-elf.so.1
install -m 0111 -g wheel -o root -v /usr/sbin/nologin bin/nologin
install -m 0444 -g wheel -o root -v /etc/localtime etc/localtime
install -m 0444 -g wheel -o root -v /usr/local/lib/compat/libsupc++.so.1 lib
install -m 0444 -g wheel -o root -v /etc/ssl/cert.pem etc/ssl/cert.pem

openssl pkcs12 -export -passout pass: -out etc/ssl/plex.p12 \
	-inkey /etc/ssl/deiter.ru.key \
	-in /etc/ssl/deiter.ru.crt \
	-certfile /etc/ssl/deiter.ru.chained.crt
chmod 0400 etc/ssl/plex.p12
chown plex:plex etc/ssl/plex.p12

mv -i $_src/Resources $_src/Plex* $_src/CrashUploader plex/
mv -i $_src/lib* lib/
chmod 0444 lib/*
ln -s Plex\ Media\ Server plex/Plex_Media_Server
rm -f lib/libpython2.7.so
ln -s libpython2.7.so.1 lib/libpython2.7.so
ln -s libsqlite3.so.0 lib/libsqlite3.so.8

_miss=$(find $_src -type f)

if [ -n "$_miss" ]; then
	echo "Missed files: $_miss"
	exit 1
fi

rm -rf $_src $_tarball

IFS='
'
for _file in $(find bin lib plex -type f); do
	_type=$(file -b $_file)
	case $_type in
	ELF*)
		;;
	*)
		continue
		;;
	esac

	ldd $_file >/dev/null 2>&1 || continue
	ldd -a $_file | awk '/=>/{print $1}'
done | sort | uniq | while read _lib; do
	test -f lib/$_lib && continue
        _path=$(find /lib /usr/lib /usr/local/lib -name $_lib | head -1)
        if [ -z "$_path" ]; then
                echo "warning: required library '$_lib' not found"
		continue
        fi
	install -m 0444 -g wheel -o root -v $_path lib/$_lib
done

ldconfig -s -f var/run/ld-elf.so.hints lib

cat >etc/master.passwd <<'EOF'
root:*:0:0::0:0:root:/:
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
	:setenv=CURL_CA_BUNDLE=/etc/ssl/cert.pem,PLEX_MEDIA_SERVER_HOME=/plex,PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS=6,SUPPORT_PATH=/data,PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR=/data,PLEX_MEDIA_SERVER_LOG_DIR=/var/log/plex,PLEX_MEDIA_SERVER_PIDFILE=/var/run/plex/plex.pid,PLEX_MEDIA_SERVER_TMPDIR=/var/tmp,PYTHONHOME=/plex/Resources/Python,TMPDIR=/var/tmp,LC_ALL=en_US.UTF-8:\
	:charset=UTF-8:\
	:lang=en_US.UTF-8:\
	:path=/bin /plex:\
	:tc=default:
EOF

cap_mkdb etc/login.conf

cat >etc/hosts <<EOF
127.0.0.1	localhost.deiter.ru	localhost
172.27.10.20	plex.deiter.ru		plex
EOF

cat >etc/resolv.conf <<EOF
search deiter.ru
nameserver 172.27.10.2
EOF

cat >etc/nsswitch.conf <<EOF
group: files
hosts: files dns
netgroup: files
networks: files
passwd: files
protocols: files
rpc: files
services: files
shells: files
EOF

chflags -R simmutable bin sbin etc lib libexec plex var/run/ld-elf.so.hints

echo "Done."
