#!/bin/sh
# enable-autostart.sh - Try to enable true OS-level autostart (requires rw rootfs)
# If rootfs remount fails, falls back to manual /data/start-all.sh

# Try to remount rootfs read-write
if mount -o remount,rw / 2>/dev/null; then
    echo "Rootfs remounted rw. Installing systemd units..."
    cp /bkupgrade/airplay2/systemd/*.service /etc/systemd/system/ 2>/dev/null
    systemctl daemon-reload
    systemctl enable airplay-setup.service nqptp.service avahi-airplay.service shairport-airplay.service 2>/dev/null
    systemctl enable /data/start-all.sh 2>/dev/null || true
    echo "Autostart enabled via systemd."
    echo "Reboot to test: reboot"
else
    echo "Cannot remount rootfs rw (write-protected)."
    echo "Using manual autostart: run 'sh /data/start-all.sh' after reboot."
    echo "Or use the PC helper: start-airplay.sh (Linux/macOS) / start-airplay.ps1 (Windows)"
fi

