#!/bin/bash
# Unified Installation Script for Hyprland Environment

# Source library
. <(curl -sSL https://raw.githubusercontent.com/nhattVim/dotfiles/refs/heads/master/scripts/lib.sh)

pacman_pkgs=(
    base
    base-devel
    linux
    linux-headers
    linux-firmware
    linux-lts
    linux-lts-headers
    khanh-xinh
)

note "Installing pacman packages..."
for pkg in "${pacman_pkgs[@]}"; do
    iPac "$pkg"
done

# Check log
if [ -f $HOME/install.log ]; then
    gum confirm "${CYAN} Do you want to check log?" && gum pager <$HOME/install.log
    gum confirm "${CYAN} Do you want to reinstall failed packages?" && reinstall_failed_pkgs
fi
