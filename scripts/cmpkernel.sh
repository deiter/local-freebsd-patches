#!/bin/sh -ex

cd /usr/src/sys/amd64/conf

egrep -v '^($|#)' $1 | awk '{print $2}' | sort
