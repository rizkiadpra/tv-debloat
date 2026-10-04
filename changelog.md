# Xiaomi Mi TV Stick — Debloat Changelog

**Device:** MiTV-AESP0 (codename `aquaman`) · Android 9 (SDK 28) · build PI.2055
**SoC vendor:** Amlogic (`com.droidlogic.*`) — NOT MediaTek
**Connection:** adb via loopback relay `127.0.0.1:15555` → `192.168.100.33:5555`
(macOS 26 Local Network Privacy blocks Homebrew adb from the LAN; relay runs on Apple-signed /usr/bin/python3)

## Baseline — 2026-09-05 10:19
```
Total RAM: 1,004,412K (status critical)
 Free RAM:   211,075K
 Used RAM: 1,272,927K
```
Packages: 89 total (88 system, 1 user) · Disabled before start: **0**

## Rules in force
- `pm disable-user --user 0` ONLY. No uninstall. No root.
- Max 10 packages per batch, then user testing before proceeding.

## Changes

### Batch 1 — telemetry / dead setup code (2026-09-05 10:2x) — TESTED OK
| Package | Why |
|---|---|
| `tv.alphonso.alphonso_eula` | Alphonso ACR — samples audio to profile viewing habits |
| `com.miui.tv.analytics` | Xiaomi telemetry collection |
| `com.google.android.tungsten.setupwraith` | First-boot setup wizard, still resident post-setup |
| `com.google.android.tv.bugreportsender` | Uploads bug reports to Google |
| `com.google.android.feedback` | Crash/feedback reporting |
| `com.android.cts.ctsshim` | Compatibility-test stub, no runtime function |
| `com.android.cts.priv.ctsshim` | Same, privileged variant |
| `com.google.android.onetimeinitializer` | First-boot init, already ran |
| `com.android.onetimeinitializer` | AOSP equivalent, already ran |
| `android.autoinstalls.config.xioami.mibox3` | Config that auto-installs partner apps |

RAM after batch 1: Free 206,091K (status critical) — no gain visible; Play Store woke during the window.
All 10 target processes confirmed dead.

### Batch 2 — unused features + preinstalled apps (2026-09-05) — user-confirmed unused
| Package | Why |
|---|---|
| `com.xiaomi.mitv.updateservice` | Xiaomi OTA updater; device out of support per user |
| `com.google.android.apps.mediashell` | Chromecast built-in — user does not cast |
| `com.google.android.katniss` | Google Assistant / voice search — unused |
| `com.google.android.speech.pumpkin` | Offline speech engine backing Assistant |
| `com.mitv.milinkservice` | Xiaomi Miracast mirroring — unused |
| `com.amazon.amazonvideo.livingroom` | Prime Video — unused |
| `com.vidio.android.tv` | Vidio — unused (only user-installed app) |
| `com.google.android.youtube.tvmusic` | YouTube Music — unused |
| `com.google.android.videos` | Google TV / Play Movies — unused |
| `com.google.android.play.games` | Play Games — unused |

RAM after batch 2: Free 295,484K — **status critical -> moderate**, +84MB vs baseline.
KEPT per user: `com.netflix.ninja`, `com.google.android.youtube.tv` (verified still enabled).
NOT TOUCHED: `com.google.android.marvin.talkback` (accessibility; user never confirmed).

### Batch 3 — Xiaomi cruft, screensavers, PatchWall (2026-09-05)
| Package | Why |
|---|---|
| `com.mitv.tvhome.atv` | PatchWall launcher — unused; competing launcher (step i) |
| `com.mitv.tvhome.michannel` | PatchWall content channels |
| `com.xiaomi.android.tvsetup.partnercustomizer` | Partner customization, 16MB resident |
| `com.mitv.dream` | Xiaomi screensaver |
| `com.google.android.backdrop` | Google Ambient/backdrop screensaver |
| `com.android.dreams.basic` | AOSP basic screensaver |
| `com.android.settings.intelligence` | Settings search suggestions |
| `com.android.printspooler` | Print spooler — no printer on a TV stick |
| `com.xm.webcontent` | Xiaomi web content |
| `com.xiaomo.tv.milegal` | Xiaomi legal/ToS screens |

Also: `settings put secure screensaver_enabled 0` (verified = 0).

SAFETY: HOME launcher verified intact after PatchWall removal —
`com.google.android.tvlauncher/.MainActivity` + `com.android.tv.settings/.system.FallbackHome`.
Ordering rule: stock tvlauncher is NOT disabled until Projectivy is installed and set as home.

RAM after batch 3: Free 310,389K (status moderate) — +99MB vs baseline. 30/89 disabled.

### Still enabled, deliberately
- `com.mitv.videoplayer` — local/USB video player; user not yet asked
- `com.google.android.marvin.talkback` — accessibility; user never confirmed
- `com.netflix.ninja`, `com.google.android.youtube.tv` — in active use

### Protected — never disabled
`android`, `com.android.systemui`, `com.android.tv.settings`, `com.android.shell`,
`com.android.bluetooth`, `com.google.android.webview`, `com.android.providers.settings`,
`com.google.android.gms`, `com.google.android.gsf`, `com.android.vending`,
`com.android.location.fused`, `com.google.android.inputmethod.latin`,
`com.google.android.tv.remote.service`, `com.google.android.packageinstaller`,
`com.google.android.tv.frameworkpackagestubs`, `com.android.captiveportallogin`,
`mitv.service` / `xiaomi.tvservice` (HDMI-CEC: remote controls TV power+volume),
`com.droidlogic`, `com.droidlogic.ble` (remote), `com.droidlogic.overlay`,
`com.droidlogic.SubTitleService` (Amlogic SoC — local equivalents of the MediaTek
`*.tv.service` / `*.tvinput` packages named in the brief, which do not exist here).


### Batch 4 — backup/sync stubs + local player (2026-09-05)
| Package | Why |
|---|---|
| `com.mitv.videoplayer` | Xiaomi local/USB video player — user streams only |
| `com.mitv.download.service` | Xiaomi download service (fed PatchWall) |
| `com.android.backupconfirm` | Backup confirmation dialog |
| `com.android.wallpaperbackup` | Wallpaper backup — no wallpaper on TV |
| `com.android.sharedstoragebackup` | Shared storage backup agent |
| `com.google.android.backuptransport` | Google backup transport |
| `com.google.android.syncadapters.calendar` | Calendar sync — no calendar use on TV |
| `com.google.android.syncadapters.contacts` | Contacts sync — no contacts use on TV |

### Steps d/e/f — 2026-09-05 10:30
- `window_animation_scale` / `transition_animation_scale` / `animator_duration_scale` = **0.5**
- `pm trim-caches 1G` (/data: 1.8G used of 4.8G, 39%)
- Rebooted. `boot_completed` in ~35s. All 38 disables + all settings persisted.

## RESULT — before vs after
| Metric | Before | After |
|---|---|---|
| Memory status | **critical** | **normal** |
| Free RAM | 211,075K | 292,074K (+79MB) |
| Disabled packages | 0 | 38 / 89 |

Caveat: free-RAM swings +/-50MB with background activity (Netflix had preloaded to
92MB at measurement). The status flag critical -> normal is the reliable signal.

## NOT DONE — steps g/j (Projectivy launcher)
Deliberately not executed. Projectivy is not on the Play Store and requires a
sideloaded APK; declined to fetch an unverified binary and grant it home-screen
role on a device holding user credentials. User to supply the APK from
projectivy.app or official APKMirror.
Also note: `cmd role add-role-holder` does NOT exist on Android 9 (SDK 28) —
role manager landed in Android 10. Use `pm set-home-activity` instead.
Stock `com.google.android.tvlauncher` is STILL ENABLED and is the active home.
Do not disable it until Projectivy is installed and verified as home.

## Revert
`./revert.sh` — re-enables all, restores animation scales to 1.0 + screensaver, reboots.
Verified 2026-09-05: enable/disable round-trip tested on com.android.printspooler (38->37->38).
`./connect.sh` — reconnects adb (auto-starts the loopback relay). Verified from cold start.

## Steps g/i/j — Projectivy Launcher (2026-09-05 10:38-10:45)

### APK verification before install
Source: https://github.com/spocky/miproja1/releases (user-supplied; confirmed OFFICIAL —
cross-referenced against APKMirror listings for developer "Spocky", version 4.71 matches).
- File: ProjectivyLauncher-4.71-c95-xda-release.apk (11MB)
- SHA-256: 6818fc2db44411a605ca4d7067fb9d7227aaef2414cff42de58fe13e9321b47a
- Signer: CN=Despesse Mickael, L=Villeurbanne, C=FR (self-signed, normal for Android)
- Package: com.spocky.projengmenu (matches brief)
- ABIs in APK: arm64-v8a, armeabi-v7a, x86, x86_64
  Device is armeabi-v7a ONLY (32-bit) — compatible.
- Declares android.intent.category.HOME + LEANBACK_LAUNCHER
- NOTE: bundles firebaseinitprovider (Firebase analytics). Disclosed to user.

### (h) Set as home — DEVIATION FROM BRIEF
`cmd role add-role-holder` FAILED as predicted: "cmd: Can't find service: role".
Role manager does not exist on Android 9 (SDK 28); it landed in Android 10.
Used `pm set-home-activity com.spocky.projengmenu/.ui.home.MainActivity` -> Success.

### (i) Home button quirk — REPRODUCED AND FIXED
After set-home-activity, HOME still resolved to com.google.android.tvlauncher
(it held a live task, t5000, which HOME resumed). This is exactly the quirk in the brief.
Fix — disabled the competing launchers:
| Package | Why |
|---|---|
| `com.google.android.tvlauncher` | Stock Google TV launcher — stole the HOME button |
| `com.google.android.tvrecommendations` | Feeds only the stock launcher's rows |
(PatchWall `com.mitv.tvhome.atv` already disabled in batch 3.)
Verified 3/3 HOME presses land on Projectivy. Remaining HOME-capable activities:
Projectivy + `com.android.tv.settings/.system.FallbackHome` (safety net, protected).

### (j) Reboot verification
boot_completed ~35s. Booted directly into Projectivy. Default launcher persisted.
40/89 packages disabled.

## FINAL RESULT
| Metric | Before | After |
|---|---|---|
| Memory status | **critical** | **normal** |
| Free RAM | 211,075K (206MB) | **419,533K (410MB)** — +204MB, ~2x |
| Used RAM | 1,272,927K | 1,200,777K |
| Disabled | 0 | 40 / 89 |
| Home launcher | tvlauncher (67MB) | Projectivy (56MB) |

Final reading taken WITH Netflix (91MB) and YouTube (93MB) both resident,
so real idle headroom is higher still.

## Revert
`./revert.sh` — re-enables all 40, hands home back to tvlauncher, restores animation
scales + screensaver, reboots. Optional commented line also uninstalls Projectivy.
Verified: enable/disable round-trip tested on-device; `sh -n` syntax-checked.
