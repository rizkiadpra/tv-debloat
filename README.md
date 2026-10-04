# Debloat Xiaomi Mi TV Stick (lewat ADB, tanpa root)

Catatan dan skrip dari proses debloat Xiaomi Mi TV Stick (`MiTV-AESP0`, kode
`aquaman`, Android 9) lewat ADB. Hasilnya: 40 dari 89 paket dimatikan, launcher
diganti ke [Projectivy](https://github.com/spocky/miproja1), RAM kosong naik dari
sekitar 206 MB ke 410 MB, dan status memori berubah dari `critical` ke `normal`.
TV terasa jauh lebih ringan, tidak lagi patah-patah.

Semua perubahan bisa dibalikkan. Tidak ada aplikasi bawaan yang di-uninstall dan
perangkat tidak di-root, jadi Netflix dan Prime Video tetap bisa HD (Widevine L1 aman).

## Isi repo

| File | Fungsi |
|---|---|
| [`changelog.md`](changelog.md) | Catatan lengkap: paket apa saja yang dimatikan per batch, alasannya, paket yang dilindungi, dan angka RAM sebelum/sesudah |
| [`revert.sh`](revert.sh) | Mengembalikan TV ini ke kondisi awal: menyalakan lagi semua paket, memulihkan launcher bawaan, lalu restart TV |
| [`connect.sh`](connect.sh), [`adb_relay.py`](adb_relay.py) | Penyambung ADB untuk macOS 26 (lihat langkah 3) |
| [`GUIDE.md`](GUIDE.md) | Penjelasan teknis lebih dalam (bahasa Inggris), sumber metode, dan perbedaan perangkat ini dengan panduan aslinya |
| `packages-*.txt`, `disabled-*.txt`, `meminfo-*.txt` | Rekaman kondisi perangkat sebelum dan sesudah |

## Langkah demi langkah untuk TV kamu sendiri

> Nama paket berbeda-beda tiap merek, model, dan versi firmware. Jangan langsung
> menyalin daftar dari `changelog.md`. Pakai daftar itu sebagai contoh, lalu cek
> daftar paket di TV kamu sendiri.

### 1. Siapkan TV

1. Buka **Settings → Device Preferences → About**.
2. Pilih **Build** sekitar 7 kali sampai muncul tulisan bahwa kamu sudah jadi developer.
3. Kembali ke **Device Preferences → Developer options**, lalu nyalakan **USB debugging**.
4. Buka **Settings → Network & Internet**, pilih jaringan Wi-Fi yang dipakai, dan catat
   **alamat IP** TV (contoh: `192.168.1.20`).

### 2. Siapkan komputer

1. Pastikan komputer tersambung ke Wi-Fi yang **sama** dengan TV.
2. Pasang `adb`:
   - **macOS:** `brew install --cask android-platform-tools`
   - **Windows / Linux:** unduh
     [Platform Tools](https://developer.android.com/tools/releases/platform-tools)
     dari Google, ekstrak, lalu jalankan perintah dari folder itu.
3. Cek pemasangannya dengan `adb version`.

### 3. Sambungkan komputer ke TV

```bash
adb connect 192.168.1.20:5555    # ganti dengan IP TV kamu
```

1. Di layar TV akan muncul dialog **"Allow USB debugging?"**. Centang
   **Always allow from this computer**, lalu pilih **OK** pakai remote.
2. Pastikan sambungannya berhasil:
   ```bash
   adb devices
   ```
   Harus tertulis `device`. Kalau tertulis `unauthorized`, dialog di TV belum diterima.

**Pengguna macOS 26:** kalau muncul `No route to host` padahal TV menyala, fitur
Local Network Privacy di macOS sedang memblokir `adb` dari Homebrew. Jalankan
`./connect.sh 192.168.1.20` dari repo ini sebagai gantinya. Setelah tersambung, perintah
`adb` lainnya bisa dipakai seperti biasa selama hanya satu perangkat yang terhubung.

### 4. Catat kondisi awal

Langkah ini penting supaya kamu bisa membandingkan hasil dan membatalkan perubahan
dengan tepat.

```bash
adb shell dumpsys meminfo | grep -E "Total RAM|Free RAM|Used RAM" > meminfo-sebelum.txt
adb shell pm list packages -d > disabled-sebelum.txt   # paket yang SUDAH mati dari awal
adb shell pm list packages | sort > paket-semua.txt
```

### 5. Cari aplikasi yang tidak perlu

Buka `paket-semua.txt` dan cari paket dengan pola berikut:

| Pola nama | Isinya |
|---|---|
| `analytics`, `bugreportsender`, `feedback`, `alphonso` | Telemetri dan pengumpul data tontonan |
| `setupwraith`, `onetimeinitializer`, `partnercustomizer`, `autoinstalls` | Wizard setup awal yang sudah tidak terpakai |
| `backdrop`, `dreams`, `mitv.dream` | Screensaver |
| `tvrecommendations`, `michannel` | Baris rekomendasi di layar utama |
| Aplikasi bawaan yang tidak kamu pakai | Misalnya Prime Video, YouTube Music, Play Games, Chromecast (`mediashell`) |

**Jangan pernah matikan paket-paket ini**, karena TV bisa rusak, remote mati, atau
ADB terputus:

- `android`, `com.android.systemui`, `com.android.tv.settings`, `com.android.shell`
- `com.google.android.gms`, `com.google.android.gsf`, `com.android.vending` (Play Services/Store)
- `com.android.location.fused` (bisa bikin TV restart terus-menerus)
- `com.google.android.inputmethod.latin` (keyboard)
- `com.google.android.tv.remote.service` dan paket Bluetooth (remote)
- `com.google.android.webview`, `com.android.providers.settings`
- Paket HDMI, tuner, dan tombol Input/Source: `*.tvinput`, `*.tv.service`,
  `*.hotkey.dispatcher`, `*.wwtv.tvcenter` (MediaTek), `com.droidlogic.*` (Amlogic)

Kalau ragu soal satu paket, **jangan dimatikan**.

### 6. Matikan per batch, maksimal 10 paket

```bash
adb shell pm disable-user --user 0 nama.paket.nya
```

Setelah setiap batch, tes TV pakai remote: tombol Input/Source, pindah HDMI (kalau
ada), aplikasi streaming yang biasa dipakai, suara, dan keyboard di layar. Lanjut ke
batch berikutnya hanya kalau semuanya masih normal.

Catat setiap paket yang kamu matikan beserta alasannya, seperti di `changelog.md`.

Kalau ada yang rusak, nyalakan lagi paketnya:

```bash
adb shell pm enable nama.paket.nya
```

> Pakai `pm disable-user`, **bukan** `pm uninstall`. Uninstall aplikasi sistem bisa
> butuh factory reset untuk dibalikkan.

### 7. Percepat animasi dan bersihkan cache

```bash
adb shell settings put global window_animation_scale 0.5
adb shell settings put global transition_animation_scale 0.5
adb shell settings put global animator_duration_scale 0.5
adb shell settings put secure screensaver_enabled 0
adb shell pm trim-caches 1G
```

Untuk mengembalikan animasi ke normal, ganti `0.5` dengan `1.0`.

### 8. (Opsional) Ganti launcher ke Projectivy

Launcher bawaan biasanya berat. Projectivy jauh lebih ringan dan punya baris
input HDMI.

1. Cek arsitektur prosesor TV:
   ```bash
   adb shell getprop ro.product.cpu.abilist
   ```
2. Unduh APK Projectivy **dari sumber resmi**:
   [github.com/spocky/miproja1/releases](https://github.com/spocky/miproja1/releases).
   Kalau tersedia di Play Store untuk TV kamu, pasang dari sana saja.
3. Pasang APK-nya:
   ```bash
   adb install ProjectivyLauncher-xxx.apk
   ```
4. **Buka Projectivy di TV dan selesaikan setup awalnya** sebelum lanjut.
5. Jadikan launcher utama:
   ```bash
   # Android 9:
   adb shell pm set-home-activity com.spocky.projengmenu/.ui.home.MainActivity
   # Android 10 ke atas:
   adb shell cmd role add-role-holder android.app.role.HOME com.spocky.projengmenu
   ```
6. Matikan launcher lama. Tanpa langkah ini, tombol Home di remote akan tetap membuka
   launcher lama.
   ```bash
   adb shell pm list packages | grep -iE "launcher|tvhome|patchwall"
   adb shell pm disable-user --user 0 com.google.android.tvlauncher   # sesuaikan hasil di atas
   ```
7. Restart TV, lalu tekan tombol Home beberapa kali untuk memastikan yang terbuka Projectivy.

### 9. Restart dan bandingkan hasilnya

```bash
adb reboot
# tunggu sekitar 1 menit, sambungkan lagi seperti langkah 3
adb shell dumpsys meminfo | grep -E "Total RAM|Free RAM|Used RAM" > meminfo-sesudah.txt
```

Angka RAM kosong bisa naik-turun sekitar 50 MB tergantung aplikasi yang sedang jalan.
Patokan yang lebih stabil adalah status memori (`critical` / `moderate` / `normal`) di
output `dumpsys meminfo`.

## Mengembalikan ke kondisi awal

- **Satu paket:** `adb shell pm enable nama.paket.nya`
- **Semua yang kamu matikan:** jalankan `pm enable` untuk setiap paket di catatanmu.
  Jangan menyalakan paket yang ada di `disabled-sebelum.txt`, karena paket itu memang
  sudah mati dari pabrik.
- **Perangkat di repo ini:** `./revert.sh` (khusus Mi TV Stick ini). Kalau setelah itu tombol
  Home masih membuka Projectivy, hapus tanda `#` di baris `adb uninstall` di dalam
  skripnya, lalu jalankan lagi.

## Mau dikerjakan AI agent saja?

Debloat ini dikerjakan dengan Claude Code memakai prompt dari artikel
[I cleaned my Android TV using Claude](https://medium.com/@mustafagultekinn01/i-cleaned-my-android-tv-using-claude-and-its-actually-smoother-than-when-i-bought-it-cc14ef5369d0)
karya Mustafa Gültekin. Prompt lengkap dan panduan teknisnya ada di
[mgultekin/android-cleaning-xiaomi](https://github.com/mgultekin/android-cleaning-xiaomi).
Prompt itu ditulis untuk TV MediaTek Android 10, jadi baca [`GUIDE.md`](GUIDE.md) dulu
untuk lima hal yang perlu disesuaikan di perangkat lain.

## Catatan

- APK Projectivy tidak disertakan di repo ini. Unduh dari sumber resminya.
- Risiko ditanggung sendiri. Matikan sedikit demi sedikit dan selalu tes setelah setiap batch.
