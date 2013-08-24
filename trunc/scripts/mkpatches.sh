#!/bin/sh -ex

PATCH_DIR=$(mktemp -dq)

cd /usr/src
for i in $(find . -type f -name '*.orig' | sed 's|^\./||'); do
	OLD_NAME=$i
	NEW_NAME=${i%.orig}
	PATCH_NAME=patch-$(echo $NEW_NAME | sed 's|/|-|g')
	diff -u $OLD_NAME $NEW_NAME >$PATCH_DIR/$PATCH_NAME || true
done
