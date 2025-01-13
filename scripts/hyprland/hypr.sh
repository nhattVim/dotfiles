#!/bin/bash
# Main Hyprland Package

# source library
source <(curl -sSL https://is.gd/nhattVim_lib)

# start script
hypr=(
    hyprland
)

# Removing other Hyprland to avoid conflict
note "Checking for other hyprland packages and remove if any..."
if pacman -Qs hyprland >/dev/null; then
    note "Hyprland detected. uninstalling to install Hyprland-git..."
    for hyprnvi in hyprland-git hyprland-nvidia hyprland-nvidia-git hyprland-nvidia-hidpi-git; do
        sudo pacman -R --noconfirm "$hyprnvi" 2>/dev/null || true
    done
fi

# Hyprland
note "Installing Hyprland......"
for HYPR in "${hypr[@]}"; do
    iAur "$HYPR" 2>&1
    [ $? -ne 0 ] && {
        err "$HYPR install had failed"
    }
done
