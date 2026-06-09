# 🔊 Multi-Speaker Setup Guide (VLC Telnet)

This guide explains how to run multiple VLC Telnet Server instances simultaneously to support a multi-speaker setup using `systemd`.

---

## 🚀 Step 1: Create the Service for Instance 1

Open a text editor with root privileges:

```bash
sudo nano /etc/systemd/system/vlc-telnet-1.service
```

Copy and paste the following configuration:

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
> Press `Ctrl + O`, then `Enter` to save the file, and `Ctrl + X` to exit Nano.

---

## 🚀 Step 2: Create the Service for Instance 2

Create another service for the second instance:

```bash
sudo nano /etc/systemd/system/vlc-telnet-2.service
```

Copy and paste the following configuration. Notice that the **Telnet port** is different:

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

After creating the service files, reload the `systemd` configuration and enable the services to start automatically at boot.

### 1. Reload the systemd daemon:

```bash
sudo systemctl daemon-reload
```

### 2. Enable the services:

```bash
sudo systemctl enable vlc-telnet-1
sudo systemctl enable vlc-telnet-2
```

### 3. Start the services:

```bash
sudo systemctl start vlc-telnet-1
sudo systemctl start vlc-telnet-2
```

---

## 📊 Step 4: Check the Service Status

To verify that both instances are running correctly, use:

```bash
sudo systemctl status vlc-telnet-1 vlc-telnet-2
```

> [!NOTE]
> If both services show **active (running)**, the setup was successful.

---

## 🛠️ Useful Commands

| Command                               | Description                                     |
| :------------------------------------ | :---------------------------------------------- |
| `sudo systemctl stop vlc-telnet-1`    | Temporarily stop the service                    |
| `sudo systemctl restart vlc-telnet-1` | Restart the service after configuration changes |
| `journalctl -u vlc-telnet-1 -f`       | View real-time logs for troubleshooting         |

---

## 💡 Additional Tips

> [!WARNING]
> This example uses the password `1234`. For security reasons, do **not** expose ports `4212` and `4213` to the public internet. Restrict access to your local network using a firewall such as UFW or Proxmox Firewall.

---

## ✅ Done!

Reboot your Linux system to verify that both VLC Telnet Server instances start automatically without any manual intervention.
