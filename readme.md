# VLC Telnet Server for Debian/Ubuntu LXC

A lightweight VLC telnet server installer for Debian/Ubuntu LXC containers.

This project automatically installs and configures:

- VLC
- ALSA audio
- VLC telnet (RC) interface
- Persistent systemd user service
- Auto-start on boot
- Audio verification
- Service verification

Designed for Home Assistant integrations using VLC telnet control.

---

# Features

- Non-root installation
- Runs VLC as the current user
- Automatic ALSA configuration
- Automatic systemd user service
- Persistent service after reboot/logout
- Pre-install safety checks
- Post-install verification
- Clean uninstaller included

---

# Requirements

- Debian 11+ or Ubuntu 22.04+
- LXC container or VM
- User with sudo access
- Audio device already passed through to the container
- Internet connection

---

# Repository

GitHub Repository:

https://github.com/Owie2711/vlc-telnet-server

---

# Files

| File | Description |
|------|-------------|
| `install-vlc-telnet.sh` | Install and configure VLC telnet server |
| `uninstall-vlc-telnet.sh` | Remove VLC telnet server cleanly |

---

# How It Works

The installer performs the following steps:

1. Verifies system compatibility
2. Verifies sudo access
3. Verifies no existing VLC telnet server is running
4. Installs required packages:
   - VLC
   - ALSA utilities
   - Netcat
5. Verifies ALSA audio device access
6. Creates VLC telnet configuration
7. Creates a persistent systemd user service
8. Enables `loginctl linger`
9. Starts VLC telnet server
10. Verifies:
    - Service status
    - Startup persistence
    - Listening port
    - Telnet responsiveness

---

# Default Configuration

| Setting | Value |
|----------|------|
| Port | `4212` |
| Password | `1234` |
| Interface | `0.0.0.0` |
| Audio Output | ALSA |

---

# Installation

## Option 1 — Clone Repository

Clone repository:

```bash
git clone https://github.com/Owie2711/vlc-telnet-server.git
```

Enter directory:

```bash
cd vlc-telnet-server
```

Make installer executable:

```bash
chmod +x install-vlc-telnet.sh
```

Run installer:

```bash
./install-vlc-telnet.sh
```

---

## Option 2 — Direct Install from GitHub

Run directly from GitHub:

```bash
bash <(curl -sSL https://raw.githubusercontent.com/Owie2711/vlc-telnet-server/main/install-vlc-telnet.sh)
```

---

# Important

Do NOT run the installer as root.

Correct:

```bash
./install-vlc-telnet.sh
```

Wrong:

```bash
sudo ./install-vlc-telnet.sh
```

The installer must run as a normal user with sudo privileges because it creates a persistent user-level systemd service.

---

# Verify Installation

Check service status:

```bash
systemctl --user status vlc-telnet
```

Verify listening port:

```bash
ss -tulpn | grep 4212
```

Test telnet connection:

```bash
telnet <LXC-IP> 4212
```

---

# Reboot Verification

After installation, reboot the container:

```bash
sudo reboot
```

Without logging in, verify the service is listening:

```bash
ss -tulpn | grep 4212
```

If the port is listening immediately after boot, persistent user services are working correctly.

---

# Home Assistant Example

Example VLC telnet integration:

```yaml
media_player:
  - platform: vlc_telnet
    name: VLC
    host: 192.168.1.10
    port: 4212
    password: 1234
```

---

# Uninstall

## Local Uninstall

Make executable:

```bash
chmod +x uninstall-vlc-telnet.sh
```

Run uninstaller:

```bash
./uninstall-vlc-telnet.sh
```

---

## Direct Uninstall from GitHub

```bash
bash <(curl -sSL https://raw.githubusercontent.com/Owie2711/vlc-telnet-server/main/uninstall-vlc-telnet.sh)
```

---

# What the Uninstaller Removes

- VLC telnet systemd user service
- VLC telnet configuration
- Service startup persistence
- Optional package removal:
  - VLC
  - ALSA utilities
  - Netcat

---

# Troubleshooting

## No Audio Output

Verify ALSA device detection:

```bash
aplay -l
```

If no sound card appears:
- audio passthrough is not configured correctly
- `/dev/snd` may not exist inside the container

---

## Service Not Starting

Check service logs:

```bash
journalctl --user -u vlc-telnet -n 100
```

---

## Port Already In Use

Check conflicting process:

```bash
ss -tulpn | grep 4212
```

---

# Notes

This project is optimized for:

- Home Assistant
- Debian/Ubuntu LXC containers
- Simple internal network audio automation

It is intentionally lightweight and minimal.