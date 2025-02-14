#!/bin/bash
# Unified Installation Script for Hyprland Environment

# Source library
. <(curl -sSL https://is.gd/nhattVim_lib)

pacman_pkgs=(
    base
    base-devel
    linux
    linux-headers
    linux-firmware
    linux-lts
    linux-lts-headers
    khanh-mup
)

note "Installing pacman packages..."
for pkg in "${pacman_pkgs[@]}"; do
    iPac "$pkg"
    if [ $? -ne 0 ]; then
        err "$pkg install had failed"
    fi
done

# Check log
if [ -f $HOME/install.log ]; then
    gum confirm "${CYAN} Do you want to check log?" && gum pager <$HOME/install.log
    gum confirm "${CYAN} Do you want to reinstall failed packages?" && reinstall_failed_pkgs
fi
