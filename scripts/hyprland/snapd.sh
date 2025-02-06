#!/bin/bash
# Snapd Installer with Retry Mechanism

# Source library
. <(curl -sSL https://is.gd/nhattVim_lib)

if command -v snap &>/dev/null; then
    ok "Snap already installed, moving on."
    exit 1
else
    note "Snap was NOT located. Installing snap ..."

    MAX_RETRIES=3
    attempt=1

    while [ $attempt -le $MAX_RETRIES ]; do
        note "Installing snap from AUR (Attempt $attempt)..."

        temp_dir=$(mktemp -d)

        git clone https://aur.archlinux.org/snapd.git "$temp_dir/snapd" && cd "$temp_dir/snapd" || {
            err "Failed to clone snap from AUR (Attempt $attempt)"
            ((attempt++))
            continue
        }

        if makepkg -si --noconfirm; then
            ok "Successfully installed Snap!"
            rm -rf "$temp_dir"
            break
        else
            err "Failed to install Snap (Attempt $attempt)"
            rm -rf "$temp_dir"
            ((attempt++))
        fi

        rm -rf "$temp_dir"
        ok "Successfully installed snap!"
        break
    done

    if [ $attempt -gt $MAX_RETRIES ]; then
        err "Exceeded maximum retries. Exiting..."
        exit 1
    fi
fi

# Installing snapd
iAur snapd

# Setup snapd before proceeding
note "Set up snap ..."
sudo systemctl enable --now snapd.socket && sudo ln -s /var/lib/snapd/snap /snap && systemctl enable --now snapd.apparmor || {
    err "Failed to setup snap"
    exit 1
}
