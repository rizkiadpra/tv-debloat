# Xiaomi Mi TV Stick debloat (ADB, no root)

Notes and scripts from debloating a Xiaomi Mi TV Stick (`MiTV-AESP0`, codename
`aquaman`, Android 9) over ADB. I disabled 40 of 89 packages and switched the
launcher to [Projectivy](https://github.com/spocky/miproja1). Free RAM went from
about 206 MB to 410 MB, and the low-memory status went from `critical` to `normal`.

- Packages were disabled with `pm disable-user --user 0`. Nothing was uninstalled
  and the device is not rooted, so Widevine L1 still works.
- [`changelog.md`](changelog.md) lists every batch, the reason each package was
  disabled, the packages I left alone, and before/after memory numbers.
- [`revert.sh`](revert.sh) re-enables every disabled package, restores the stock
  launcher and settings, and reboots the TV.
- [`connect.sh`](connect.sh) and [`adb_relay.py`](adb_relay.py) are a loopback
  relay. macOS 26 Local Network Privacy blocks Homebrew `adb` from reaching the
  LAN, but the Apple-signed `/usr/bin/python3` is allowed, so it relays the traffic.

The Projectivy APK is not included. Get it from the official source.

Use at your own risk. Package names differ between devices and firmware, so check
your own `pm list packages` before you copy anything.
