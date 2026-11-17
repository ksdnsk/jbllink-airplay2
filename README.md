# airplay2-jbl

AirPlay 2 (multi-room) on **JBL Link Music** (MediaTek MT8516, ARMv7, Yocto),
built on a Debian 9 LXC and deployed to the speaker.

## What works

- AirPlay 1 + AirPlay 2 service visible as **"JBL Link Music"** on iPhone/iPad
- Playback through the Harman DSP path (`ytmout` → `hmpp`)
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
  start-airplay.sh          # manual start
  systemd/*.service         # reference units (rootfs is read-only)
/data/start-all.sh          # start YTM + AirPlay after reboot
/data/avahi/                # avahi config + dbus policy
```

## Start after reboot

```
sh /data/start-all.sh
```

(SSH must be up first: `sh /data/jbl-ssh/service.sh start` via ADB.)

## Build environment

Debian 9 (stretch) LXC, cross toolchain `arm-linux-gnueabihf`.
See the conversation / issue tracker for full build notes.

## Files in this repo

- `scripts/` — start-airplay.sh, run-shair.sh, start-all.sh
- `config/` — shairport-sync.conf, avahi-daemon.conf, avahi-dbus.conf
- `systemd/` — reference unit files (rootfs is read-only, so they are not auto-installed)
- `avahi/` — dbus policy

## Backup

Full binary bundle: `/bkupgrade/airplay2-backup.tar.gz` on the speaker (33 MB).

