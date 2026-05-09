# VLC Telnet Server Setup

Panduan ini menjelaskan cara mengatur VLC Media Player sebagai layanan latar belakang (headless) dengan antarmuka Telnet menggunakan Systemd di Linux. Ini sangat berguna jika Anda ingin mengontrol pemutaran audio/video dari jarak jauh melalui jaringan.

## ⚡ Instalasi Cepat (Otomatis)

### 1. Langsung dari GitHub (One-Liner)
Gunakan perintah ini untuk menginstal secara instan tanpa perlu download/clone manual:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Owie2711/vlc-telnet-server/main/install.sh)"
```

### 2. Dari File Lokal
Jika Anda sudah meng-clone repositori ini, gunakan cara ini:

```bash
chmod +x install.sh
./install.sh
```

---

## 🔊 Persiapan (Khusus Proxmox LXC): Passthrough Audio ke Debian

Jika Anda menjalankan server VLC ini di dalam container LXC (Debian/Ubuntu) di atas **Proxmox**, Anda perlu meneruskan (*passthrough*) perangkat audio dari host Proxmox ke dalam container agar suara dapat keluar. Jika Anda menginstall langsung di PC/Raspberry Pi, abaikan bagian ini.

1. Buka terminal/shell node host Proxmox Anda.
2. Edit file konfigurasi container LXC Anda (misalnya ID container adalah `102`):

```bash
nano /etc/pve/lxc/102.conf
```

3. Tambahkan dua baris berikut di bagian paling bawah file tersebut:

```ini
lxc.cgroup2.devices.allow: c 116:* rwm
lxc.mount.entry: /dev/snd dev/snd none bind,optional,create=dir
```

4. Simpan file (tekan `Ctrl+O` -> `Enter`, lalu `Ctrl+X`).
5. **Restart** container LXC Anda dari UI Proxmox, atau gunakan perintah berikut di shell Proxmox:

```bash
pct reboot 102
```

---

## 🛠️ Langkah 1: Buat File Service

Buka terminal dan jalankan perintah berikut untuk membuat file konfigurasi service baru:

```bash
sudo nano /etc/systemd/system/vlc-telnet.service
```

## 📝 Langkah 2: Masukkan Konfigurasi Service

Salin (Copy) konfigurasi di bawah ini dan tempelkan (Paste) ke dalam editor `nano` yang baru saja Anda buka. 

> **Catatan Penting:** Pastikan Anda mengubah `User=zowie` dengan username yang ada di sistem server Anda (misalnya: `pi`, `root`, atau `ubuntu`).

```ini
[Unit]
Description=VLC Telnet Server Headless
After=network.target

[Service]
# Ganti 'zowie' dengan user asli di sistem (misal: pi, ubuntu, atau root)
User=zowie
ExecStart=/usr/bin/cvlc -I telnet --telnet-host 0.0.0.0 --telnet-port 4212 --telnet-password 1234 --aout alsa --vout dummy
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

Simpan file dan keluar dari editor (Tekan `Ctrl+O` -> `Enter` untuk menyimpan, lalu `Ctrl+X` untuk keluar).

### ⚙️ Penjelasan Konfigurasi (Opsional):
- `--telnet-host 0.0.0.0`: Mengizinkan akses dari semua IP di jaringan.
- `--telnet-port 4212`: Port yang digunakan untuk koneksi telnet.
- `--telnet-password 1234`: Password untuk login telnet (ubah angka `1234` dengan password Anda agar lebih aman).
- `--aout alsa --vout dummy`: Memaksa VLC untuk berjalan tanpa antarmuka grafis (headless).

## 🚀 Langkah 3: Terapkan dan Jalankan Service

Setelah file dibuat, beritahu sistem untuk memuat ulang konfigurasi dan mulai jalankan layanannya. Salin dan jalankan perintah ini satu per satu:

```bash
sudo systemctl daemon-reload
sudo systemctl enable vlc-telnet.service
sudo systemctl start vlc-telnet.service
```

Untuk memastikan service sudah berjalan tanpa error, cek statusnya dengan perintah:

```bash
sudo systemctl status vlc-telnet.service
```

## 💻 Langkah 4: Cara Mengontrol VLC

Sekarang Anda bisa mengakses antarmuka kontrol VLC dari komputer mana saja di jaringan yang sama. Buka Terminal atau Command Prompt dan jalankan:

```bash
telnet <IP_SERVER_ANDA> 4212
```
*(Ganti `<IP_SERVER_ANDA>` dengan IP address mesin tempat VLC berjalan, contoh: `telnet 192.168.1.10 4212`)*

Saat diminta password, ketikkan password yang telah diatur (default: `1234`) lalu tekan Enter.
Ketik `help` untuk melihat daftar perintah yang tersedia.

---

## 💾 Simpan State ALSA Secara Paksa

ALSA biasanya menyimpan state volume saat shutdown, namun pada sistem *headless* atau LXC, proses ini sering kali terlewat. Anda bisa memaksanya dengan perintah:

```bash
sudo alsactl store
```

Perintah ini akan mencatat level volume saat ini ke dalam file konfigurasi sistem agar tidak berubah saat reboot.
