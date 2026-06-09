# VLC Telnet Server for Proxmox

Turn your **Proxmox host** into a dedicated VLC Telnet audio server for **Home Assistant** and other automation platforms.

---

## 🎯 Why?

Home Assistant OS (HAOS) running as a virtual machine on Proxmox may have issues with audio hardware passthrough or device compatibility. Instead of passing physical audio devices directly to HAOS, this project allows the Proxmox host to handle audio playback while Home Assistant simply sends playback commands over Telnet.

This approach provides a simple and reliable solution for:

* 🔊 Text-to-Speech (TTS)
* 🚪 Doorbell announcements
* 🚨 Alarm sounds
* 🔔 Notifications
* 🎵 Media playback
* 🏠 Multi-room audio

---

## 📖 How It Works

```text
                   Telnet
+----------------+ -------> +----------------------+
|                |          |                      |
| Home Assistant |          | Proxmox Host        |
|     (HAOS)     |          | VLC Telnet Server   |
|                |          |                      |
+----------------+          +----------+-----------+
                                       |
                                       |
                                       v
                              +------------------+
                              | Physical Speaker |
                              | USB / HDMI / AUX |
                              +------------------+
```

Home Assistant acts as the client and sends commands to the VLC Telnet Server running on the Proxmox host. VLC then plays audio through the host's connected audio device.

---

## ✨ Features

* Lightweight VLC Telnet server
* Designed for Proxmox environments
* No audio passthrough required for HAOS
* Supports multiple VLC instances
* Ideal for Home Assistant automations
* Automatic startup with systemd
* Compatible with USB, HDMI, and onboard audio devices

---

# 🔊 Multi-Speaker Setup Guide

This guide explains how to run multiple VLC Telnet Server instances simultaneously to support a multi-speaker setup using `systemd`.

---

## 🚀 Step 1: Create the Service for Instance 1

```bash
sudo nano /etc/systemd/system/vlc-telnet-1.service
```

Paste:

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
> Press `Ctrl + O`, `Enter`, then `Ctrl + X`.

---

## 🚀 Step 2: Create the Service for Instance 2

```bash
sudo nano /etc/systemd/system/vlc-telnet-2.service
```

Paste:

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

## ⚙️ Step 3: Enable and Start the Services

Reload systemd:

```bash
sudo systemctl daemon-reload
```

Enable auto start:

```bash
sudo systemctl enable vlc-telnet-1
sudo systemctl enable vlc-telnet-2
```

Start services:

```bash
sudo systemctl start vlc-telnet-1
sudo systemctl start vlc-telnet-2
```

---

## 📊 Step 4: Verify

Check the service status:

```bash
sudo systemctl status vlc-telnet-1 vlc-telnet-2
```

> [!NOTE]
> If both services show **active (running)**, everything is working correctly.

---

## 🛠 Useful Commands

| Command                               | Description           |
| :------------------------------------ | :-------------------- |
| `sudo systemctl stop vlc-telnet-1`    | Stop the service      |
| `sudo systemctl restart vlc-telnet-1` | Restart after changes |
| `journalctl -u vlc-telnet-1 -f`       | View real-time logs   |

---

## 🔀 Adding More Speakers

You can create additional instances simply by:

* Copying an existing service file.
* Changing the Telnet port.
* Starting the new service.

Example:

| Instance  | Port |
| :-------- | :--- |
| Speaker 1 | 4212 |
| Speaker 2 | 4213 |
| Speaker 3 | 4214 |
| Speaker 4 | 4215 |

Each instance can be controlled independently from Home Assistant.

---

## 🔐 Security

> [!WARNING]
> Do not expose the Telnet ports to the public internet.

Recommended:

* ✅ Local network only
* ✅ Protect with a firewall
* ✅ Use a strong Telnet password

---

## 💡 Example Home Assistant Use Cases

* TTS announcements
* Doorbell notifications
* Alarm sounds
* Package delivery alerts
* Multi-room audio
* Automation notifications

---

## ✅ Done!

After rebooting your Proxmox host, all VLC Telnet Server instances will start automatically and be ready to accept connections from Home Assistant.

---

## 🚀 Project Goal

The goal of this project is to provide a simple and reliable audio server for Home Assistant users running HAOS on Proxmox, eliminating the need for complicated audio passthrough while supporting scalable multi-speaker setups.
