#!/bin/sh -exu

_script=$(realpath $0)
_base=$(dirname $_script)

. $_base/common.sh

_update_cfg
_mount_fs

cd $_src

make check-old
make check-old-dirs
make check-old-files
make check-old-libs
make delete-old
make delete-old-dirs
make delete-old-files
make delete-old-libs

cd

_clean_old
_umount_fs
