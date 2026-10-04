# Doing this on your own TV

This repo records one device, but the method works on most Android TVs. This
page covers how to repeat it and where the popular debloat prompt did not fit
this device.

## Where the method comes from

The debloat followed an agent prompt that has been passed around for this
job. It was written up by Mustafa Gültekin in
[I cleaned my Android TV using Claude](https://medium.com/@mustafagultekinn01/i-cleaned-my-android-tv-using-claude-and-its-actually-smoother-than-when-i-bought-it-cc14ef5369d0)
(Medium, 2026-08-29). The prompt itself came from [tv.cobanov.dev](http://tv.cobanov.dev).
The author's longer playbook is in
[mgultekin/android-cleaning-xiaomi](https://github.com/mgultekin/android-cleaning-xiaomi).
It covers a Xiaomi Mi A2 55" TV (MediaTek, Android 10). Read its `TECHNICAL_DETAILS.md`
if your TV has HDMI inputs. Their repo has no license, so it is linked here, not copied.

## Before you start

1. On the TV, open **Settings → Device Preferences → About** and select **Build**
   about 7 times. This unlocks Developer options.
2. In **Developer options**, turn on **USB debugging**. Older Xiaomi TVs have no
   wireless-debugging pairing screen. You don't need `adb pair`, because
   `adb connect <ip>:5555` works once USB debugging is on.
3. Find the TV's IP under **Settings → Network & Internet → Status**. Your
   computer must be on the same network.
4. Get `adb` from Google's
   [platform-tools](https://developer.android.com/tools/releases/platform-tools)
   or your package manager.
5. Run `adb connect <ip>:5555`. The TV shows an "Allow USB debugging?" dialog;
   accept it with the remote and tick "Always allow".

**On macOS 26:** if `adb connect` fails with "No route to host" while
`/usr/bin/nc -z <ip> 5555` succeeds, Local Network Privacy is blocking the
Homebrew binary. Use [`connect.sh`](connect.sh), which relays through the
Apple-signed `/usr/bin/python3`.

## The rules that keep it reversible

- **Disable, never uninstall.** Use `pm disable-user --user 0 <pkg>`, and undo it
  with `pm enable <pkg>`. Uninstalling system packages can need a factory reset
  to undo.
- **No root, no custom ROM.** Either one breaks Widevine L1 for good, which drops
  Netflix and Prime Video to SD.
- **Record the starting state first:** `dumpsys meminfo` and `pm list packages -d`.
  If some packages were already disabled at the start, a revert that runs
  "enable everything disabled" turns them on too. [`revert.sh`](revert.sh) does
  exactly that, which is safe here only because this stick started with zero
  disabled packages.
- **Batches of at most 10**, then test with the remote: the Input button, HDMI
  (if the TV has it), your streaming apps, audio, and the on-screen keyboard.
- **Don't copy someone else's package list.** Package names change with the
  model, region and firmware. Pull your own list with `pm list packages` and go
  through it.
- **Keep a changelog as you go**, with what you disabled, why, and how to undo it.

## Where this device differed from the prompt

The prompt was written for MediaTek TVs on Android 10. This is an Amlogic
stick on Android 9, and five steps needed changes:

| Prompt says | What happened here | What to do |
|---|---|---|
| Protect `*.hotkey.dispatcher`, `*.tvinput`, `*.wwtv.tvcenter` | None of these exist. It's a stick, so there are no HDMI inputs or tuner | Find your SoC's equivalents (`com.droidlogic.*` on Amlogic) and protect those. See the protected list in [`changelog.md`](changelog.md) |
| Set the launcher with `cmd role add-role-holder` | `cmd: Can't find service: role`. The role manager arrived in Android 10 | On Android 9, use `pm set-home-activity <pkg>/<activity>` |
| Install Projectivy | Not installed from the Play Store here. The APK was sideloaded from the developer's GitHub releases | Get it from [spocky/miproja1](https://github.com/spocky/miproja1/releases), check the signer, and match the APK's ABIs to the device (`getprop ro.product.cpu.abilist`; this stick is 32-bit `armeabi-v7a`) |
| Disable every competing launcher | Needed here too. HOME kept resuming the stock launcher's live task until it was disabled | Disable the old launchers only **after** the new one is installed and past its first-run setup. `com.android.tv.settings/.system.FallbackHome` stays as a safety net |
| Before/after Free RAM | Readings swing by about ±50 MB, depending on which apps are loaded | Use the `status critical/moderate/normal` flag in `dumpsys meminfo` and the per-process list. Take readings after a reboot, with a fixed wait |

The HOME-button quirk was first described on a MediaTek Android 10 TV. It
showed up the same way on this Amlogic Android 9 stick, so assume it applies
to any pre-Android-11 TV.

## If your TV has HDMI inputs

This stick has none, so none of this was tested here. The linked playbook
covers it in detail:

- The row of HDMI inputs on the home screen is a feature of the stock launcher,
  not a system menu. Change launchers and the row can disappear. Projectivy has
  its own Inputs row; FLauncher doesn't.
- Never disable the input service or the app that renders HDMI passthrough.
- A voice command such as "switch to HDMI 2" works with any launcher, as long
  as the Assistant package is still enabled.

## After a revert

`revert.sh` hands HOME back to the stock launcher but leaves Projectivy
installed. If HOME still opens Projectivy afterwards (the same quirk in
reverse), uncomment the `adb uninstall com.spocky.projengmenu` line and run
the script again.
