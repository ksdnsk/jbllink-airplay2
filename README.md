# jbllink-airplay2

AirPlay 2 (multi-room) on **JBL Link Music** (MediaTek MT8516, ARMv7, Yocto),
built on a Debian 9 LXC and deployed to the speaker.

## One-command install

On the speaker (as root, with network access):

```sh
wget -qO- https://raw.githubusercontent.com/ksdnsk/jbllink-airplay2/master/install.sh | sh
```

This downloads the binary bundle (33 MB), writes configs, mounts the D-Bus policy,
and starts AirPlay2 as **"JBL Link Music"**.

## Manual start after reboot

```sh
sh /data/start-all.sh
```

(SSH first: `sh /data/jbl-ssh/service.sh start` via ADB.)

## What works

- AirPlay 1 + AirPlay 2 service visible as "JBL Link Music" on iPhone/iPad
- Playback through the Harman DSP path (ytmout -> hmpp)
- NQPTP + shairport-sync in AirPlay 2 mode
- Coexists with stock Alice / YTM (YouTube Music)

## Layout on the speaker

```
/bkupgrade/airplay2/        # 131 MB volume (data is only 17 MB)
  shairport-sync            # AirPlay 1+2 server
  avahi-daemon              # mDNS (musl static)
  nqptp                     # PTP timing for AirPlay 2
  *.so                      # bundled runtime libs
  shairport-sync.conf
  start-airplay.sh
  systemd/*.service         # reference units (rootfs is read-only)
/data/start-all.sh          # start YTM + AirPlay after reboot
/data/avahi/                # avahi config + dbus policy
```

## Files in this repo

- install.sh — one-command installer
- scripts/ — start-airplay.sh, run-shair.sh, start-all.sh
- config/ — shairport-sync.conf, avahi-daemon.conf, avahi-dbus.conf
- systemd/ — reference unit files
- avahi/ — dbus policy

## Backup

Full binary bundle: /bkupgrade/airplay2-backup.tar.gz on the speaker (33 MB).
Release asset: https://github.com/ksdnsk/jbllink-airplay2/releases/tag/v1.0

## Build environment

Debian 9 (stretch) LXC, cross toolchain arm-linux-gnueabihf.

