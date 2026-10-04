# AGENTS.md — Xiaomi Mi TV Stick debloat

## What this is

Record and tools for the debloat of one device: Xiaomi Mi TV Stick
`MiTV-AESP0` (`aquaman`), Android 9 / SDK 28, Amlogic SoC (`com.droidlogic.*`,
not MediaTek). Done 2026-09-05: 40 of 89 packages disabled, launcher switched
to Projectivy, free RAM ~206 MB → ~410 MB. Public repo: github.com/rizkiadpra/tv-debloat.

**`changelog.md` is the source of truth**: every batch, why each package was
disabled, the protected list, and before/after numbers. Read it before running
anything against the TV.

## Files

- `README.md` / `GUIDE.md` — public docs. GUIDE credits the source prompt
  (Medium article + mgultekin/android-cleaning-xiaomi, unlicensed: link, never copy)
  and lists where it did not fit this device.
- `connect.sh [tv-ip] [port]` — starts `adb_relay.py` and connects adb to
  `127.0.0.1:15555`. Default TV IP `192.168.100.33` (DHCP, may change).
- `adb_relay.py` — TCP relay. macOS 26 Local Network Privacy blocks Homebrew
  `adb` from the LAN; Apple-signed `/usr/bin/python3` is allowed, so it does the
  hop. Keep the local port outside 5554–5585 (reserved for emulators).
- `revert.sh` — **full revert**: re-enables every disabled package, restores the
  stock launcher and default settings, **reboots the TV**. Ask before running.
- `disabled-*.txt`, `meminfo-*.txt`, `packages-*.txt` — snapshots.
- `projectivy-4.71.apk` — launcher APK that was installed (verified, see changelog). Local only, git-ignored.
- `relay*.log` — relay output; safe to delete.

## Rules

- `pm disable-user --user 0` only. No uninstall, no root.
- At most 10 packages per batch, then let the user test the TV before continuing.
- Never disable anything on the changelog's "Protected — never disabled" list
  (HDMI-CEC, remote/BLE, Play services, settings, the `FallbackHome` safety net).
- Log every change in `changelog.md` using the same batch format.
- Android 9 has no role manager: set the launcher with
  `pm set-home-activity`, and disable competing launchers or HOME keeps
  resuming the old one.
