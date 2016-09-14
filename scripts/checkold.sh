#!/bin/sh -xe

DIRS="bin boot etc lib libexec rescue sbin usr var"

rm -f /tmp/alt.txt /tmp/ext.txt

cd /var/tmp/alt 
for i in $DIRS; do
	find $i | sort >> /tmp/alt.txt
done

cd /
for i in $DIRS; do
	find $i | grep -v usr/src | grep -v usr/obj | grep -v usr/ports | grep -v usr/local | sort >> /tmp/ext.txt
done

cd /tmp
diff -u alt.txt ext.txt
