# Arch Linux Setup - Hyprland Desktop

## Pre-requisites
- Arch Linux ISO on USB (https://archlinux.org/download/)
- Secure Boot **disabled** in UEFI (ASUS: Boot > OS Type > Other OS)
- Windows is on `nvme1n1` — DO NOT touch this drive
- Arch installs to `nvme0n1` (replacing Fedora)

## Phase 1: Install Arch

1. Boot from Arch USB
2. Connect to network (ethernet auto-connects, or use `iwctl` for wifi)
3. Download configs:
```
curl -LO https://raw.githubusercontent.com/Zacknetic/arch-setup/main/user_configuration.json
curl -LO https://raw.githubusercontent.com/Zacknetic/arch-setup/main/user_credentials.json
```
4. **Edit credentials:** `nano user_credentials.json` — set real passwords
5. Run: `archinstall --config user_configuration.json --creds user_credentials.json`
6. Disk config: select `nvme0n1`, wipe, btrfs. **DO NOT select nvme1n1 (Windows)**
7. Reboot when done, remove USB.

## Phase 2: Post-Install

1. Login at TTY as `zack`
2. Run:
```
curl -LO https://raw.githubusercontent.com/Zacknetic/arch-setup/main/post-install.sh
bash post-install.sh
sudo reboot
```
3. SDDM starts. Select **Hyprland** and login.
