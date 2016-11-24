#!/bin/sh -eux

_jails="plex transmission"

_usage()
{
	echo "$0 <start | stop>"
	exit 1
}

_attach()
{
	local _dev="$1"
	local _key="$2"
	local _pwd="$3"

	echo $_pwd | geli attach -k $_key -j - $_dev
	printf "%24s: %s\n" $_name ok
}

_start()
{
	local _pool _passwd _index _pool _type _name _key

	_pool="$1"

	stty -echo
	read -p "Enter GELI password for $_pool: " _passwd
	stty echo

	for _index in 0 1 2 3; do
		_type="data"
		_name="${_pool}_${_type}_${_index}"
		_key="/boot/keys/${_name}.key"
		_attach gpt/$_name $_key $_passwd
	done

	for _index in 0 1; do
		for _type in cache log; do
			_name="${_pool}_${_type}_${_index}"
			_key="/boot/keys/${_name}.key"
			_attach gpt/$_name $_key $_passwd
		done
	done

	zpool import $_pool || zpool list $_pool
}

_stop()
{
	local _pool _index _pool _type _name

	_pool="$1"

	zpool list $_pool >/dev/null 2>&1 && zpool export -f $_pool || true

	for _index in 0 1 2 3; do
		_type="data"
		_name="${_pool}_${_type}_${_index}"
		geli detach gpt/${_name}.eli
	done

	for _index in 0 1; do
		for _type in cache log; do
			_name="${_pool}_${_type}_${_index}"
			geli detach gpt/${_name}.eli
		done
	done
}

if [ $# -ne 1 ]; then
	_usage
fi

_action="$1"

case "$_action" in
start)
	_start alien
	_start predator
	for _jail in $_jails; do
		jail -cv $_jail
	done
	;;
stop)
	for _jail in $_jails; do
		jail -rv $_jail
	done
	_stop alien
	_stop predator
	;;
*)
	_usage
	;;
esac
