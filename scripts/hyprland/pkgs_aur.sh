#!/bin/bash
# Hyprland Packages

# source library
source <(curl -sSL https://is.gd/nhattVim_lib)

# start script
pkgs=(
    zen-browser-bin
    arttime-git
    pipes.sh
    tgpt-bin
    # microsoft-edge-stable-bin
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
    shell-color-scripts-git
    # wallust
    waybar
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

# Installation of main components
note "Installing hyprland packages..."
for PKG1 in "${hypr_pkgs[@]}" "${fonts[@]}" "${pkgs[@]}"; do
    iAur "$PKG1"
    if [ $? -ne 0 ]; then
        err "$PKG1 install had failed"
    fi
done

cargo install wallust
