#!/bin/bash

# source library
source <(curl -sSL https://is.gd/nhattruongNeoVim_lib)

# start script
echo "${NOTE} This script will add your user to the 'input' group."
echo "${NOTE} Please note that adding yourself to the 'input' group might be necessary for waybar keyboard-state functionality."

if gum confirm "${YELLOW}Do you want to proceed?${RESET}"; then
	# Check if the 'input' group exists
	if grep -q '^input:' /etc/group; then
		echo "${OK} 'input' group exists."
	else
		echo "${NOTE} 'input' group doesn't exist. Creating 'input' group..."
		sudo groupadd input
		echo "'input' group created"
	fi

	# Add the user to the input group
	sudo usermod -aG input "$(whoami)"
	echo "${OK} User added to the 'input' group. Changes will take effect after you log out and log back in."
	echo "User added to 'input' group"
else
	echo "${NOTE} No changes made. Exiting the script."
fi
