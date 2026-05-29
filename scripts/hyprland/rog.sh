#!/bin/bash
# Asus ROG Laptops #

# Source library
. <(curl -sSL https://raw.githubusercontent.com/nhattVim/dotfiles/refs/heads/master/scripts/lib.sh)

# Packages
pacman=(power-profiles-daemon switcheroo-control)
aur=(asusctl supergfxctl rog-control-center)

# Install ASUS ROG packages
note "Installing ASUS ROG packages ..."

for pkg in "${pacman[@]}"; do
    iPac "$pkg"
done

for pkg in "${aur[@]}"; do
    iAur "$pkg"
done

# Enable ROG services
note "Activating ROG services..."
enable_service "supergfxd.service"
enable_service "switcheroo-control.service"
enable_service "power-profiles-daemon.service"

# Set battery charging limit
yes_no "Do you want to set battery charging limit (only for laptop)?" battery

if [ "$battery" == "Y" ]; then
    act "Setting up battery charge limit."
    number=$(gum input --prompt="-> " --width 80 --placeholder "Enter the battery charge limit (0 - 100):")
    asusctl battery limit $number
fi
