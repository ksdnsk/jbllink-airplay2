# jbllink-airplay2

AirPlay 2 (multi-room) на **JBL Link Music** (MediaTek MT8516, ARMv7, Yocto),
собрано на Debian 9 LXC и развёрнуто на колонке. Только AirPlay (без YTM).

[English version](README.md)

## Установка одной командой

На колонке (от root, с доступом в сеть):

    wget -qO- https://raw.githubusercontent.com/ksdnsk/jbllink-airplay2/master/install.sh | sh

Скачивает бинарный бандл (33 МБ), пишет конфиги, монтирует dbus-policy,
запускает AirPlay2 под именем **"JBL Link Music"**.

## Ручной запуск после перезагрузки

На колонке:
    sh /data/start-all.sh

С ПК (Linux/macOS):
    ./start-airplay.sh [IP] [SSH_KEY]

С ПК (Windows):
    powershell -File start-airplay.ps1 [-IP ...] [-KeyPath ...]

(Сначала поднимите SSH: sh /data/jbl-ssh/service.sh start через ADB, или используйте PC-хелпер.)

## Автозапуск

Корень колонки (/) — read-only (UBIFS). На этом устройстве
`mount -o remount,rw /` заблокирован (write-protected), поэтому настоящий
OS-level автозапуск (systemd в /etc) невозможен без модификации rootfs-образа.
Юниты лежат в `systemd/` для справки.

### Вариант 1: Фоновый демон (рекомендуется, полностью автоматический)

Запустите один раз на ПК. Он опрашивает колонку и автоматически поднимает
AirPlay2 после каждой перезагрузки — без ручного вмешательства.

- Linux/macOS: `./autostart-daemon.sh [IP] [SSH_KEY] [INTERVAL]`
- Windows: `powershell -File autostart-daemon.ps1 [-IP ...] [-KeyPath ...] [-Interval 10]`

Оставьте работать в фоне (tmux/screen на Linux, или как службу на Windows).

### Вариант 2: Разовый запуск (вручную, после ребута)

1. На колонке: `sh /data/start-all.sh`
2. С ПК: `./start-airplay.sh` (Linux/macOS) или `start-airplay.ps1` (Windows)

### Вариант 3: Настоящий OS-level автозапуск (только если rootfs можно перемонтировать в rw)

    sh enable-autostart.sh

На этом устройстве remount не работает (write-protected), поэтому откатывается к Варианту 2.

## Что работает

- Сервис AirPlay 1 + AirPlay 2 виден как "JBL Link Music" на iPhone/iPad
- Воспроизведение через Harman DSP (ytmout -> hmpp)
- NQPTP + shairport-sync в режиме AirPlay 2
- Сосуществует со штатной Алисой

## Расположение на колонке

    /bkupgrade/airplay2/        # том 131 МБ (data всего 17 МБ)
      shairport-sync            # сервер AirPlay 1+2
      avahi-daemon              # mDNS (musl static)
      nqptp                     # тайминг PTP для AirPlay 2
      *.so                      # bundled runtime libs
      shairport-sync.conf
      start-airplay.sh
      systemd/*.service         # справочные юниты (rootfs read-only)
    /data/start-all.sh          # запуск AirPlay после ребута
    /data/avahi/                # конфиг avahi + dbus policy

## Файлы в репозитории

- install.sh - установка одной командой
- enable-autostart.sh - попытка OS-level автозапуска (требует rw rootfs)
- start-airplay.sh - разовый хелпер для Linux/macOS
- start-airplay.ps1 - разовый хелпер для Windows
- autostart-daemon.sh - фоновый демон для Linux/macOS (автозапуск после ребута)
- autostart-daemon.ps1 - фоновый демон для Windows (автозапуск после ребута)
- scripts/ - start-airplay.sh, run-shair.sh
- config/ - shairport-sync.conf, avahi-daemon.conf, avahi-dbus.conf
- systemd/ - справочные unit-файлы
- avahi/ - dbus policy

## Бэкап

Полный бандл бинарников: /bkupgrade/airplay2-backup.tar.gz на колонке (33 МБ).
Release-asset: https://github.com/ksdnsk/jbllink-airplay2/releases/tag/v1.0

## Среда сборки

Debian 9 (stretch) LXC, кросс-тулчейн arm-linux-gnueabihf.
