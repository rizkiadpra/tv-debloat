#!/bin/sh
# Undo the 2026-11-08 launcher switch: Projectivy becomes Home again and tv-home is disabled.
# Leaves the 40 debloated packages alone (that is revert.sh's job).
# usage: ./revert-tvhome.sh [tv-ip]    default 192.168.100.35
cd "$(dirname "$0")"
./connect.sh "${1:-192.168.100.35}" 15555 >/dev/null
export ANDROID_SERIAL=127.0.0.1:15555
# Order matters: bring Projectivy back before disabling tv-home, so Home is never empty.
adb shell pm enable com.spocky.projengmenu
adb shell pm set-home-activity com.spocky.projengmenu/.ui.home.MainActivity
adb shell pm disable-user --user 0 com.mihir.tvhome
# Optional, to remove it completely (it is a sideloaded app, not a system package):
# adb shell pm uninstall com.mihir.tvhome
adb shell input keyevent KEYCODE_HOME
sleep 4
adb shell dumpsys window | grep mCurrentFocus
