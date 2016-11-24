#!/bin/sh -eu

. common.sh

_conf=$(basename $_script .sh)
_custom_full="$_root/conf/src.conf"
_system_part=$(mktemp)
_default_full=$(mktemp)
_default_part=$(mktemp)

cd /var/devel/src/tools/build/options

_list=$(ls WITH_* WITHOUT_* | sort)

for _item in $_list; do
	(echo '.Dd UNTITLED' ; cat $_item) | mandoc -Tascii -O width=70 | \
		col -bx | tr -s ' ' | egrep -v 'UNTITLED|^$' | sed 's|^|## |'
	echo "# $_item=YES"
	echo ''
done >$_default_full

# src.conf format:
# 1. comments: lines which begin with ##
# 2. enabled control variables: VARIABLE=VALUE
# 3. disabled control variables: # VARIABLE=VALUE

awk -F= '!/^##.*$|^(\ |\t)*$/{gsub(/^#\ */, ""); print $1}' $_default_full >$_default_part
awk -F= '!/^##.*$|^(\ |\t)*$/{gsub(/^#\ */, ""); print $1}' $_custom_full >$_system_part
echo "==> options diff:"
diff -u $_default_part $_system_part || true

grep '^##' $_default_full >$_default_part
grep '^##' $_custom_full >$_system_part
echo "==> text diff:"
diff -u $_default_part $_system_part || true

rm -f $_default_full $_default_part $_system_part
