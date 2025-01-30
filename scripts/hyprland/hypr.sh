#!/bin/bash
# Main Hyprland Package

# source library
. <(curl -sSL https://is.gd/nhattVim_lib)

# start script
hypr=(
    hyprcursor
    hyprutils
    aquamarine
    hypridle
    hyprlock
    hyprland
    pyprland
    hyprland-qtutils
    libspng
)

uninstall=(
    hyprland-git
    hyprland-nvidia
    hyprland-nvidia-git
    hyprland-nvidia-hidpi-git
)

# Removing other Hyprland to avoid conflict
note "Checking for other hyprland packages and remove if any..."
if pacman -Qs hyprland >/dev/null; then
    for PKG in "${uninstall[@]}"; do
        uPac "$PKG"
        if [ $? -ne 0 ]; then
            err "$PKG uninstallation had failed"
        fi
    done
fi

# Hyprland
note "Installing Hyprland......"
for HYPR in "${hypr[@]}"; do
    iAur "$HYPR"
    [ $? -ne 0 ] && {
        err "$HYPR install had failed"
    }
done
