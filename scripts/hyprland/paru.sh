#!/bin/bash
# Paru AUR Helper

# Source library
. <(curl -sSL https://is.gd/nhattVim_lib)

if [ -n "$ISAUR" ]; then
    ok "AUR helper already installed, moving on."
else
    note "AUR helper was NOT located."

    MAX_RETRIES=3
    attempt=1

    while [ $attempt -le $MAX_RETRIES ]; do
        note "Installing paru from (Attempt $attempt) AUR..."

        temp_dir=$(mktemp -d)

        git clone https://aur.archlinux.org/paru-bin.git "$temp_dir" && cd "$temp_dir" || {
            err "Failed to clone paru from AUR (Attempt $attempt)"
            ((attempt++))
            continue
        }

        if makepkg -si --noconfirm; then
            ok "Successfully installed paru!"
            rm -rf "$temp_dir"
            break
        else
            err "Failed to install paru from AUR (Attempt $attempt)"
            rm -rf "$temp_dir"
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
