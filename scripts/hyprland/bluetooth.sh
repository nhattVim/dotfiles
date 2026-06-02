#!/bin/bash
# bluetooth Stuff

# source library
. <(curl -sSL https://raw.githubusercontent.com/nhattVim/dotfiles/refs/heads/master/scripts/lib.sh)

# start script
bluetooth=(
    bluez
    bluez-utils
    blueman
)

# install bluetooth
note "Installing bluetooth packages..."
for BLUE in "${bluetooth[@]}"; do
    install_arch_pkg "$BLUE"
done

# enable service if needed
enable_service --now bluetooth.service
