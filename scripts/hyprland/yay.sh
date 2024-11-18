#!/bin/bash
# Yay AUR Helper
# NOTE: If paru is already installed, yay will not be installed

# source library
source <(curl -sSL https://is.gd/nhattruongNeoVim_lib)

# Check Existing yay-bin
cd $HOME
if [ -d yay-bin ]; then
	rm -rf yay-bin
fi

if [ -n "$ISAUR" ]; then
	printf "\n%s - AUR helper already installed, moving on.\n" "${OK}"
else
	printf "\n%s - AUR helper was NOT located\n" "${NOTE}"
	printf "\n%s - Installing yay from AUR\n" "${NOTE}"
	git clone https://aur.archlinux.org/yay-bin.git || {
		printf "%s - Failed to clone yay from AUR\n" "${ERROR}"
		exit 1
	}
	cd yay-bin || {
		printf "%s - Failed to enter yay-bin directory\n" "${ERROR}"
		exit 1
	}
	makepkg -si --noconfirm || {
		printf "%s - Failed to install yay from AUR\n" "${ERROR}"
		exit 1
	}
    cd ~ && rm -rf yay-bin || {
		printf "%s - Failed to remove yay-bin directory\n" "${ERROR}"
		exit 1
    }
fi

# Update system before proceeding
printf "\n%s - Performing a full system update to avoid issues.... \n" "${NOTE}"
ISAUR=$(command -v yay || command -v paru)

$ISAUR -Syu --noconfirm || {
	printf "%s - Failed to update system\n" "${ERROR}"
	exit 1
}
