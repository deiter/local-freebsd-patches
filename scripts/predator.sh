#!/bin/sh -exu

_pass=""
_pool='predator'

# ada0: <Samsung SSD 850 EVO 120GB EMT02B6Q> ACS-2 ATA SATA 3.x device
# ada1: <Samsung SSD 850 EVO 120GB EMT02B6Q> ACS-2 ATA SATA 3.x device
#
# da4: <ATA WD2003FYYS-23W0B WA32> Fixed Direct Access SPC-4 SCSI device
# da5: <ATA WD2003FYYS-23W0B WA32> Fixed Direct Access SPC-4 SCSI device
# da6: <ATA WD2003FYYS-23W0B WA32> Fixed Direct Access SPC-4 SCSI device
# da7: <ATA WD2003FYYS-23W0B WA32> Fixed Direct Access SPC-4 SCSI device

_index=0
for _disk in 4 5 6 7; do
	_type="data"
	_dev="da${_disk}"
	_name="${_pool}_${_type}_${_index}"
	_key="/boot/keys/${_name}.key"

#	geli detach gpt/${_name}.eli
#	geli clear gpt/${_name}
#	rm -f $_key
#	gpart destroy -F $_dev
#	continue

	dd if=/dev/random of=$_key bs=32k count=1
	gpart create -s gpt $_dev
	gpart add -a 4k -t freebsd-zfs -l $_name $_dev
	echo $_pass | geli init -e AES-CBC -l 256 -s 4096 -K $_key -J - gpt/$_name
	echo $_pass | geli attach -k $_key -j - gpt/$_name
	_index=$(( $_index + 1 ))
done

for _disk in 0 1; do
	_dev="ada${_disk}"
	gpart create -s gpt $_dev
done

_index=0
for _disk in 0 1; do
	_type="cache"
	_dev="ada${_disk}"
	_name="${_pool}_${_type}_${_index}"
	_key="/boot/keys/${_name}.key"

#	geli detach gpt/${_name}.eli
#	geli clear gpt/${_name}
#	rm -f $_key
#	continue

	dd if=/dev/random of=$_key bs=32k count=1
	gpart add -a 4k -s 48G -t freebsd-zfs -l $_name $_dev
	echo $_pass | geli init -e AES-CBC -l 256 -s 4096 -K $_key -J - gpt/$_name
	echo $_pass | geli attach -k $_key -j - gpt/$_name
	_index=$(( $_index + 1 ))
done

_index=0
for _disk in 0 1; do
	_type="log"
	_dev="ada${_disk}"
	_name="${_pool}_${_type}_${_index}"
	_key="/boot/keys/${_name}.key"

#	geli detach gpt/${_name}.eli
#	geli clear gpt/${_name}
#	rm -f $_key
#	continue

	dd if=/dev/random of=$_key bs=32k count=1
	gpart add -a 4k -s 48G -t freebsd-zfs -l $_name $_dev
	echo $_pass | geli init -e AES-CBC -l 256 -s 4096 -K $_key -J - gpt/$_name
	echo $_pass | geli attach -k $_key -j - gpt/$_name
	_index=$(( $_index + 1 ))
done

zpool create -f \
	-o cachefile=none \
	-O compression=lz4 \
	-O atime=off \
	-O mountpoint=none \
	$_pool \
	raidz gpt/${_pool}_data_0.eli gpt/${_pool}_data_1.eli gpt/${_pool}_data_2.eli gpt/${_pool}_data_3.eli \
	cache gpt/${_pool}_cache_0.eli gpt/${_pool}_cache_1.eli \
	log mirror gpt/${_pool}_log_0.eli gpt/${_pool}_log_1.eli
