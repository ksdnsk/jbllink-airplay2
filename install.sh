#!/bin/sh
# One-command installer for AirPlay2 on JBL Link Music (AirPlay2 only)
# Usage: wget -qO- https://raw.githubusercontent.com/ksdnsk/jbllink-airplay2/master/install.sh | sh
set -e

REPO="https://github.com/ksdnsk/jbllink-airplay2/releases/download/v1.0"
BASE="/bkupgrade/airplay2"

echo "==> Creating directories"
mkdir -p "$BASE" /data/avahi/system.d

echo "==> Downloading binary bundle (33 MB)"
cd /tmp
wget -O airplay2-backup.tar.gz "$REPO/airplay2-backup.tar.gz"
echo "==> Extracting"
tar xzf airplay2-backup.tar.gz -C /bkupgrade

echo "==> Writing avahi config"
cat > /data/avahi/avahi-daemon.conf <<'AVAHIEOF'
[reflector]
enable-reflector=no
[wide-area]
enable-wide-area=no
[publish]
publish-addresses=yes
publish-hinfo=yes
publish-workstation=no
publish-domain=yes
[server]
host-name=jbl-link-music
domain-name=local
use-ipv4=yes
use-ipv6=no
allow-interfaces=wlan0
enable-dbus=yes
AVAHIEOF

echo "==> Writing dbus policy"
cat > /data/avahi/system.d/avahi-dbus.conf <<'DBUSEOF'
<!DOCTYPE busconfig PUBLIC "-//freedesktop//DTD D-BUS Bus Configuration 1.0//EN"
 "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
<busconfig>
  <policy context="default">
    <allow own="org.freedesktop.Avahi"/>
    <allow send_destination="org.freedesktop.Avahi"/>
    <allow receive_sender="org.freedesktop.Avahi"/>
  </policy>
  <policy user="root">
    <allow own="org.freedesktop.Avahi"/>
    <allow send_destination="org.freedesktop.Avahi"/>
  </policy>
</busconfig>
DBUSEOF

echo "==> Writing shairport-sync config"
cat > "$BASE/shairport-sync.conf" <<'SHAIREOF'
general = {
    name = "JBL Link Music";
    interpolation = "basic";
    default_airplay_volume = 0.0;
};
alsa = {
    output_device = "ytmout";
    buffer_size = 16384;
    period_size = 4096;
    disable_synchronization = "yes";
};
SHAIREOF

chmod +x "$BASE"/*.sh "$BASE"/shairport-sync "$BASE"/avahi-daemon "$BASE"/nqptp 2>/dev/null || true

echo "==> Creating /data/start-all.sh (AirPlay2 only)"
cat > /data/start-all.sh <<'STARTALLEOF'
#!/bin/sh
mount --bind /data/avahi/system.d /etc/dbus-1/system.d 2>/dev/null || true
systemctl restart dbus.service 2>/dev/null || true
sleep 1
sh /bkupgrade/airplay2/start-airplay.sh
STARTALLEOF
chmod +x /data/start-all.sh

echo "==> Mounting dbus policy"
mount --bind /data/avahi/system.d /etc/dbus-1/system.d 2>/dev/null || true
systemctl restart dbus.service 2>/dev/null || true
sleep 1

echo "==> Starting AirPlay2"
sh "$BASE/start-airplay.sh"

echo ""
echo "Done. AirPlay2 is running as 'JBL Link Music'."
echo "After reboot: sh /data/start-all.sh"

