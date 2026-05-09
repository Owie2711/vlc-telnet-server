# 🔊 Panduan Setup Multi-Speaker (VLC Telnet)

Dokumen ini menjelaskan cara menjalankan beberapa instance VLC Telnet Server secara bersamaan untuk mendukung sistem multi-speaker menggunakan `systemd`.

---

### 🚀 Langkah 1: Buat Service untuk Instance 1
Buka editor (gunakan `sudo`):

```bash
sudo nano /etc/systemd/system/vlc-telnet-1.service
```

Salin dan tempel kode berikut:

```ini
[Unit]
Description=VLC Telnet Server Instance 1
After=network.target sound.target

[Service]
Type=simple
User=zowie
ExecStart=/usr/bin/cvlc -I telnet --telnet-port 4212 --telnet-password 1234 -A alsa --alsa-audio-device plug:dmix --no-dbus
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```
> [!TIP]
> Tekan `Ctrl+O`, `Enter`, lalu `Ctrl+X` untuk menyimpan dan keluar dari Nano.

---

### 🚀 Langkah 2: Buat Service untuk Instance 2
Buka editor lagi untuk instance kedua:

```bash
sudo nano /etc/systemd/system/vlc-telnet-2.service
```

Salin dan tempel kode berikut (perhatikan perbedaan pada **port**):

```ini
[Unit]
Description=VLC Telnet Server Instance 2
After=network.target sound.target

[Service]
Type=simple
User=zowie
ExecStart=/usr/bin/cvlc -I telnet --telnet-port 4213 --telnet-password 1234 -A alsa --alsa-audio-device plug:dmix --no-dbus
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

---

### ⚙️ Langkah 3: Aktifkan dan Jalankan Service
Setelah file service dibuat, kita perlu memberi tahu sistem untuk memuat ulang konfigurasi dan mengaktifkan autorun saat boot.

1. **Reload systemd daemon:**
   ```bash
   sudo systemctl daemon-reload
   ```

2. **Enable (agar otomatis jalan saat Linux nyala):**
   ```bash
   sudo systemctl enable vlc-telnet-1
   sudo systemctl enable vlc-telnet-2
   ```

3. **Start (jalankan sekarang):**
   ```bash
   sudo systemctl start vlc-telnet-1
   sudo systemctl start vlc-telnet-2
   ```

---

### 📊 Langkah 4: Cara Cek Status
Untuk memastikan kedua instance berjalan dengan benar, gunakan perintah:

```bash
sudo systemctl status vlc-telnet-1 vlc-telnet-2
```
> [!NOTE]
> Jika status berwarna **hijau (active running)**, berarti konfigurasi berhasil.

---

### 🛠️ Perintah Penting Lainnya

| Perintah | Deskripsi |
| :--- | :--- |
| `sudo systemctl stop vlc-telnet-1` | Mematikan service sementara |
| `sudo systemctl restart vlc-telnet-1` | Restart (jika ada perubahan konfigurasi) |
| `journalctl -u vlc-telnet-1 -f` | Melihat log secara real-time (debugging) |

---

### 💡 Tips Tambahan
> [!WARNING]
> Karena menggunakan password `1234`, pastikan port `4212` dan `4213` pada firewall (misal: Proxmox/UFW) **tidak dibuka ke publik**. Cukup izinkan akses dari jaringan lokal saja demi keamanan.

---

**Selesai!** Coba reboot Linux Anda, dan kedua instance VLC harusnya langsung aktif secara otomatis tanpa perlu perintah manual lagi.
