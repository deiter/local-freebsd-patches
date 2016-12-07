#!/bin/sh -eu

_vbin="/usr/local/bin/VBoxManage"
_base="/var/db/vbox"
_dataset="alien/vm"
_user="vboxusers"
_group="vboxusers"

_ostype="OpenSolaris_64"
_nictype="82545EM"
_ctrbus="scsi"
_ctrtype="LSILogic"
_cpus="2"
_memory="4096"
_networks="4"
_disks="4"
_disksize="16GB"
_minport="5900"
_maxport="6000"
_null="-"
_mkdir="install -d -m 0750 -g $_group -o $_user -v"

export VBOX_USER_HOME="$_base"

_pre()
{
	local _msg="$@"
	echo -n " ==> $_msg "
	return 0
}

_msg()
{
	local _msg="$@"
	echo " ==> $_msg"
	return 0
}

_err()
{
	local _msg="$@"
	_msg "$_msg"
	exit 1
}

_vbox()
{
	local _cmd="$@"
	su -m $_user -c "$_vbin $_cmd"
	return $?
}

_exist()
{
	local _vm="$1"
	_vbox showvminfo $_vm >/dev/null 2>&1
	return $?
}

_uuid()
{
	local _vm="$1"

	_vbox list vms | sed 's|["{}]||g' | awk '
		BEGIN {
			uuid = "'$_null'"
		}
		{
			if ($1 == "'$_vm'") {
				uuid = $NF
			}
		}
		END {
			print uuid
		}
	'
	return 0
}

_pid()
{
	local _vm="$1"
	local _uuid

	_uuid=$(_uuid $_vm)

	if [ "$_uuid" = "$_null" ]; then
		return 0
	fi

	if ! pgrep -f "VBoxHeadless.*$_uuid"; then
		echo "$_null"
	fi

	return 0
}

_run()
{
	local _vm="$1"
	local _pid

	_pid=$(_pid $_vm)

	if [ "$_pid" = "$_null" ]; then
		return 1
	fi

	return 0
}

_unplumb()
{
	local _vm="$1"
	local _sn="0"

	while [ $_sn -lt $_networks ]; do
		_br="bridge$_sn"
		_in="$_vm$_sn"

		if ifconfig $_in >/dev/null 2>&1; then
			_msg "Destroy TAP interface $_in"
			ifconfig $_in destroy 
		fi

		_sn=$(( $_sn + 1 ))
	done

	return 0
}

_kill()
{
	local _vm="$1"
	local _pid

	_pid=$(_pid $_vm)

	if [ "$_pid" = "$_null" ]; then
		_err "VM $_vm is not currently running"
	fi

	_msg "Kill VM $_vm [pid: $_pid]"

	if ! kill -9 $_pid; then
		true
	fi

	_unplumb $_vm

	return 0
}

_port()
{
	local _vm="$1"

	if ! _run $_vm; then
		echo "$_null"
		return 0
	fi

	_vbox showvminfo --machinereadable $_vm | awk -F'"' '
		BEGIN {
			port = "'$_null'"
		}
		/^vrdeproperty\[TCP\/Ports\]=/ {
			port = $2
		}
		END {
			print port
		}
	'
	return 0
}

_list()
{
	local _obj="$1"
	local _cmd _list _vm _uuid _pid _port

	case "$_obj" in
	templates)
		zfs list -Hp -t snapshot -o name -d 2 $_dataset | \
			sed 's|^'$_dataset'/||g'
		return $?
		;;
	all)
		_cmd="vms"
		;;
	run)
		_cmd="runningvms"
		;;
	*)
		_usage
		;;
	esac

	_list=$(_vbox list $_cmd | sed 's|["{}]||g' | awk '{print $1}')

	if [ -z "$_list" ]; then
		return 0
	fi

	printf "%-16s %-36s %-5s %-5s\n" "vm" "uuid" "pid" "port"
	jot -s "" -b = 64
	for _vm in $_list; do
		_uuid=$(_uuid $_vm)
		_pid=$(_pid $_vm)
		_port=$(_port $_vm)
		printf "%-16s %-36s %-5s %-5s\n" $_vm $_uuid $_pid $_port
	done

	return 0
}

_cdrom()
{
	local _vm="$1"
	local _cd="$2"

	_vbox storageattach $_vm --storagectl sata --port 0 --device 0 \
		--type dvddrive --medium $_cd

	return $?
}

_rm()
{
	local _vm="$1"

	if ! _exist $_vm; then
		_err "VM $_vm does not exist"
	fi

	if _run $_vm; then
		_err "VM $_vm is currently running"
	fi

	if _vbox unregistervm $_vm --delete; then
		rm -rf $_base/vm/$_vm
	fi

	_unplumb $_vm

	if zfs list $_dataset/$_vm >/dev/null 2>&1; then
		zfs destroy -r $_dataset/$_vm
	fi

	return 0
}

_clone()
{
	local _tm="$1"
	local _vm="$2"
	local _td _ts _ds _sn _to

	if ! zfs list -Hp -t snapshot $_dataset/$_tm >/dev/null 2>&1; then
		_err "Snapshot $_dataset/$_tm does not exist"
	fi

	if _exist $_vm; then
		_err "VM $_vm already exist"
	fi

	if zfs list -Hp -t filesystem $_dataset/$_vm >/dev/null 2>&1; then
		_err "Destination dataset $_dataset/$_vm already exist"
	fi

	zfs list -Hpr -t snapshot -o name $_dataset/$_tm | \
		awk -F '@' '{print $1, $2}' | \
		while read _td _ts; do
		_msg "Clone $_tm -> $_vm"
		zfs list -Hpr -t snapshot -o name $_td | \
			awk -F '@' '/@'$_ts'$/{print $1, $2}' | \
			sort | while read _ds _sn; do
			_to="${_ds#$_td}"
			zfs clone $_ds@$_sn $_dataset/$_vm$_to
		done
	done

	_create $_vm

	return $?
}

_template()
{
	local _vm="$1"
	local _sn="$2"

	if ! _exist $_vm; then
		_err "VM $_vm does not exist"
	fi

	zfs snapshot -r $_dataset/$_vm@$_sn

	return $?
}

_create()
{
	local _vm="$1"
	local _dn="0"
	local _disk

	$_mkdir $_base
	$_mkdir $_base/vm
	$_mkdir $_base/disks

	if _exist $_vm; then
		_err "VM $_vm already exist"
	fi

	_msg "Create and register new VM $_vm"
	_vbox createvm --name $_vm --basefolder $_base/vm --register
	$_mkdir $_base/vm/$_vm/ports
	$_mkdir $_base/vm/$_vm/disks
	_msg "Modify VM $_vm [os: $_ostype, mem: $_memory, cpu: $_cpus]"
	_vbox modifyvm $_vm --ostype $_ostype --memory $_memory \
		--acpi on --apic on --ioapic on --x2apic off --biosapic apic \
		--chipset ich9 --usb off --audio none --cpus $_cpus \
		--clipboard disabled --draganddrop disabled \
		--defaultfrontend headless \
		--boot1 dvd --boot2 disk --boot3 net \
		--uart1 0x3F8 4 --uartmode1 server $_base/vm/$_vm/ports/com1 \
		--uart2 0x2F8 3 --uartmode2 server $_base/vm/$_vm/ports/com2 \
		--vrde on --vrdeextpack VNC
	_msg "Modify VM $_vm [bus: $_ctrbus, ctrl: $_ctrtype]"
	_vbox storagectl $_vm --name $_ctrbus --add $_ctrbus \
		--controller $_ctrtype --hostiocache on --bootable on
	_vbox storagectl $_vm --name sata --add sata --controller IntelAhci \
		--hostiocache on --bootable on
	_vbox storageattach $_vm --storagectl sata --port 0 --device 0 \
		--type dvddrive --medium emptydrive

	while [ $_dn -lt $_disks ]; do
		_disk="disk$_dn"
		_msg "Modify VM $_vm [$_disk $_disksize]"
		zfs list $_dataset/$_vm/$_disk >/dev/null 2>&1 || \
			zfs create -p -V $_disksize -o volmode=dev \
				$_dataset/$_vm/$_disk
			_vbox internalcommands createrawvmdk \
				-filename $_base/vm/$_vm/disks/$_disk.vmdk \
				-rawdisk /dev/zvol/$_dataset/$_vm/$_disk
			_vbox storageattach $_vm --storagectl $_ctrbus \
				--port $_dn --device 0 --type hdd \
				--medium $_base/vm/$_vm/disks/$_disk.vmdk
		_dn=$(( $_dn + 1 ))
	done

	return $?
}

_reset()
{
	local _vm="$1"

	if ! _exist $_vm; then
		_err "VM $_vm does not exist"
	fi

	_msg "Reset VM $_vm"
	_vbox controlvm $_vm reset
	return $?
}

_stop()
{
	local _vm="$1"
	local _sn="0"
	local _nc _br _in _tap

	if ! _exist $_vm; then
		_err "VM $_vm does not exist"
	fi

	_msg "Stop VM $_vm"

	if ! _vbox controlvm $_vm poweroff; then
		true
	fi

	_unplumb $_vm

	return $?
}

_start()
{
	local _vm="$1"
	local _vm="$1"
	local _sn="0"
	local _bp="0"
	local _nc _br _in _tap _pid _port

	if ! _exist $_vm; then
		_err "VM $_vm does not exist"
	fi

	if _run $_vm; then
		_err "VM $_vm already run"
	fi

	_msg "Start VM $_vm"

	while [ $_sn -lt $_networks ]; do
		_pre "Create TAP interface"
		_tap=$(ifconfig tap create)
		_br="bridge$_sn"
		_in="$_vm$_sn"
		_sn=$(( $_sn + 1 ))
		if [ $_bp -lt 4 ]; then
			_bp=$_sn
		fi
		_nc="${_nc:+$_nc }--nictype$_sn $_nictype"
		_nc="$_nc --nic$_sn bridged"
		_nc="$_nc --bridgeadapter$_sn $_tap"
		_nc="$_nc --cableconnected$_sn on"
		_nc="$_nc --nicbootprio$_sn $_bp"

		if ! ifconfig $_br >/dev/null 2>&1; then
			_pre "Create bridge interface"
			ifconfig $_br create
		fi

		if ifconfig $_in >/dev/null 2>&1; then
			ifconfig $_in destroy
		fi

		ifconfig $_tap name $_in \
			description "$_vm $_tap" \
			group "vbox"

		ifconfig $_br addm $_in
	done

	_port="$_minport"
	while [ "$_port" -le "$_maxport" ]; do
		if ! nc -z localhost $_port >/dev/null 2>&1; then
			break
		fi
		_port=$(( $_port + 1 ))
	done

	if [ "$_port" -eq "$_maxport" ]; then
		_err "Unable to find unused TCP port [$_minport,$_maxport]"
	fi

	_vbox modifyvm $_vm $_nc --vrdeport $_port
	_vbox startvm $_vm

	_pid=$(_pid $_vm)
	_port=$(_port $_vm)

	_msg "VM $_vm: pid: $_pid port: $_port"

	return $?
}

_usage()
{
	local _sc=$(basename $0)
	cat <<-EOF

	  $_sc list <all | run | templates>
	  $_sc cdrom <vm> <iso | emptydrive>
	  $_sc template <vm> <new_template>
	  $_sc clone <template> <new_vm>
	  $_sc command <vm>

	  commands: create, start, stop, kill, reset, pid, port, uuid, rm

	EOF

	exit 1
}

if [ ! -x "$_vbin" ]; then
	_err "$_vbin command not found"
fi

if [ $# -lt 2 -o $# -gt 3 ]; then
	_usage
fi

_cmd="$1"
_obj="$2"

if [ "$_cmd" = "cdrom" -o "$_cmd" = "clone" -o "$_cmd" = "template" ]; then
	if [ $# -ne 3 ]; then
		_usage
	fi
	_prm="$3"
fi

case "$_cmd" in
list)
	_list $_obj
	;;
create)
	_create $_obj
	;;
reset)
	_reset $_obj
	;;
stop)
	_stop $_obj
	;;
start)
	_start $_obj
	;;
cdrom)
	_cdrom $_obj $_prm
	;;
kill)
	_kill $_obj
	;;
port)
	_port $_obj
	;;
pid)
	_pid $_obj
	;;
uuid)
	_uuid $_obj
	;;
rm)	_rm $_obj
	;;
clone)
	_clone $_obj $_prm
	;;
template)
	_template $_obj $_prm
	;;
*)
	_usage
	;;
esac
