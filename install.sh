#!/bin/bash

# =================================================================
# VLC Telnet Server Auto Installer
# =================================================================

# 1. Pastikan script tidak dijalankan sebagai root (karena VLC menolak jalan sebagai root)
if [ "$EUID" -eq 0 ]; then
    echo "❌ ERROR: Script ini tidak boleh dijalankan langsung sebagai root."
    echo "Silakan jalankan sebagai user biasa (bisa menggunakan sudo di dalam script)."
    exit 1
fi

CURRENT_USER=$(whoami)
echo "👤 User yang akan digunakan: $CURRENT_USER"

# 2. Verifikasi/Install ALSA
echo "🔍 Mengecek ALSA..."
if ! command -v alsactl &> /dev/null; then
    echo "📦 ALSA tidak ditemukan. Menginstall alsa-utils..."
    sudo apt-get update && sudo apt-get install alsa-utils -y
else
    echo "✅ ALSA sudah terinstall."
fi

# 3. Verifikasi/Install VLC
echo "🔍 Mengecek VLC..."
if ! command -v cvlc &> /dev/null; then
    echo "📦 VLC tidak ditemukan. Menginstall vlc..."
    sudo apt-get update && sudo apt-get install vlc -y
else
    echo "✅ VLC sudah terinstall."
fi

# 4. Tanya Password Telnet
read -p "🔐 Masukkan password untuk VLC Telnet: " TELNET_PASS
if [ -z "$TELNET_PASS" ]; then
    echo "❌ Password tidak boleh kosong!"
    exit 1
fi

# 5. Membuat file service
SERVICE_PATH="/etc/systemd/system/vlc-telnet.service"

echo "📝 Membuat service di $SERVICE_PATH..."

sudo bash -c "cat > $SERVICE_PATH" <<EOF
[Unit]
Description=VLC Telnet Server Headless
After=network.target

[Service]
User=$CURRENT_USER
ExecStart=/usr/bin/cvlc -I telnet --telnet-host 0.0.0.0 --telnet-port 4212 --telnet-password $TELNET_PASS --aout alsa --vout dummy
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# 6. Reload dan Jalankan Service
echo "🚀 Mengaktifkan dan menjalankan service..."
sudo systemctl daemon-reload
sudo systemctl enable vlc-telnet.service
sudo systemctl start vlc-telnet.service

# 7. Verifikasi
echo "📊 Mengecek status service..."
sleep 2
sudo systemctl status vlc-telnet.service --no-pager

echo ""
echo "✅ Instalasi Selesai!"
echo "Anda bisa mengakses VLC Telnet pada port 4212 menggunakan password yang telah dibuat."
