#!/bin/bash
# Yay AUR Helper Auto Retry Installer

# Source library
source <(curl -sSL https://is.gd/nhattVim_lib)

if [ -n "$ISAUR" ]; then
    ok "AUR helper already installed, moving on."
else
    note "AUR helper was NOT located."
    note "Installing yay from AUR ..."

    MAX_RETRIES=3
    attempt=1

    while [ $attempt -le $MAX_RETRIES ]; do
        note "Try to install yay from AUR (Attempt $attempt)..."

        cd "$HOME" && rm -rf yay

        git clone https://aur.archlinux.org/yay.git && cd yay || {
            err "Failed to clone yay from AUR (Attempt $attempt)"
            ((attempt++))
            continue
        }

        if makepkg -si --noconfirm; then
            ok "Successfully installed yay!"
            cd "$HOME" && rm -rf yay
            break
        else
            err "Failed to install yay from AUR (Attempt $attempt)"
            cd "$HOME"
            ((attempt++))
        fi

        if [ $attempt -gt $MAX_RETRIES ]; then
            err "Exceeded maximum retries. Exiting..."
            exit 1
        fi
    done
fi

# Update system before proceeding
note "Performing a full system update to avoid issues..."
ISAUR=$(command -v yay || command -v paru)

$ISAUR -Syu --noconfirm || {
    err "Failed to update system"
    exit 1
}
