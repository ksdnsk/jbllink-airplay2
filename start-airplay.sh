#!/usr/bin/env bash
# start-airplay.sh - Auto-start AirPlay2 on JBL Link Music after reboot (run from Linux/macOS PC)
# Requires: adb and ssh in PATH, SSH key at KEY_PATH
set -e

IP="${1:-192.168.1.83}"
KEY_PATH="${2:-$HOME/jbl_user_ed25519}"

echo "Connecting ADB to $IP..."
adb connect "$IP:5555" >/dev/null 2>&1
sleep 2

echo "Starting SSH service..."
adb -s "$IP:5555" shell "sh /data/jbl-ssh/service.sh start" >/dev/null 2>&1
sleep 2

echo "Starting AirPlay2 stack..."
ssh -i "$KEY_PATH" -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "root@$IP" "sh /data/start-all.sh"

echo "Done. AirPlay2 should be running as 'JBL Link Music'."
