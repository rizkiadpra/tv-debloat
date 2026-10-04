#!/bin/sh
# FULL REVERT — restores the TV to its pre-debloat state.
cd "$(dirname "$0")"
./connect.sh >/dev/null 2>&1
D=127.0.0.1:15555

# 1. re-enable every disabled package
adb -s $D shell 'for p in $(pm list packages -d | sed "s/package://"); do pm enable $p; done'

# 2. hand the home screen back to the stock Google TV launcher
adb -s $D shell 'pm set-home-activity com.google.android.tvlauncher/.MainActivity'

# 3. restore default settings
adb -s $D shell 'settings put global window_animation_scale 1.0; settings put global transition_animation_scale 1.0; settings put global animator_duration_scale 1.0; settings put secure screensaver_enabled 1'

# 4. optional: remove Projectivy entirely (safe - user-installed, not a system package)
#    uncomment the next line if you want it gone
# adb -s $D uninstall com.spocky.projengmenu

adb -s $D reboot
echo "Reverted and rebooting."
