# Handoff, updated 2026-11-08 16:55 by Claude Code (Opus 5.5)

## Goal
Keep the family Mi TV Stick usable and light. Device history: `changelog.md` (2026-11-08 sections).
Launcher feature work now lives in `~/Projects/Personal/tv-home` (its own HANDOFF/PRD/spec).

## Done (this stretch, not committed)
- Remote re-paired: Xiaomi's pairing service refused (distance gate), so `rcpair/` (RC Pair)
  called createBond over LE. Bond persists after reboot. RC Pair disabled afterwards.
- Home switched to tv-home, Projectivy disabled; `revert-tvhome.sh` added.
- `connect.sh` default IP now 192.168.100.35.

## In progress
- Nothing on this repo. Prayer-times launcher work continues in tv-home.

## Next
1. Commit (and push, if Rizki agrees) the 2026-11-08 changes, including `rcpair/` source.
   `rcpair/build/` and `rcpair/debug.keystore` are git-ignored.

## Decisions (don't redo)
- Pair the remote with RC Pair + the "two buttons beside Home" combo; Home + Back is wrong for this remote.
- Revert scripts disable apps instead of uninstalling them (AGENTS.md rule).

## Traps
- scrcpy needs `--hwdec=disabled`; one heavy job at a time on the 1 GB stick.
- Opening Add accessory pauses Xiaomi's auto-pair scanner.
- The stick's IP changes (DHCP). Scan port 5555 with `/usr/bin/nc` if adb goes offline.
