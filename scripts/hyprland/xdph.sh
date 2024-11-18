#!/bin/bash
# XDG-Desktop-Portals #

# source library
source <(curl -sSL https://is.gd/nhattruongNeoVim_lib)

# start script
xdg=(
	xdg-desktop-portal-hyprland
	xdg-desktop-portal-gtk
)

# XDG-DESKTOP-PORTAL-HYPRLAND
for xdgs in "${xdg[@]}"; do
	install_aur_pkg "$xdgs"
	if [ $? -ne 0 ]; then
		echo -e "\e[1A\e[K${ERROR} - $xdph install had failed"
	fi
done

printf "\n"

printf "${NOTE} Checking for other XDG-Desktop-Portal-Implementations....\n"
sleep 1
printf "\n"
printf "${NOTE} XDG-desktop-portal-KDE & GNOME (if installed) should be manually disabled or removed! I can't remove it... sorry...\n"
if gum confirm "${CAT} Would you like to try to remove other XDG-Desktop-Portal-Implementations?"; then
	sleep 1
	# Clean out other portals
	printf "${NOTE} Clearing any other xdg-desktop-portal implementations...\n"
	# Check if packages are installed and uninstall if present
	if pacman -Qs xdg-desktop-portal-wlr >/dev/null; then
		echo "Removing xdg-desktop-portal-wlr..."
		sudo pacman -R --noconfirm xdg-desktop-portal-wlr
	fi
	if pacman -Qs xdg-desktop-portal-lxqt >/dev/null; then
		echo "Removing xdg-desktop-portal-lxqt..."
		sudo pacman -R --noconfirm xdg-desktop-portal-lxqt
	fi
else
	echo "No other XDG-implementations will be removed."
fi
