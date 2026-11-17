#!/bin/sh
export LD_LIBRARY_PATH=/bkupgrade/airplay2
export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/var/run/dbus/system_bus_socket
export ALSA_CONFIG_PATH=/data/ytm/my.conf
for p in $(ps | grep -E 'shairport-sync|/bkupgrade/airplay2/nqptp|/bkupgrade/airplay2/avahi-daemon' | grep -v grep | awk '{print $1}'); do kill $p 2>/dev/null; done
sleep 1
/bkupgrade/airplay2/nqptp >/tmp/nqptp.log 2>&1 &
/bkupgrade/airplay2/avahi-daemon -f /data/avahi/avahi-daemon.conf --no-drop-root >/tmp/avahi.log 2>&1 &
sleep 2
/bkupgrade/airplay2/shairport-sync -c /bkupgrade/airplay2/shairport-sync.conf >>/tmp/shair.log 2>&1 &
echo "AirPlay started, PID: $!"
