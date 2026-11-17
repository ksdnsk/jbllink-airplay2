# jbllink-airplay2

AirPlay 2 (multi-room) on **JBL Link Music** (MediaTek MT8516, ARMv7, Yocto),
built on a Debian 9 LXC and deployed to the speaker. AirPlay-only (no YTM).

## One-command install

On the speaker (as root, with network access):

    wget -qO- https://raw.githubusercontent.com/ksdnsk/jbllink-airplay2/master/install.sh | sh

This downloads the binary bundle (33 MB), writes configs, mounts the D-Bus policy,
and starts AirPlay2 as **"JBL Link Music"**.

## Manual start after reboot

On the speaker:
    sh /data/start-all.sh

From a Linux/macOS PC:
    ./start-airplay.sh [IP] [SSH_KEY]

From a Windows PC:
    powershell -File start-airplay.ps1 [-IP ...] [-KeyPath ...]

(SSH must be up first: sh /data/jbl-ssh/service.sh start via ADB, or use the PC helper.)

## Autostart

The speaker's rootfs (/) is read-only (UBIFS). On this device
mount -o remount,rw / is write-protected, so true OS-level autostart
(systemd units in /etc) is NOT possible without modifying the rootfs image.
Units are provided in systemd/ for reference.

### Option 1: Background daemon (recommended, fully automatic)

Run once on your PC. It polls for the device and auto-starts AirPlay2
after every reboot - no manual intervention needed.

- Linux/macOS: ./autostart-daemon.sh [IP] [SSH_KEY] [INTERVAL]
- Windows: powershell -File autostart-daemon.ps1 [-IP ...] [-KeyPath ...] [-Interval 10]

Leave it running in the background (tmux/screen on Linux, or as a service).

### Option 2: One-shot (manual, after reboot)

1. On the speaker: sh /data/start-all.sh
2. From a PC: ./start-airplay.sh (Linux/macOS) or start-airplay.ps1 (Windows)

### Option 3: True OS-level autostart (only if rootfs can be remounted rw)

    sh enable-autostart.sh

On this device remount fails (write-protected), so this falls back to Option 2.

## What works

- AirPlay 1 + AirPlay 2 service visible as "JBL Link Music" on iPhone/iPad
- Playback through the Harman DSP path (ytmout -> hmpp)
- NQPTP + shairport-sync in AirPlay 2 mode
- Coexists with stock Alice

## Layout on the speaker

    /bkupgrade/airplay2/        # 131 MB volume (data is only 17 MB)
      shairport-sync            # AirPlay 1+2 server
      avahi-daemon              # mDNS (musl static)
      nqptp                     # PTP timing for AirPlay 2
      *.so                      # bundled runtime libs
      shairport-sync.conf
      start-airplay.sh
      systemd/*.service         # reference units (rootfs is read-only)
    /data/start-all.sh          # start AirPlay after reboot
    /data/avahi/                # avahi config + dbus policy

## Files in this repo

- install.sh - one-command installer
- enable-autostart.sh - try to enable OS-level autostart (requires rw rootfs)
- start-airplay.sh - Linux/macOS one-shot auto-start helper
- start-airplay.ps1 - Windows one-shot auto-start helper
- autostart-daemon.sh - Linux/macOS background daemon (auto-starts after reboot)
- autostart-daemon.ps1 - Windows background daemon (auto-starts after reboot)
- scripts/ - start-airplay.sh, run-shair.sh
- config/ - shairport-sync.conf, avahi-daemon.conf, avahi-dbus.conf
- systemd/ - reference unit files
- avahi/ - dbus policy

## Backup

Full binary bundle: /bkupgrade/airplay2-backup.tar.gz on the speaker (33 MB).
Release asset: https://github.com/ksdnsk/jbllink-airplay2/releases/tag/v1.0

## Build environment

Debian 9 (stretch) LXC, cross toolchain arm-linux-gnueabihf.
