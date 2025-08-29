#!/bin/bash
# Paru AUR Helper Installer

# Source library
. <(curl -sSL https://raw.githubusercontent.com/nhattVim/dotfiles/refs/heads/master/scripts/lib.sh)

ISAUR=$(command -v yay || command -v paru)

if [ -n "$ISAUR" ]; then
    ok "AUR helper already installed: $ISAUR"
else
    note "AUR helper NOT found, installing paru from AUR..."

    MAX_RETRIES=3
    attempt=1

    while [ $attempt -le $MAX_RETRIES ]; do
        temp_dir=$(mktemp -d)
        note "Attempt $attempt: Cloning paru-bin..."
        if git clone https://aur.archlinux.org/paru-bin.git "$temp_dir" && cd "$temp_dir"; then
            if makepkg -si --noconfirm; then
                ok "Successfully installed paru!"
                rm -rf "$temp_dir"
                break
            else
                err "Failed to build/install paru (Attempt $attempt)"
            fi
        else
            err "Failed to clone paru-bin (Attempt $attempt)"
        fi

        rm -rf "$temp_dir"
        ((attempt++))
    done

    if [ $attempt -gt $MAX_RETRIES ]; then
        err "Exceeded maximum retries. Exiting..."
        exit 1
    fi

    ISAUR=$(command -v yay || command -v paru)
fi

# Update system before proceeding
note "Performing a full system update to avoid issues..."

# Update system
$ISAUR -Syu --noconfirm || {
    err "Failed to update system"
    exit 1
}

# Configure AUR helper
note "Generating package database for AUR helper..."
$ISAUR -Y --gendb || err "Could not generate database"

note "Enabling devel package tracking..."
$ISAUR -Y --devel --save || err "Could not enable devel tracking"

ok "AUR helper setup completed."
