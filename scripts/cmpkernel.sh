#!/bin/sh -exu

egrep -v '^($|#)' $1 | awk '{print $1, $2}' | sort
