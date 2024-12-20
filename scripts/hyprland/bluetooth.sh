#!/bin/bash
# Bluetooth Stuff

# source library
source <(curl -sSL https://is.gd/nhattVim_lib)

# start script
bluetooth=(
	bluez
	bluez-utils
	blueman
)

# install bluetooth
printf "${NOTE} Installing Bluetooth Packages...\n"
for BLUE in "${bluetooth[@]}"; do
	iAur "$BLUE"
	[ $? -ne 0 ] && {
		echo -e "\e[1A\e[K${ERROR} - $BLUE install had failed"
	}
done

printf " Activating Bluetooth Services...\n"
sudo systemctl enable --now bluetooth.service
