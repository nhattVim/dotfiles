#!/bin/bash
# XDG-Desktop-Portals #

# source library
. <(curl -sSL https://raw.githubusercontent.com/nhattVim/dotfiles/refs/heads/master/scripts/lib.sh)

# start script
xdg=(
    xdg-desktop-portal
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
)

# conflic xdg-desktop-portal
remove=(
    xdg-desktop-portal-wlr
    xdg-desktop-portal-gnome
    xdg-desktop-portal-kde
    xdg-desktop-portal-lxqt
)

# XDG-DESKTOP-PORTAL-HYPRLAND
for xdgs in "${xdg[@]}"; do
    install_arch_pkg "$xdgs"
done

# Remove conflic xdg-desktop-portal
note "Clearing any other xdg-desktop-portal implementations..."
for xdgs in "${remove[@]}"; do
    uninstall_arch_pkg "$xdgs"
done