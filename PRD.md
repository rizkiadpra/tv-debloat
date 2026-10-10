# PRD: tv-debloat

Diperbarui: 2026-10-10 · Status: live · Repo: https://github.com/rizkiadpra/tv-debloat

## Masalah dan tujuan
Xiaomi Mi TV Stick (`MiTV-AESP0`, kode `aquaman`, Android 9) terasa patah-patah karena RAM kosong hanya sekitar 206 MB dan status memori `critical`. Banyak paket bawaan berisi telemetri, wizard setup yang sudah tidak terpakai, screensaver, dan aplikasi yang tidak dipakai pemilik.

Repo ini mencatat proses mematikan paket-paket itu lewat ADB tanpa root dan tanpa uninstall, lalu menyediakan skrip dan panduan agar orang lain bisa mengulang caranya di TV mereka sendiri.

Berhasil berarti TV terasa ringan, semua perubahan bisa dibalikkan, dan pembaca bisa mengulang metodenya tanpa menyalin daftar paket yang belum tentu cocok dengan perangkatnya.

## Pengguna
Pemilik perangkat ini (satu TV stick, rumah tangga sendiri). Pembaca publik yang punya Android TV atau TV stick lambat dan mau membersihkannya lewat ADB. Agent AI yang melanjutkan pekerjaan di repo ini, yang harus membaca `changelog.md` dan `AGENTS.md` dulu.

## Lingkup saat ini
- Mencatat per batch paket yang dimatikan beserta alasannya, daftar paket yang dilindungi, dan angka RAM sebelum dan sesudah (`changelog.md`).
- Mematikan 40 dari 89 paket di perangkat ini dengan `pm disable-user --user 0`.
- Mengganti launcher ke Projectivy 4.71 dan mematikan launcher bawaan yang bersaing.
- Menyambungkan ADB dari macOS 26 lewat relay loopback (`connect.sh`, `adb_relay.py`).
- Mengembalikan perangkat ke kondisi awal dengan satu skrip (`revert.sh`).
- Menyimpan rekaman kondisi perangkat (`packages-*.txt`, `disabled-*.txt`, `meminfo-*.txt`, `device-info.txt`).
- Menjelaskan langkah demi langkah untuk TV lain dalam Bahasa Indonesia (`README.md`).
- Menjelaskan sumber metode dan perbedaan perangkat ini dari prompt aslinya, dalam bahasa Inggris (`GUIDE.md`).

## Di luar lingkup
- Uninstall paket sistem, root, dan custom ROM. Uninstall bisa butuh factory reset untuk dibalikkan, dan root atau custom ROM mematikan Widevine L1 sehingga Netflix dan Prime Video turun ke SD.
- Daftar paket yang berlaku umum untuk semua merek. Nama paket berbeda tiap model, wilayah, dan firmware.
- Pengujian TV dengan input HDMI atau tuner. Stick ini tidak punya keduanya, jadi bagian itu di `GUIDE.md` belum pernah dicoba.
- Menyalin isi repo mgultekin/android-cleaning-xiaomi. Repo itu tanpa lisensi, jadi hanya ditautkan.
- Menyertakan APK Projectivy di git. File `*.apk` masuk `.gitignore`.

## Ukuran keberhasilan
Hasil terukur di perangkat ini, dari `changelog.md`:

| Metrik | Sebelum | Sesudah |
|---|---|---|
| Status memori | critical | normal |
| RAM kosong | 211,075K (sekitar 206 MB) | 419,533K (sekitar 410 MB) |
| Paket dimatikan | 0 | 40 dari 89 |

RAM kosong berayun sekitar 50 MB tergantung aplikasi yang sedang jalan, jadi tanda yang andal adalah status memori. Pembacaan akhir diambil saat Netflix dan YouTube sedang berjalan. Ukuran lain, misalnya jumlah pembaca, bintang, atau orang yang berhasil mengulang, belum ditetapkan dan belum diketahui. Tanda kualitatif: TV tidak lagi patah-patah dan tombol Home membuka Projectivy.

## Arsitektur dan stack ringkas
Tidak ada aplikasi. Isinya skrip shell (`connect.sh`, `revert.sh`), satu relay TCP Python (`adb_relay.py`, memakai `/usr/bin/python3` bawaan Apple), dan dokumen Markdown. Semua perintah ke TV memakai `adb` lewat `127.0.0.1:15555` ke `192.168.100.33:5555`. Cara jalan dan jebakan ada di `AGENTS.md`.

## Deploy dan lingkungan
Di repo ini "deploy" berarti mempublikasikan panduan dan skrip ke GitHub. Tidak ada server atau build.

| | |
|---|---|
| Produksi | https://github.com/rizkiadpra/tv-debloat (repo publik, cabang `main`) |
| Hosting | GitHub |
| Data | File teks di repo. Tidak ada database. Perubahan ke TV hanya lewat ADB dari komputer pemilik |
| Cara deploy | `git push origin main`. Cabang lokal `main` sama dengan `origin/main` per 2026-10-10 |
| Deploy terakhir | 2026-10-04, commit 08b61f3 |

## Riwayat rilis
| Tanggal | Versi / commit | Perubahan |
|---|---|---|
| 2026-10-04 | 08b61f3 | README ditulis ulang dalam Bahasa Indonesia dengan panduan langkah demi langkah |
| 2026-10-04 | 5c00f9b | `GUIDE.md` ditambahkan: langkah persiapan, kredit sumber, dan perbedaan dari prompt asli |
| 2026-10-04 | 8160f11 | Commit awal: changelog, snapshot, `revert.sh`, `connect.sh`, `adb_relay.py` |

Proses debloat di TV sendiri dikerjakan 2026-09-05 (tercatat di `changelog.md`), sebelum repo dibuat. Belum diketahui apakah tiap commit di atas dipush satu per satu atau sekaligus.

## Keputusan produk
- Satu perangkat dicatat dengan rinci, bukan satu daftar universal, karena nama paket berbeda antar perangkat.
- Hanya `pm disable-user`, maksimal 10 paket per batch, lalu pemilik menguji TV sebelum lanjut.
- Paket pada daftar "Protected" di `changelog.md` tidak boleh dimatikan (HDMI-CEC, remote dan BLE, Play services, settings, `FallbackHome`).
- Setiap perubahan dicatat di `changelog.md` dengan format batch yang sama.
- Projectivy dipasang dari APK resmi yang diperiksa dulu (penanda tangan, ABI, SHA-256), dan hanya setelah itu launcher bawaan dimatikan.
- Bahasa: README Indonesia untuk pembaca umum, GUIDE Inggris untuk rujukan teknis.

## Risiko dan pertanyaan terbuka
- `revert.sh` menyalakan semua paket yang sedang mati, termasuk yang sudah mati dari pabrik. Aman di sini hanya karena TV mulai dengan nol paket mati.
- Pembaca yang menyalin daftar paket dari `changelog.md` ke TV lain bisa membuat TV rusak.
- IP TV bawaan di skrip (`192.168.100.33`) dari DHCP dan bisa berubah.
- Lisensi repo ini belum ditetapkan. Tidak ada file lisensi di repo.
- Firmware keluaran Xiaomi berikutnya bisa mengaktifkan lagi paket yang dimatikan. Belum diketahui, belum diuji.
- Sumber prompt di `GUIDE.md` ditautkan ke `tv.cobanov.dev` lewat http. Tautan itu belum diperiksa ulang.

## Backlog
Belum ada backlog yang disepakati di repo. Item di bawah ini hanya celah dokumen yang terlihat, belum diputuskan.
1. Merapikan `changelog.md` supaya bagian "RESULT" dan "NOT DONE" yang sudah usang tidak membingungkan pembaca.
2. Menyamakan jumlah penyesuaian di `GUIDE.md` dengan isi tabelnya.
3. Menambah file lisensi bila pemilik memutuskan.
