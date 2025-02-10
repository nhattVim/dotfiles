#!/bin/bash
# bluetooth Stuff

# source library
# . <(curl -sSL https://is.gd/nhattVim_lib)
. <(curl -sSL https://raw.githubusercontent.com/nhattVim/dotfiles/master/scripts/lib.sh)

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
