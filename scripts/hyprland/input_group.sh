#!/bin/bash

# source library
. <(curl -sSL https://raw.githubusercontent.com/nhattVim/dotfiles/refs/heads/master/scripts/lib.sh)

note "This script will add your user to the 'input' group."
note "This is often required for Waybar keyboard-state functionality."

if gum confirm "${YELLOW}Do you want to proceed?${RESET}"; then
    # Ensure 'input' group exists
    if getent group input >/dev/null; then
        ok "'input' group exists"
    else
        note "'input' group not found. Creating..."
        sudo groupadd input
        ok "'input' group created"
    fi

    # Add current user to group
    sudo usermod -aG input "$(whoami)"
    ok "User added to 'input' group (log out & log back in to apply)"
else
    note "No changes made."
fi
