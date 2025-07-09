#!/bin/bash
# Paru AUR Helper Installer

# Source library
. <(curl -sSL https://raw.githubusercontent.com/nhattVim/dotfiles/refs/heads/master/scripts/lib.sh)

ISAUR=$(command -v yay || command -v paru)

if [ -n "$ISAUR" ]; then
    ok "AUR helper already installed, moving on."
else
    note "AUR helper was NOT located."

    MAX_RETRIES=3
    attempt=1

    while [ $attempt -le $MAX_RETRIES ]; do
        note "Installing paru from AUR (Attempt $attempt)..."

        temp_dir=$(mktemp -d)

        if git clone https://aur.archlinux.org/paru-bin.git "$temp_dir" && cd "$temp_dir"; then
            if makepkg -si --noconfirm; then
                ok "Successfully installed paru!"
                rm -rf "$temp_dir"
                break
            else
                err "Failed to install paru (Attempt $attempt)"
            fi
        else
            err "Failed to clone paru (Attempt $attempt)"
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

$ISAUR -Syu --noconfirm || {
    err "Failed to update system"
    exit 1
}
