#!/bin/bash
# Paru AUR Helper
# YELLOW: If yay is already installed, paru will not be installed

# source library
source <(curl -sSL https://is.gd/nhattVim_lib)

# start script
cd $HOME
if [ -d paru-bin ]; then
    rm -rf paru-bin
fi

if [ -n "$ISAUR" ]; then
    ok "AUR helper already installed, moving on."
else
    note "AUR helper was NOT located"
    note "Installing paru from AUR"
    git clone https://aur.archlinux.org/paru-bin.git || {
        err "Failed to clone paru from AUR"
        exit 1
    }
    cd paru-bin || {
        err "Failed to enter paru-bin directory"
        exit 1
    }
    makepkg -si --noconfirm || {
        err "Failed to install paru from AUR"
        exit 1
    }
    cd ~ && rm -rf paru-bin || {
        err "Failed to remove paru-bin directory"
        exit 1
    }
fi

# Update system before proceeding
note "Perfoming a full system update to avoid issues...."
ISAUR=$(command -v yay || command -v paru)

$ISAUR -Syu --noconfirm || {
    err "Failed to update system"
    exit 1
}
