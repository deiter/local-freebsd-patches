#!/bin/sh -eu

# ( echo .Dd UNTITLED ; cat /usr/src/tools/build/options/WITHOUT_ACCT ) | mandoc | egrep -v 'UNTITLED|^$' 

BASENAME=$(basename $0 .sh)
OPTIONS_TEXT=$(mktemp -qt $BASENAME)
OPTIONS_ONLY=$(mktemp -qt $BASENAME)
SRC_CONF=$(mktemp -qt $BASENAME)

cd /usr/src/tools/build/options

LIST=$(ls | grep -v '[a-z]' | sort)

for ITEM in $LIST ; do
	(echo '.Dd UNTITLED' ; egrep -v '^\.' $ITEM) | mandoc -Tascii -O width=70 | egrep -v 'UNTITLED|^$' | sed 's|^|## |'
	echo "# $ITEM=YES"
	echo ''
done >$OPTIONS_TEXT

# src.conf format:
# 1. comments: lines which begin with ##
# 2. enabled control variables: VARIABLE=VALUE
# 3. disabled control variables: # VARIABLE=VALUE

awk -F= '!/^##.*$|^(\ |\t)*$/{gsub(/^#\ */, ""); print $1}' $OPTIONS_TEXT >$OPTIONS_ONLY
awk -F= '!/^##.*$|^(\ |\t)*$/{gsub(/^#\ */, ""); print $1}' /etc/src.conf >$SRC_CONF
diff -u $SRC_CONF $OPTIONS_ONLY || true

echo
echo "Full src.conf: $OPTIONS_TEXT"
echo

rm -f $SRC_CONF $OPTIONS_ONLY
