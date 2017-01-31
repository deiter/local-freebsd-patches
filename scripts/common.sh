
unset LANG LC_ALL MM_CHARSET

_master="nostromo"
_domain="deiter.ru"
_realm="DEITER.RU"
_tz="Europe/Moscow"
_pool="zroot"
_local="/usr/local"
_devel="/export/freebsd"
_acme="$_local/etc/acme"
_ssl="$_local/etc/ssl/acme"
_stage="$_devel/stage"
_ports="$_devel/ports"
_conf="$_devel/conf"
_src="$_devel/src"
_obj="$_devel/obj"
_pkg="$_devel/pkg"
_jails="alien/jails"
_gw="172.27.10.1"
_dns="172.27.10.2"
_mask="24"

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

_amsg()
{
	local _msg="$@"

	echo " ==> $_msg"
}

_update_svn()
{
	if [ ! -d .svn ]; then
		_exit "SVN configuration not found"
	fi

	$_svn cleanup
	$_svn cleanup --remove-unversioned --remove-ignored
	$_svn revert -R .
	$_svn diff
	$_svn status
	$_svn up
}

_update_cfg()
{
	local _dir _file

	_dir=$_root/files/root

	for _file in $(find $_dir -type f); do
		install -v -m 0644 -g wheel -o root $_file ${_file#$_dir}
	done
}

_update_repos()
{
	install -v -d -m 0755 -g wheel -o root $_local/etc/pkg/repos

	cat >$_local/etc/pkg/repos/FreeBSD.conf <<-EOF
	FreeBSD: {
	    enabled: no
	}
	EOF

	cat >$_local/etc/pkg/repos/local.conf <<-EOF
	local: {
	    url: "file://$_pkg",
	    enabled: yes
	}
	EOF
}

_mount_fs()
{
	if [ "$_hostname" = "$_master" ]; then
		return 0
	fi

	if [ -d $_src ]; then
		return 0
	fi

	install -v -d -m 0755 -g wheel -o root $_devel
	mount $_master:$_devel $_devel
}

_umount_fs()
{
	if [ "$_hostname" = "$_master" ]; then
		return 0
	fi

	if mount -p | awk '{print $2}' | grep -q "^$_devel$"; then
		umount $_devel
		rmdir $_devel
	fi
}

_create_jail()
{
	local _jail=$1
	local _dataset _path _list _ip _cfg _dir _file

	if [ -z "$_jail" ]; then
		_exit "Jail name is not defined"
	fi

	case "$_jail" in
	plex)
		_exit "Jail plex is protected"
		;;
	transmission)
		_exit "Jail transmission is protected"
		;;
	*)
		;;
	esac

	if [ ! -d "$_src" ]; then
		_exit "System src directory not found"
	fi

	_dataset="$_jails/$_jail"
	_cfg="$_root/files/jails/$_jail"
	_ip=$(host $_jail | awk '{print $NF}')

	if [ -z "$_ip" ]; then
		_exit "Jail $_jail: IP address not found"
	fi

	if jls -j $_jail; then
		jail -rv $_jail
	fi

	if zfs list $_dataset; then
		zfs destroy -rf $_dataset
	fi

	zfs create $_dataset
	_path=$(zfs get -H -o value mountpoint $_dataset)

	if [ ! -d "$_path" ]; then
		_exit "Jail $_jail: root path $_path not found"
	fi

	make -C $_src DESTDIR=$_path KERNCONF=$_kernel installworld distribution installkernel >$_path/install.log 2>&1

	if [ "$_jail" = "mail" ]; then
		make -C $_src/etc MK_MAILWRAPPER=yes MK_MAIL=yes MK_SENDMAIL=yes obj depend all
		make -C $_src/usr.sbin/mailwrapper MK_MAILWRAPPER=yes obj depend all
		make -C $_src/usr.sbin/mailwrapper DESTDIR=$_dst MK_MAILWRAPPER=yes install >>$_dst/install.log 2>&1
	fi

	cd $_path
	install -v -o root -g wheel -m 0644 /dev/null etc/fstab
	install -v -o root -g wheel -m 0444 /dev/null etc/wall_cmos_clock
	install -v -o root -g wheel -m 0444 usr/share/zoneinfo/$_tz etc/localtime

	cat >var/db/zoneinfo <<-EOF
	$_tz
	EOF

	cat >etc/hosts <<-EOF
	127.0.0.1	localhost.${_domain}	localhost
	$_ip	${_jail}.${_domain}	${_jail}
	EOF

	cat >etc/resolv.conf <<-EOF
	search ${_domain}
	nameserver ${_dns}
	EOF

	cat >root/.k5login <<-EOF
	tiamat@${_realm}
	EOF

	cat >etc/rc.conf <<-EOF
	rc_startmsgs="NO"
	rc_debug="NO"
	rc_info="NO"
	cron_enable="NO"
	sshd_enable="NO"
	sendmail_enable="NONE"
	fsck_y_enable="YES"
	background_fsck="NO"
	update_motd="NO"
	dumpdev="NO"
	hostname="${_jail}.${_domain}"
	ifconfig_${_jail}1="inet ${_ip}/${_mask}"
	defaultrouter="${_gw}"
	EOF

	for _dir in $(awk '/^\//{print $2}' /etc/fstab.$_jail | sort); do
		install -v -d -m 0755 -g wheel -o root $_dir
	done

	if [ ! -d $_cfg ]; then
		return 0
	fi

	for _dir in $(find $_cfg -type d); do
		install -v -d -m 0755 -g wheel -o root ${_path}${_dir#$_cfg}
	done

	for _file in $(find $_cfg -type f); do
		install -v -o root -g wheel -m 0644 $_file ${_path}${_file#$_cfg}
	done
}

_update_ssl()
{
	local _dst _crt _name _file _hash

	_dst="/etc/ssl"
	_crt="$_ssl/$_domain"

	if [ ! -d "$_crt" ]; then
		_exit "SSL directory '$_crt' not found"
	fi

	for _name in privkey cert chain fullchain; do
		_file="$_crt/$_name.pem"
		if [ ! -f "$_file" ]; then
			_exit "SSL cert file '$_file' not found"
		fi
	done

	install -d -m 0755 -g wheel -o root -v $_dst
	find $_dst -type l -delete
	install -v -o root -g wheel -m 0400 $_crt/privkey.pem $_dst/$_domain.key
	install -v -o root -g wheel -m 0444 $_crt/cert.pem $_dst/$_domain.crt
	install -v -o root -g wheel -m 0444 $_crt/chain.pem $_dst/letsencrypt.crt
	install -v -o root -g wheel -m 0444 $_crt/fullchain.pem $_dst/$_domain.chained.crt
	install -v -o root -g wheel -m 0444 $_local/share/certs/ca-root-nss.crt $_dst/cert.pem

	setfacl -m user:ldap:read_set:allow $_dst/$_domain.key
	setfacl -m user:postgres:read_set:allow $_dst/$_domain.key

	_hash=$(openssl x509 -noout -hash -in $_dst/letsencrypt.crt)
	ln -s letsencrypt.crt $_dst/$_hash.0

	_hash=$(openssl x509 -noout -hash -in $_dst/cert.pem)
	ln -s cert.pem $_dst/$_hash.0
}

_clean_old()
{
	local _file _dir

	for _file in /COPYRIGHT /sys; do
		rm -f $_file
	done

	rm -rf /var/cache /usr/lib/debug
	rm -rf /usr/share/examples /usr/share/bsdconfig 
	rm -rf /usr/share/pc-sysinstall
	rm -f /COPYRIGHT /sys /var/msgs/bounds

	for _dir in /usr/src /usr/obj /var/games /var/yp \
		/usr/share/bsdconfig /usr/share/syscons \
		/etc/bluetooth /etc/dma /etc/ppp /etc/X11 \
		/media /proc /var/unbound/conf.d /var/unbound \
		/var/db/freebsd-update /var/db/hyperv /var/db/ipf \
		/var/db/ports /var/db/portsnap /var/spool/lpd \
		/var/spool/clientmqueue /var/spool/dma \
		/var/spool/mqueue /var/spool/opielocks \
		/var/spool/output/lpd /var/spool/output \
		/var/db/openldap-data /var/msgs /var/rwho /proc; do
		test -d $_dir && rmdir $_dir
	done

	return 0
}
