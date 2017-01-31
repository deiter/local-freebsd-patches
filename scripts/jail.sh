#!/bin/sh -exu

_script=$(realpath $0)
_base=$(dirname $_script)

. $_base/common.sh

if [ $# -eq 0 ]; then
	_exit "Jail name is not defined"
fi

_jail=$1
_create_jail $_jail
jail -cv $_jail
jexec -l $_jail $_base/clean-old.sh
jexec -l $_jail $_base/update-pkg.sh
