# Arch Linux Setup - Hyprland Desktop

## Pre-requisites
- Arch Linux ISO on USB (https://archlinux.org/download/)
- Secure Boot **disabled** in UEFI (ASUS: Boot > OS Type > Other OS)
- Windows is on `nvme1n1` — DO NOT touch this drive
- Arch installs to `nvme0n1` (replacing Fedora)

## Phase 1: Install Arch

Boot from Arch USB, then copy-paste this entire block:

```
curl -LO https://raw.githubusercontent.com/Zacknetic/arch-setup/main/user_configuration.json && curl -LO https://raw.githubusercontent.com/Zacknetic/arch-setup/main/user_credentials.json && nano user_credentials.json
```

Change the two passwords in nano, save (Ctrl+O, Enter, Ctrl+X), then run:

```
archinstall --config user_configuration.json --creds user_credentials.json
```

When prompted for disk config:
- Select `nvme0n1` (1.8TB NVMe — this has Fedora)
- Choose **Wipe all selected drives**
- Filesystem: **btrfs** with compression
- **TRIPLE CHECK you are NOT selecting nvme1n1 (Windows)**

Reboot when done. Remove USB.

## Phase 2: Post-Install

Login at TTY as `zack`, then copy-paste:

```
curl -LO https://raw.githubusercontent.com/Zacknetic/arch-setup/main/post-install.sh && bash post-install.sh
```

When done:

```
sudo reboot
```

SDDM starts. Select **Hyprland** and login.

## Key Bindings

| Key | Action |
|-----|--------|
| SUPER + Return | Terminal (Kitty) |
| SUPER + Space | App launcher (Rofi) |
| SUPER + Q | Close window |
| SUPER + E | File manager (Thunar) |
| SUPER + F | Fullscreen |
| SUPER + V | Toggle floating |
| SUPER + 1-0 | Switch workspace |
| SUPER + SHIFT + 1-0 | Move window to workspace |
| Print | Screenshot (select area) |
| SUPER + drag | Move window |
| SUPER + right-drag | Resize window |

## Hardware Notes

- **GPU**: RTX 4070 — nvidia-dkms with mkinitcpio hooks (auto-rebuilds on kernel update)
- **Webcam**: Logitech BRIO — PipeWire config hides IR camera to prevent app crashes
- **Dual Boot**: Windows on nvme1n1 untouched. Use UEFI boot menu (F8/F12) to switch OS.

## Recovery

If Hyprland doesn't start:
1. `Ctrl+Alt+F2` for TTY
2. Login as zack or root
3. Check: `journalctl -b | grep -i nvidia`
4. Rebuild: `sudo mkinitcpio -P`
5. Emergency: add `nvidia.modeset=0` to boot params for basic mode

## What's Installed

**Phase 1 (archinstall):** base system, linux kernel, systemd-boot, NetworkManager, PipeWire audio, NVIDIA drivers, bluetooth, Docker, Flatpak, Firefox, dev tools

**Phase 2 (post-install.sh):** Hyprland, Waybar, Rofi, Kitty, Thunar, Mako notifications, SDDM, paru (AUR helper), Equibop (Discord), VS Code, Claude Code, JetBrains Mono Nerd Font, Tokyo Night color scheme
