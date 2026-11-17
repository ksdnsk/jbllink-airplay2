#!/bin/sh
export LD_LIBRARY_PATH=/bkupgrade/airplay2
export ALSA_CONFIG_PATH=/data/ytm/my.conf
export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/var/run/dbus/system_bus_socket
/bkupgrade/airplay2/shairport-sync -c /bkupgrade/airplay2/shairport-sync.conf >/tmp/shair.log 2>&1 &
