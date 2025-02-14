#!/bin/bash
# bluetooth Stuff

# source library
. <(curl -sSL https://is.gd/nhattVim_lib)

# start script
bluetooth=(
    bluez
    bluez-utils
    blueman
)

# install bluetooth
note "Installing bluetooth Packages..."
for BLUE in "${bluetooth[@]}"; do
    iPac "$BLUE"
    if [ $? -ne 0 ]; then
        exit 1
    fi
done

note "Activating bluetooth Services..."
sudo systemctl enable --now bluetooth.service
