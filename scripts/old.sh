#!/bin/sh -exu

. common.sh

cd $_src

make check-old
make check-old-dirs
make check-old-files
make check-old-libs
make delete-old
make delete-old-dirs
make delete-old-files
make delete-old-libs

_clean_old
