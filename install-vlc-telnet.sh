#!/bin/bash

set -euo pipefail

PORT=4212
PASSWORD="1234"
SERVICE_NAME="vlc-telnet"

echo "========================================="
echo " VLC Telnet Installer"
echo "========================================="

trap 'echo "[ERROR] Installation failed"' ERR

#
# PRECHECK
#

# Prevent running as root
if [ "$EUID" -eq 0 ]; then
    echo "[ERROR] Do not run this script as root"
    exit 1
fi

# Verify sudo access
if ! sudo -v; then
    echo "[ERROR] Current user does not have sudo access"
    exit 1
fi

# Verify supported OS
if ! grep -qiE 'debian|ubuntu' /etc/os-release; then
    echo "[ERROR] Only Debian/Ubuntu are supported"
    exit 1
fi

# Check existing VLC telnet process
if pgrep -f "vlc.*rc" > /dev/null; then
    echo "[ERROR] VLC telnet server is already running"
    exit 1
fi

# Check existing port usage
if ss -tulpn | grep -q ":${PORT} "; then
    echo "[ERROR] Port ${PORT} is already in use"
    ss -tulpn | grep ":${PORT} "
    exit 1
fi

# Check existing service
if systemctl --user list-unit-files | grep -q "${SERVICE_NAME}.service"; then
    echo "[ERROR] ${SERVICE_NAME} service already exists"
    exit 1
fi

# Check existing VLC config
if [ -f "$HOME/.config/vlc/vlcrc" ]; then
    echo "[ERROR] Existing VLC config detected:"
    echo "$HOME/.config/vlc/vlcrc"
    exit 1
fi

echo "[OK] Precheck passed"

#
# INSTALL PACKAGES
#

echo
echo "Installing required packages..."

sudo apt update

sudo apt install -y \
    vlc \
    alsa-utils \
    netcat-openbsd

echo "[OK] Packages installed"

#
# VERIFY ALSA
#

echo
echo "Checking ALSA audio devices..."

if ! aplay -l > /dev/null 2>&1; then
    echo "[ERROR] No ALSA audio device detected"
    exit 1
fi

echo "[OK] ALSA audio device detected"

#
# CREATE VLC CONFIG
#

echo
echo "Creating VLC configuration..."

mkdir -p "$HOME/.config/vlc"

cat > "$HOME/.config/vlc/vlcrc" <<EOF
extraintf=rc
rc-host=0.0.0.0:${PORT}
rc-password=${PASSWORD}
aout=alsa
alsa-audio-device=default
EOF

echo "[OK] VLC configuration created"

#
# CREATE SYSTEMD USER SERVICE
#

echo
echo "Creating systemd user service..."

mkdir -p "$HOME/.config/systemd/user"

cat > "$HOME/.config/systemd/user/${SERVICE_NAME}.service" <<EOF
[Unit]
Description=VLC Telnet Server
After=network.target sound.target

[Service]
Type=simple
ExecStart=/usr/bin/cvlc \\
    --intf rc \\
    --rc-host 0.0.0.0:${PORT} \\
    --rc-password ${PASSWORD}

Restart=always
RestartSec=5

[Install]
WantedBy=default.target
EOF

echo "[OK] Service file created"

#
# ENABLE PERSISTENT USER SERVICE
#

echo
echo "Enabling persistent user services..."

sudo loginctl enable-linger "$USER"

echo "[OK] Linger enabled"

#
# ENABLE & START SERVICE
#

echo
echo "Starting VLC telnet service..."

systemctl --user daemon-reload
systemctl --user enable "${SERVICE_NAME}"
systemctl --user start "${SERVICE_NAME}"

sleep 3

#
# POST-INSTALL VERIFICATION
#

echo
echo "Running verification checks..."

# Verify service running
if ! systemctl --user is-active --quiet "${SERVICE_NAME}"; then
    echo "[ERROR] Service failed to start"
    systemctl --user status "${SERVICE_NAME}"
    exit 1
fi

echo "[OK] Service is running"

# Verify startup enabled
if ! systemctl --user is-enabled --quiet "${SERVICE_NAME}"; then
    echo "[ERROR] Service is not enabled at startup"
    exit 1
fi

echo "[OK] Service enabled at startup"

# Verify port listening
if ! ss -tulpn | grep -q ":${PORT} "; then
    echo "[ERROR] Port ${PORT} is not listening"
    exit 1
fi

echo "[OK] Port ${PORT} is listening"

# Verify telnet response
if ! timeout 5 bash -c "echo 'help' | nc localhost ${PORT}" > /dev/null 2>&1; then
    echo "[ERROR] VLC telnet server is not responding"
    exit 1
fi

echo "[OK] VLC telnet server responding"

#
# COMPLETE
#

echo
echo "========================================="
echo " INSTALLATION COMPLETE"
echo "========================================="
echo
echo "Host      : 0.0.0.0"
echo "Port      : ${PORT}"
echo "Password  : ${PASSWORD}"
echo
echo "Service Commands:"
echo "systemctl --user status ${SERVICE_NAME}"
echo
echo "Test Connection:"
echo "telnet <LXC-IP> ${PORT}"
echo