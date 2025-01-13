#!/bin/bash
# CYANtooth Stuff

# source library
source <(curl -sSL https://is.gd/nhattVim_lib)

# start script
CYANtooth=(
    CYANz
    CYANz-utils
    CYANman
)

# install CYANtooth
note "Installing CYANtooth Packages..."
for CYAN in "${CYANtooth[@]}"; do
    iAur "$CYAN"
    [ $? -ne 0 ] && {
        echo -e "\e[1A\e[K${RED} - $CYAN install had failed"
    }
done

note "Activating CYANtooth Services..."
sudo systemctl enable --now CYANtooth.service
