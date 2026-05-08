#!/bin/bash

set -euo pipefail

SERVICE_NAME="vlc-telnet"
PORT=4212

echo "========================================="
echo " VLC Telnet Uninstaller"
echo "========================================="

trap 'echo "[ERROR] Uninstall failed"' ERR

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

echo "[OK] Precheck passed"

#
# STOP SERVICE
#

echo
echo "Stopping VLC telnet service..."

if systemctl --user list-unit-files | grep -q "${SERVICE_NAME}.service"; then

    systemctl --user stop "${SERVICE_NAME}" || true
    systemctl --user disable "${SERVICE_NAME}" || true

    echo "[OK] Service stopped and disabled"

else
    echo "[INFO] Service not found"
fi

#
# REMOVE SERVICE FILE
#

echo
echo "Removing service file..."

SERVICE_FILE="$HOME/.config/systemd/user/${SERVICE_NAME}.service"

if [ -f "$SERVICE_FILE" ]; then
    rm -f "$SERVICE_FILE"
    echo "[OK] Service file removed"
else
    echo "[INFO] Service file not found"
fi

#
# RELOAD SYSTEMD
#

echo
echo "Reloading systemd user daemon..."

systemctl --user daemon-reload

echo "[OK] Systemd daemon reloaded"

#
# REMOVE VLC CONFIG
#

echo
echo "Removing VLC configuration..."

VLC_CONFIG="$HOME/.config/vlc/vlcrc"

if [ -f "$VLC_CONFIG" ]; then
    rm -f "$VLC_CONFIG"
    echo "[OK] VLC configuration removed"
else
    echo "[INFO] VLC configuration not found"
fi

#
# OPTIONAL PACKAGE REMOVAL
#

echo
read -rp "Remove VLC and ALSA packages? (y/N): " REMOVE_PACKAGES

if [[ "$REMOVE_PACKAGES" =~ ^[Yy]$ ]]; then

    echo
    echo "Removing packages..."

    sudo apt remove --purge -y \
        vlc \
        alsa-utils \
        netcat-openbsd

    sudo apt autoremove -y

    echo "[OK] Packages removed"

else
    echo "[INFO] Package removal skipped"
fi

#
# VERIFY CLEANUP
#

echo
echo "Running cleanup verification..."

# Verify service removed
if systemctl --user list-unit-files | grep -q "${SERVICE_NAME}.service"; then
    echo "[ERROR] Service still exists"
    exit 1
fi

echo "[OK] Service removed"

# Verify port closed
if ss -tulpn | grep -q ":${PORT} "; then
    echo "[ERROR] Port ${PORT} is still in use"
    ss -tulpn | grep ":${PORT} "
    exit 1
fi

echo "[OK] Port ${PORT} is closed"

# Verify config removed
if [ -f "$VLC_CONFIG" ]; then
    echo "[ERROR] VLC config still exists"
    exit 1
fi

echo "[OK] VLC config removed"

#
# COMPLETE
#

echo
echo "========================================="
echo " UNINSTALL COMPLETE"
echo "========================================="
echo
echo "VLC telnet server has been removed."
echo