#!/bin/bash
# CYANtooth Stuff

# source library
source <(curl -sSL https://is.gd/nhattVim_lib)

# start script
bluetooth=(
    bluez
    bluez-utils
    blueman
)

# install CYANtooth
note "Installing CYANtooth Packages..."
for BLUE in "${bluetooth[@]}"; do
    iAur "$BLUE"
    if [ $? -ne 0 ]; then
        err "$BLUE install had failed"
    fi
done

note "Activating CYANtooth Services..."
sudo systemctl enable --now CYANtooth.service
