#!/bin/sh -x

cd /var/devel/alt 
find . | grep -v /boot/kernel | sort > /tmp/alt.txt

umount /usr/src
umount /home/tiamat
umount /home
umount /export/iso
umount /export
umount /var/devel/obj
umount /var/devel/dist
umount /var/devel/build

cd /
find . | grep -v /compat/linux/ | grep -v /root/ | grep -v /usr/local/ | grep -v /proc/ | grep -v /boot/kernel | grep -v /var/devel/ | sort > /tmp/root.txt
