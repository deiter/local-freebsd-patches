#!/bin/sh -ex

BASENAME=$(basename $0)
OPTIONS=$(mktemp -qt $BASENAME)
SRCCONF=$(mktemp -qt $BASENAME)

(cd /usr/src/tools/build/options && ls |grep -v '[a-z]' | sort) >$OPTIONS
awk -F= '{gsub(/^#\ */, ""); print $1}' /etc/src.conf >$SRCCONF
diff -u $SRCCONF $OPTIONS || true
rm -f $SRCCONF $OPTIONS
