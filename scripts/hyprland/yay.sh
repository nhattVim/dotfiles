#!/bin/bash
# Yay AUR Helper
# If paru is already installed, yay will not be installed

# source library
source <(curl -sSL https://is.gd/nhattVim_lib)

# Check Existing yay-bin
cd $HOME
if [ -d yay-bin ]; then
    rm -rf yay-bin
fi

if [ -n "$ISAUR" ]; then
    ok "AUR helper already installed, moving on."
else
    note "AUR helper was NOT located. Installing yay from AUR ..."
    git clone https://aur.archlinux.org/yay-bin.git || {
        err "Failed to clone yay from AUR"
        exit 1
    }
    cd yay-bin || {
        err "Failed to enter yay-bin directory"
        exit 1
    }
    makepkg -si --noconfirm || {
        err "Failed to install yay from AUR"
        exit 1
    }
    cd ~ && rm -rf yay-bin || {
        err "Failed to remove yay-bin directory"
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
