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

Change the two passwords in nano, save (Ctrl+O, Enter, Ctrl+X).

### BEFORE running archinstall — verify which drive is which:

```
lsblk -f
```

Look at the output:
- The **Windows** drive will have `ntfs` partitions — this is `nvme1n1`. DO NOT TOUCH.
- The **Fedora** drive will have `btrfs` and `ext4` partitions — this is `nvme0n1`. Install here.
- Fedora root partition UUID from our install: `a6f038d3-0703-42d9-9570-086acfb4861a`

If the drives are swapped from what's listed above, adjust accordingly. **Trust the filesystem types, not the device names.**

Now run:

```
archinstall --config user_configuration.json --creds user_credentials.json
```

When prompted for disk config:
- Select the drive with btrfs/ext4 (the Fedora drive)
- Choose **Wipe all selected drives**
- Filesystem: **btrfs** with compression
- **TRIPLE CHECK you are NOT selecting the ntfs (Windows) drive**

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
- **Dual Boot**: Windows on other NVMe untouched. Use UEFI boot menu (F8/F12) to switch OS.

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
