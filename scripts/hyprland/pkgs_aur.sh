#!/bin/bash
# Hyprland Packages

# source library
source <(curl -sSL https://is.gd/nhattVim_lib)

# start script
pkgs=(
    microsoft-edge-stable
    arttime-git
    pipes.sh
    tgpt-bin
    # vmware-workstation
    # xampp
)

hypr_pkgs=(
    gvfs
    gvfs-mtp
    imagemagick
    kitty
    kvantum
    python-requests
    qt6-svg
    rofi-lbonn-wayland-git
    swaylock-effects-git
    swaync
    swww
    wlogout
    cava
    eog
    mousepad
    nwg-look-bin
    pacman-contrib
)

fonts=(
    adobe-source-code-pro-fonts
    noto-fonts-emoji
    otf-font-awesome
    ttf-droid
    ttf-fira-code
    ttf-jetbrains-mono
    ttf-jetbrains-mono-nerd
)

# List of packages to uninstall as it conflicts with swaync or causing swaync to not function properly
uninstall=(
    dunst
    mako
)

# Checking if mako or dunst is installed
note "Checking if mako or dunst are installed and removing for swaync to work properly"
for PKG in "${uninstall[@]}"; do
    uPac "$PKG"
    if [ $? -ne 0 ]; then
        err "$PKG uninstallation had failed"
    fi
done

# Installation of main components
note "Installing hyprland packages..."
for PKG1 in "${hypr_pkgs[@]}" "${fonts[@]}" "${pkgs[@]}"; do
    iAur "$PKG1"
    if [ $? -ne 0 ]; then
        err "$PKG1 install had failed"
    fi
done
