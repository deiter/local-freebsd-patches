#!/bin/sh -exu

egrep -v '^($|#)' $1 | awk '{print $2}' | sort
