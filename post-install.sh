#!/bin/bash
# Arch Linux Post-Install Script
# Run as your user (zack), NOT as root
# Usage: bash post-install.sh
set -e

echo "=== Phase 1: AUR Helper (paru) ==="
if ! command -v paru &> /dev/null; then
    cd /tmp
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si --noconfirm
    cd ~
fi

echo "=== Phase 2: Hyprland Desktop Environment ==="
paru -S --noconfirm --needed \
    hyprland hyprpaper hyprlock hypridle hyprsunset \
    waybar rofi-wayland wlogout swww nwg-look \
    qt5-wayland qt6-wayland

echo "=== Phase 3: Fonts ==="
paru -S --noconfirm --needed \
    ttf-jetbrains-mono-nerd ttf-font-awesome \
    ttf-nerd-fonts-symbols noto-fonts noto-fonts-cjk noto-fonts-emoji

echo "=== Phase 4: Apps ==="
paru -S --noconfirm --needed \
    equibop-bin visual-studio-code-bin cheese \
    gnome-calculator file-roller pavucontrol \
    nm-connection-editor starship

echo "=== Phase 5: Claude Code ==="
curl -fsSL https://claude.ai/install.sh | sh

echo "=== Phase 6: Display Manager (SDDM) ==="
sudo pacman -S --noconfirm --needed sddm
sudo systemctl enable sddm

echo "=== Phase 7: NVIDIA Pacman Hook ==="
sudo mkdir -p /etc/pacman.d/hooks
sudo tee /etc/pacman.d/hooks/nvidia.hook > /dev/null << 'EOF'
[Trigger]
Operation=Install
Operation=Upgrade
Operation=Remove
Type=Package
Target=nvidia-dkms
Target=linux
Target=linux-headers
[Action]
Description=Rebuilding initramfs after NVIDIA driver update...
Depends=mkinitcpio
When=PostTransaction
NeedsTargets
Exec=/bin/sh -c 'while read -r trg; do case $trg in linux*) exit 0; esac; done; /usr/bin/mkinitcpio -P'
EOF

echo "=== Phase 8: Logitech BRIO Webcam Fix ==="
mkdir -p ~/.config/pipewire/pipewire.conf.d
cat > ~/.config/pipewire/pipewire.conf.d/hide-brio-ir.conf << 'EOF'
monitor.v4l2.rules = [
    {
        matches = [
            {
                device.vendor.id = "0x046d"
                device.product.id = "0x085e"
                api.v4l2.cap.device-caps = "04200001"
            }
        ]
        actions = {
            update-props = {
                node.disabled = true
            }
        }
    }
]
EOF

echo "=== Phase 9: Hyprland Base Config ==="
mkdir -p ~/.config/hypr
cat > ~/.config/hypr/hyprland.conf << 'HYPRCONF'
monitor=,preferred,auto,1
env = LIBVA_DRIVER_NAME,nvidia
env = XDG_SESSION_TYPE,wayland
env = GBM_BACKEND,nvidia-drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = NVD_BACKEND,direct
cursor {
    no_hardware_cursors = false
}
input {
    kb_layout = us
    follow_mouse = 1
    sensitivity = 0
}
general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    col.inactive_border = rgba(595959aa)
    layout = dwindle
}
decoration {
    rounding = 10
    blur {
        enabled = true
        size = 3
        passes = 1
    }
}
animations {
    enabled = yes
    bezier = myBezier, 0.05, 0.9, 0.1, 1.05
    animation = windows, 1, 7, myBezier
    animation = windowsOut, 1, 7, default, popin 80%
    animation = border, 1, 10, default
    animation = fade, 1, 7, default
    animation = workspaces, 1, 6, default
}
dwindle {
    pseudotile = yes
    preserve_split = yes
}
$mainMod = SUPER
bind = $mainMod, Return, exec, kitty
bind = $mainMod, Q, killactive,
bind = $mainMod SHIFT, E, exit,
bind = $mainMod, E, exec, thunar
bind = $mainMod, V, togglefloating,
bind = $mainMod, Space, exec, rofi -show drun
bind = $mainMod, F, fullscreen,
bind = , Print, exec, grim -g "$(slurp)" - | wl-copy
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod, 9, workspace, 9
bind = $mainMod, 0, workspace, 10
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
bind = $mainMod SHIFT, 6, movetoworkspace, 6
bind = $mainMod SHIFT, 7, movetoworkspace, 7
bind = $mainMod SHIFT, 8, movetoworkspace, 8
bind = $mainMod SHIFT, 9, movetoworkspace, 9
bind = $mainMod SHIFT, 0, movetoworkspace, 10
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow
bind = $mainMod, mouse_down, workspace, e+1
bind = $mainMod, mouse_up, workspace, e-1
bind = $mainMod CTRL, left, resizeactive, -20 0
bind = $mainMod CTRL, right, resizeactive, 20 0
bind = $mainMod CTRL, up, resizeactive, 0 -20
bind = $mainMod CTRL, down, resizeactive, 0 20
exec-once = waybar
exec-once = mako
exec-once = /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
exec-once = hyprpaper
exec-once = wl-paste --type text --watch cliphist store
exec-once = wl-paste --type image --watch cliphist store
HYPRCONF

echo "=== Phase 10: Waybar Config ==="
mkdir -p ~/.config/waybar
cat > ~/.config/waybar/config.jsonc << 'WAYBARCONF'
{
    "layer": "top", "position": "top", "height": 35, "spacing": 4,
    "modules-left": ["hyprland/workspaces"],
    "modules-center": ["clock"],
    "modules-right": ["pulseaudio", "network", "cpu", "memory", "tray"],
    "clock": { "format": "{:%Y-%m-%d  %H:%M}" },
    "cpu": { "format": "CPU {usage}%" },
    "memory": { "format": "RAM {}%" },
    "network": { "format-wifi": "{essid}", "format-ethernet": "ETH", "format-disconnected": "OFF" },
    "pulseaudio": { "format": "VOL {volume}%", "format-muted": "MUTE", "on-click": "pavucontrol" },
    "tray": { "spacing": 10 }
}
WAYBARCONF

cat > ~/.config/waybar/style.css << 'WAYBARCSS'
* { font-family: "JetBrainsMono Nerd Font"; font-size: 13px; }
window#waybar { background-color: rgba(26, 27, 38, 0.85); color: #c0caf5; border-bottom: 2px solid rgba(51, 204, 255, 0.5); }
#workspaces button { padding: 0 8px; color: #565f89; }
#workspaces button.active { color: #33ccff; border-bottom: 2px solid #33ccff; }
#clock, #cpu, #memory, #network, #pulseaudio, #tray { padding: 0 10px; }
WAYBARCSS

echo "=== Phase 11: Kitty Config ==="
mkdir -p ~/.config/kitty
cat > ~/.config/kitty/kitty.conf << 'KITTYCONF'
font_family      JetBrainsMono Nerd Font
font_size 12.0
background_opacity 0.85
confirm_os_window_close 0
foreground #c0caf5
background #1a1b26
color0 #15161e
color1 #f7768e
color2 #9ece6a
color3 #e0af68
color4 #7aa2f7
color5 #bb9af7
color6 #7dcfff
color7 #a9b1d6
KITTYCONF

echo "=== Phase 12: Mako + Starship ==="
mkdir -p ~/.config/mako
cat > ~/.config/mako/config << 'MAKOCONF'
default-timeout=5000
border-size=2
border-color=#33ccff
border-radius=10
background-color=#1a1b26ee
text-color=#c0caf5
font=JetBrainsMono Nerd Font 11
MAKOCONF

cat >> ~/.bashrc << 'BASHRC'
eval "$(starship init bash)"
alias ls='ls --color=auto'
alias ll='ls -la'
alias update='paru -Syu'
BASHRC

echo "=== Phase 13: Flatpak Setup ==="
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

echo ""
echo "============================================"
echo "  Setup complete! Reboot to start Hyprland."
echo "============================================"
echo ""
echo "Key bindings:"
echo "  SUPER + Return  = Terminal (Kitty)"
echo "  SUPER + Space   = App launcher (Rofi)"
echo "  SUPER + Q       = Close window"
echo "  SUPER + E       = File manager (Thunar)"
echo "  SUPER + F       = Fullscreen"
echo "  SUPER + 1-0     = Switch workspace"
echo "  Print           = Screenshot (select area)"
echo ""
echo "Run 'sudo reboot' then select Hyprland in SDDM."
