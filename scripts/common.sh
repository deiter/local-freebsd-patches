
unset LANG LC_ALL

_master="nostromo"
_tz="Europe/Moscow"
_pool="zroot"
_local="/usr/local"
_devel="/var/devel"
_stage="$_devel/stage"
_ports="$_devel/ports"
_conf="$_devel/conf"
_src="$_devel/src"
_obj="$_devel/obj"
_pkg="$_devel/pkg"

_hostname=$(hostname -s)
_osname=$(uname -o)
_target=$(uname -m)
_kernel=$(uname -i)
_script=$(realpath $0)
_bin=$(dirname $_script)
_root=$(dirname $_bin)
_jobs=$(sysctl -n kern.smp.cpus)

export MAKEOBJDIRPREFIX="$_obj"

if [ -x $_local/bin/mkisofs ]; then
	_mkisofs="$_local/bin/mkisofs"
else
	_mkisofs=""
fi

if [ -x /usr/bin/svnlite ]; then
	_svn="/usr/bin/svnlite"
elif [ -x /usr/bin/svn ]; then
	_svn="/usr/bin/svn"
elif [ -x $_local/bin/svn ]; then
	_svn="$_local/bin/svn"
else
	echo "svn command not found"
	exit 1
fi

_patch="/usr/bin/patch -p 0 -V none"

_exit()
{
	local _msg="$@"

	if [ -n "$_msg" ]; then
		echo "$_msg"
	fi

	exit 1
}

_update_svn()
{
	test -d .svn || exit 1
	$_svn cleanup
	$_svn cleanup --remove-unversioned --remove-ignored
	$_svn revert -R .
	$_svn diff
	$_svn status
	$_svn up
}

_update_cfg()
{
	local _cfg
	for _cfg in make.conf src.conf mergemaster.rc; do
		install -v -m 0644 -g wheel -o root $_root/conf/$_cfg /etc/$_cfg
	done
}

_mount_fs()
{
	local _fs

	if [ "$_hostname" = "$_master" ]; then
		return 0
	fi

	if [ ! -d $_devel ]; then
		install -v -d -m 0755 -g wheel -o root $_devel
	fi

	for _fs in $_src $_obj; do
		if [ ! -d $_fs ]; then
			install -v -d -m 0755 -g wheel -o root $_fs
		fi
		mount $_master:$_fs $_fs
	done
}

_umount_fs()
{
	local _fs

	if [ "$_hostname" = "$_master" ]; then
		return 0
	fi

	for _fs in $_obj $_src; do
		umount $_fs
		rmdir $_fs
	done

	rmdir $_devel
}

_clean_old()
{
	local _file _dir

	for _file in /COPYRIGHT /sys; do
		rm -f $_file
	done

	rm -rf /var/cache

	for _dir in /usr/src /usr/obj /var/games /var/yp \
		/etc/dma \
		/var/unbound/conf.d /var/unbound \
		/var/db/freebsd-update /var/db/hyperv /var/db/ipf \
		/var/db/ports /var/db/portsnap /mnt /proc; do
		test -d $_dir && rmdir $_dir
	done

	return 0
}
