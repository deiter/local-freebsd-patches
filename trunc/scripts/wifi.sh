#!/bin/sh -x

killall dhclient
killall wpa_supplicant
ifconfig wlan0 destroy

sleep 3
set -e

# ifconfig wlan0 create wlandev rum0
ifconfig wlan0 create wlandev iwn0
wpa_supplicant -s -B -i wlan0 -c /etc/wpa_supplicant.conf
while [ 1 ]; do
        ifconfig wlan0 | grep 'status: associated' && break
        sleep 1
done

dhclient wlan0

