#!/bin/bash
# autostart-daemon.sh - PC-side daemon that auto-starts AirPlay2 after device reboot
# Runs on Linux/macOS. Polls for device, starts SSH + AirPlay2 automatically.
# Usage: ./autostart-daemon.sh [IP] [SSH_KEY] [POLL_INTERVAL]
IP="${1:-192.168.1.83}"
KEY="${2:-$HOME/jbl_user_ed25519}"
INTERVAL="${3:-10}"
echo "Watching for $IP (poll every ${INTERVAL}s). Press Ctrl+C to stop."
while true; do
  if ping -c 1 -W 2 "$IP" >/dev/null 2>&1; then
    if ! adb -s "$IP:5555" shell true >/dev/null 2>&1; then
      adb connect "$IP:5555" >/dev/null 2>&1
      sleep 2
    fi
    if adb -s "$IP:5555" shell true >/dev/null 2>&1; then
      if ! ssh -i "$KEY" -p 2222 -o ConnectTimeout=3 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$IP true 2>/dev/null; then
        adb -s "$IP:5555" shell "sh /data/jbl-ssh/service.sh start" >/dev/null 2>&1
        sleep 2
      fi
      if ssh -i "$KEY" -p 2222 -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$IP true 2>/dev/null; then
        if ! ssh -i "$KEY" -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$IP 'pidof shairport-sync' >/dev/null 2>&1; then
          echo "[$(date)] Device online, starting AirPlay2..."
          ssh -i "$KEY" -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$IP 'sh /data/start-all.sh' >/dev/null 2>&1
          echo "[$(date)] AirPlay2 started."
        fi
      fi
    fi
  fi
  sleep "$INTERVAL"
done
