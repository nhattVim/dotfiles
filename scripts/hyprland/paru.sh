#!/bin/bash
# Paru AUR Helper
# NOTE: If yay is already installed, paru will not be installed

# source library
source <(curl -sSL https://is.gd/nhattruongNeoVim_lib)

# start script
cd $HOME
if [ -d paru-bin ]; then
	rm -rf paru-bin
fi

if [ -n "$ISAUR" ]; then
	printf "\n%s - AUR helper already installed, moving on..\n" "${OK}"
else
	printf "\n%s - AUR helper was NOT located\n" "${NOTE}"
	printf "\n%s - Installing paru from AUR\n" "${NOTE}"
	git clone https://aur.archlinux.org/paru-bin.git || {
		printf "%s - Failed to clone paru from AUR\n" "${ERROR}"
		exit 1
	}
	cd paru-bin || {
		printf "%s - Failed to enter paru-bin directory\n" "${ERROR}"
		exit 1
	}
	makepkg -si --noconfirm || {
		printf "%s - Failed to install paru from AUR\n" "${ERROR}"
		exit 1
	}
    cd ~ && rm -rf paru-bin || {
		printf "%s - Failed to remove paru-bin directory\n" "${ERROR}"
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
