#!/bin/bash
# Yay AUR Helper

# Source library
. <(curl -sSL https://nhattVim.github.io/lib.sh)

if [ -n "$ISAUR" ]; then
    ok "AUR helper already installed, moving on."
else
    note "AUR helper was NOT located."

    MAX_RETRIES=3
    attempt=1

    while [ $attempt -le $MAX_RETRIES ]; do
        note "Installing yay from AUR (Attempt $attempt)..."

        temp_dir=$(mktemp -d)

        git clone https://aur.archlinux.org/yay-bin.git "$temp_dir" && cd "$temp_dir" || {
            err "Failed to clone yay from AUR (Attempt $attempt)"
            ((attempt++))
            continue
        }

        if makepkg -si --noconfirm; then
            ok "Successfully installed yay!"
            rm -rf "$temp_dir"
            break
        else
            err "Failed to install yay from AUR (Attempt $attempt)"
            rm -rf "$temp_dir"
            ((attempt++))
        fi

        rm -rf "$temp_dir"
        ok "Successfully installed yay!"
        break
    done

    if [ $attempt -gt $MAX_RETRIES ]; then
        err "Exceeded maximum retries. Exiting..."
        exit 1
    fi
fi

# Update system before proceeding
note "Performing a full system update to avoid issues..."
ISAUR=$(command -v yay || command -v paru)

$ISAUR -Syu --noconfirm || {
    err "Failed to update system"
    exit 1
}
