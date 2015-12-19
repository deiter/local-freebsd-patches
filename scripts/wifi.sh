#!/bin/sh -x

HW="iwn0"
IN="wlan0"

killall wpa_supplicant
killall dhclient
ifconfig $IN destroy
sleep 3
ifconfig wlan create wlandev $HW
ifconfig $IN country RU regdomain ETSI
wpa_supplicant -s -B -i $IN -c /etc/wpa_supplicant.conf
while [ 1 ]; do
	ifconfig $IN | grep 'status: associated' && break
	sleep 1
done

#ifconfig $IN inet 172.27.0.98 netmask 255.255.255.0 up
