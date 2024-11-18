#!/bin/bash
# Hyprland Packages

# source library
source <(curl -sSL https://is.gd/nhattruongNeoVim_lib)

# start script
aur_pkgs=(
	microsoft-edge-stable
	arttime-git
	pipes.sh
	tgpt-bin
	# vmware-workstation
	# xampp
)

hypr_pkgs=(
	gvfs
	gvfs-mtp
	imagemagick
	kitty
	kvantum
	python-requests
	qt6-svg
	rofi-lbonn-wayland-git
	swaylock-effects-git
	swaync
	swww
	wlogout
	cava
	eog
	mousepad
	nwg-look-bin
	pacman-contrib
)

fonts=(
	adobe-source-code-pro-fonts
	noto-fonts-emoji
	otf-font-awesome
	ttf-droid
	ttf-fira-code
	ttf-jetbrains-mono
	ttf-jetbrains-mono-nerd
)

# List of packages to uninstall as it conflicts with swaync or causing swaync to not function properly
uninstall=(
	dunst
	mako
)

# Checking if mako or dunst is installed
printf "\n%s - Checking if mako or dunst are installed and removing for swaync to work properly \n" "${NOTE}"
for PKG in "${uninstall[@]}"; do
	uninstall_pacman_pkg "$PKG"
	if [ $? -ne 0 ]; then
		echo -e "${ERROR} - $PKG uninstallation had failed"
	fi
done

# Installation of main components
printf "\n%s - Installing hyprland packages.... \n" "${NOTE}"
for PKG1 in "${hypr_pkgs[@]}" "${fonts[@]}" "${aur_pkgs[@]}"; do
	install_aur_pkg "$PKG1"
	if [ $? -ne 0 ]; then
		echo -e "${ERROR} - $PKG1 install had failed"
	fi
done
