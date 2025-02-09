#!/bin/bash
# XDG-Desktop-Portals #

# source library
. <(curl -sSL https://bit.ly/nhattVim_lib)

# start script
xdg=(
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
)

# XDG-DESKTOP-PORTAL-HYPRLAND
for xdgs in "${xdg[@]}"; do
    iAur "$xdgs"
    if [ $? -ne 0 ]; then
        err "$xdgs install had failed"
    fi
done

# Clean out other portals
note "Clearing any other xdg-desktop-portal implementations..."
if pacman -Qs xdg-desktop-portal-wlr >/dev/null; then
    act "Removing xdg-desktop-portal-wlr..."
    sudo pacman -R --noconfirm xdg-desktop-portal-wlr
fi
if pacman -Qs xdg-desktop-portal-lxqt >/dev/null; then
    act "Removing xdg-desktop-portal-lxqt..."
    sudo pacman -R --noconfirm xdg-desktop-portal-lxqt
fi
