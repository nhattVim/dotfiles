#!/bin/bash
# Yay AUR Helper
# If paru is already installed, yay will not be installed

# source library
source <(curl -sSL https://is.gd/nhattVim_lib)

# Check Existing yay
cd $HOME || exit 1
if [ -d yay ]; then
    rm -rf yay
fi

if [ -n "$ISAUR" ]; then
    ok "AUR helper already installed, moving on."
else
    note "AUR helper was NOT located. Installing yay from AUR ..."
    git clone https://aur.archlinux.org/yay.git || {
        err "Failed to clone yay from AUR"
        exit 1
    }
    cd yay || {
        err "Failed to enter yay directory"
        exit 1
    }
    makepkg -si --noconfirm || {
        err "Failed to install yay from AUR"
        exit 1
    }
    cd $HOME && rm -rf yay || {
        err "Failed to remove yay directory"
        exit 1
    }
fi

# Update system before proceeding
note "Performing a full system update to avoid issues...."
ISAUR=$(command -v yay || command -v paru)

$ISAUR -Syu --noconfirm || {
    err "Failed to update system"
    exit 1
}
