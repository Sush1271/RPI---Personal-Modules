# RPI---Personal-Modules

A collection of utility scripts and configuration files for Raspberry Pi to automate home setup and network sharing.

## Modules

### 📺 TV Automation
- `tv-startup.sh`: Shell script to handle TV power-on sequences.
- `tv-wakeup.service`: Systemd service to automate the startup script on boot.

### 📁 Network Sharing
- `smb.conf`: Custom Samba configuration for network file sharing.

## Installation

1. Copy the desired configuration/script to your Raspberry Pi.
2. For the TV automation, enable the service:
   ```bash
   sudo cp tv-wakeup.service /etc/systemd/system/
   sudo systemctl enable tv-wakeup.service
   sudo systemctl start tv-wakeup.service
   ```
3. For Samba, back up your existing `smb.conf` and replace it with this version.
