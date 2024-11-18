#!/bin/bash
# Main Hyprland Package

# source library
source <(curl -sSL https://is.gd/nhattruongNeoVim_lib)

# start script
hypr=(
	hyprland
)

# Removing other Hyprland to avoid conflict
printf "${YELLOW} Checking for other hyprland packages and remove if any..${RESET}\n"
if pacman -Qs hyprland >/dev/null; then
	printf "${YELLOW} Hyprland detected. uninstalling to install Hyprland-git...${RESET}\n"
	for hyprnvi in hyprland-git hyprland-nvidia hyprland-nvidia-git hyprland-nvidia-hidpi-git; do
		sudo pacman -R --noconfirm "$hyprnvi" 2>/dev/null || true
	done
fi

# Hyprland
printf "${NOTE} Installing Hyprland .......\n"
for HYPR in "${hypr[@]}"; do
	install_aur_pkg "$HYPR" 2>&1
	[ $? -ne 0 ] && {
		echo -e "\e[1A\e[K${ERROR} - $HYPR install had failed"
	}
done
