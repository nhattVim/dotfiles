#!/bin/bash
# Asus ROG Laptops #

# Source library
. <(curl -sSL https://is.gd/nhattVim_lib)

pacman_pkgs=(
    power-profiles-daemon
)

aur_pkgs=(
    asusctl
    supergfxctl
    rog-control-center
)

note "Installing ASUS ROG packages ...\n"

for pkg in "${pacman_pkgs[@]}"; do
    iPac "$pkg"
done

for pkg in "${aur_pkgs[@]}"; do
    iAur "$pkg"
done

note "Activating ROG services..."
sudo systemctl enable supergfxd

note "Enabling power-profiles-daemon..."
sudo systemctl enable power-profiles-daemon
