#!/bin/bash
# Snap install script for Arch Linux

# Source library
. <(curl -sSL https://is.gd/nhattVim_lib)

# Check if snap is installed
if command -v snap &>/dev/null; then
    ok "Snap is already installed, moving on."
    exit 0
else
    note "Snap was NOT located."
fi

MAX_RETRIES=3
attempt=1

while [ $attempt -le $MAX_RETRIES ]; do
    note "Installing snap (Attempt $attempt)..."

    temp_dir=$(mktemp -d)

    if git clone https://aur.archlinux.org/snapd.git "$temp_dir"; then
        cd "$temp_dir" || { err "Failed to enter snapd directory (Attempt $attempt)"; rm -rf "$temp_dir"; ((attempt++)); continue; }
    else
        err "Failed to clone snapd (Attempt $attempt)"
        rm -rf "$temp_dir"
        ((attempt++))
        continue
    fi

    if makepkg -si --noconfirm; then
        ok "Successfully installed snap!"
        rm -rf "$temp_dir"
        break
    else
        err "Failed to install snap (Attempt $attempt)"
        rm -rf "$temp_dir"
        ((attempt++))
    fi
done

if [ $attempt -gt $MAX_RETRIES ]; then
    err "Exceeded maximum retries. Exiting..."
    exit 1
fi

# Setup snapd before proceeding
act "Enabling snap..."
if sudo systemctl enable --now snapd.socket; then
    ok "Snap setup completed successfully!"
else
    err "Failed to enable snapd"
    exit 1
fi

# Restart snapd
act "Restarting snapd..."
if sudo systemctl restart snapd; then
    ok "Snap restarted successfully!"
else
    err "Failed to restart snapd"
    exit 1
fi

# Install snap-store
act "Installing snap-store..."
if sudo snap install snap-store && sudo snap install snapd-desktop-integration; then
    ok "Snap Store installed successfully!"
else
    err "Failed to install Snap Store"
    exit 1
fi
