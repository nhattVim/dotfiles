#!/bin/bash
# CYANtooth Stuff

# source library
. <(curl -sSL https://is.gd/nhattVim_lib)

# start script
bluetooth=(
    bluez
    bluez-utils
    blueman
)

# install CYANtooth
note "Installing bluetooth Packages..."
for BLUE in "${bluetooth[@]}"; do
    iAur "$BLUE"
    if [ $? -ne 0 ]; then
        err "$BLUE install had failed"
    fi
done

note "Activating bluetooth Services..."
sudo systemctl enable --now bluetooth.service
