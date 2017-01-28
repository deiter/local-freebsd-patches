#!/bin/sh -exu

_script=$(realpath $0)
_base=$(dirname $_script)

. $_base/common.sh

if [ $# -ne 1 ]; then
	_exit "Usage: $_script <domain>"
fi

if [ "$1" != "$_domain" ]; then
	exit 0
fi

_update_ssl

service slapd restart
jexec -l www service apache24 restart
