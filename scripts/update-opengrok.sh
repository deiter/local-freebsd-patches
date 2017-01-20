#!/bin/sh -exu

_base="/usr/local"
_src="/var/devel/src"

export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export JAVA_HOME="$_base/openjdk8"
export OPENGROK_APP_SERVER="Tomcat"
export OPENGROK_TOMCAT_BASE="$_base/tomcat"
export OPENGROK_INSTANCE_BASE="/var/db/opengrok"

install -d -m 0755 -g www -o www -v $OPENGROK_INSTANCE_BASE

cd $_base

if [ -d opengrok ]; then
	cd opengrok
else
	pkg install -y openjdk8 tomcat8 ctags git apache-ant
	$_base/etc/rc.d/tomcat8 restart
	git clone https://github.com/OpenGrok/OpenGrok opengrok
	cd opengrok
	ant
	./OpenGrok deploy
fi

su -m www -c "$_base/opengrok/OpenGrok index /var/devel/src"

$_base/etc/rc.d/tomcat8 restart
