#!/bin/bash
# XDG-Desktop-Portals #

# source library
. <(curl -sSL https://raw.githubusercontent.com/nhattVim/dotfiles/refs/heads/master/scripts/lib.sh)

# start script
xdg=(
    xdg-desktop-portal-hyprland
    xdg-desktop-portal
)

# conflic xdg-desktop-portal
remove=(
    xdg-desktop-portal-gtk
    xdg-desktop-portal-wlr
    xdg-desktop-portal-gnome
    xdg-desktop-portal-kde
    xdg-desktop-portal-lxqt
)

# XDG-DESKTOP-PORTAL-HYPRLAND
for xdgs in "${xdg[@]}"; do
    iAur "$xdgs"
done

# Remove conflic xdg-desktop-portal
note "Clearing any other xdg-desktop-portal implementations..."
for xdgs in "${remove[@]}"; do
    act "Removing $xdgs..."
    sudo pacman -R --noconfirm "$xdgs"
done

# Configure xdg-desktop-portal
note "Configuring xdg-desktop-portal-hyprland..."
mkdir -p ~/.config/xdg-desktop-portal
cat <<EOF >~/.config/xdg-desktop-portal/portal.conf
[preferred]
default=hyprland
EOF

# Restart services
act "Restart portal services..."
systemctl --user daemon-reexec
systemctl --user restart xdg-desktop-portal.service
systemctl --user restart xdg-desktop-portal-hyprland.service || true
