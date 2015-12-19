#!/bin/sh -exu

TMPDIR=/var/tmp
RKCRC=/var/tmp/rkutils/rkcrc
RKFLASHTOOL=/var/tmp/rkflashtool/rkflashtool
KERNCONF=RADXA

cd $TMPDIR
rm -f kernel.img
$RKCRC -k /usr/obj/arm.armv6/usr/src/sys/$KERNCONF/kernel.bin kernel.img
$RKFLASHTOOL p | tee parm.txt

# 0x00006000@0x00004000(kernel),0x00006000@0x0000a000(boot)
$RKFLASHTOOL w 0x00004000 0x00006000 < kernel.img
$RKFLASHTOOL w 0x0000a000 0x00006000 < kernel.img
