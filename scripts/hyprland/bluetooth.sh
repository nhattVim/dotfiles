#!/bin/bash
# bluetooth Stuff

# source library
. <(curl -sSL https://is.gd/nhattVim_lib)

HYPR_FOLDER="$HOME/.config/hypr/configs"
STARTUP_FILE="$HYPR_FOLDER/execs.conf"

# start script
bluetooth=(
    bluez
    bluez-utils
    blueman
)

# install bluetooth
note "Installing bluetooth Packages..."
for BLUE in "${bluetooth[@]}"; do
    iAur "$BLUE"
    if [ $? -ne 0 ]; then
        err "$BLUE install had failed"
    fi
done

note "Activating bluetooth Services..."
sudo systemctl enable --now bluetooth.service
