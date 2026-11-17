#!/bin/sh
mount --bind /data/avahi/system.d /etc/dbus-1/system.d 2>/dev/null || true
systemctl restart dbus.service 2>/dev/null || true
sleep 1
cd /data/ytm/bin && ./ytm-alice daemon start >/tmp/ytm-alice.log 2>&1 || true
sleep 2
sh /bkupgrade/airplay2/start-airplay.sh
