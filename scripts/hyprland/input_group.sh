#!/bin/bash

# source library
. <(curl -sSL https://raw.githubusercontent.com/nhattVim/dotfiles/refs/heads/master/scripts/lib.sh)

# start script
note "This script will add your user to the 'input' group."
note "Please note that adding yourself to the 'input' group might be necessary for waybar keyboard-state functionality."

if gum confirm "${YELLOW}Do you want to proceed?${RESET}"; then
    # Check if the 'input' group exists
    if grep -q '^input:' /etc/group; then
        ok "'input' group exists"
    else
        note "'input' group doesn't exist. Creating 'input' group..."
        sudo groupadd input
        note "'input' group created"
    fi

    # Add the user to the input group
    sudo usermod -aG input "$(whoami)"
    ok "User added to the 'input' group. Changes will take effect after you log out and log back in."
    ok "User added to 'input' group"
else
    note "No changes made."
fi
