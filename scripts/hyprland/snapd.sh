#!/bin/bash
# Snapd

# source library
source <(curl -sSL https://is.gd/nhattruongNeoVim_lib)

# start script
cd $HOME
if [ -d snapd ]; then
	rm -rf snapd
fi

# if command -v snap &>/dev/null; then
# 	printf "\n%s - Snap already installed, moving on.\n" "${OK}"
# else
# 	printf "\n%s - Snap was NOT located\n" "${NOTE}"
# 	printf "\n%s - Installing snap\n" "${NOTE}"
# 	git clone https://aur.archlinux.org/snapd.git || {
# 		printf "%s - Failed to clone snap from\n" "${ERROR}"
# 		exit 1
# 	}
# 	cd snapd || {
# 		printf "%s - Failed to enter snapd directory\n" "${ERROR}"
# 		exit 1
# 	}
# 	makepkg -si --noconfirm || {
# 		printf "%s - Failed to install snap\n" "${ERROR}"
# 		exit 1
# 	}
# 	cd ~ && rm -rf snapd || {
# 		printf "%s - Failed to remove snapd directory\n" "${ERROR}"
# 		exit 1
# 	}
# fi

# install snapd
printf "\n%s - Installing snapd\n" "${NOTE}"
install_aur_pkg snapd

# setup snapd before proceeding
printf "\n%s - Set up snap.... \n" "${NOTE}"
sudo systemctl enable --now snapd.socket && sudo ln -s /var/lib/snapd/snap /snap && systemctl enable --now snapd.apparmor || {
	printf "%s - Failed to setup snap\n" "${ERROR}"
	exit 1
}
