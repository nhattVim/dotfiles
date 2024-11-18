#!/bin/bash
# SDDM

# source library
source <(curl -sSL https://is.gd/nhattruongNeoVim_lib)

# start
sddm=(
	sddm
	qt5-graphicaleffects
	qt5-quickcontrols2
	qt5-svg
)

# Install SDDM and SDDM theme
printf "${NOTE} Installing SDDM and dependencies........\n"
for package in "${sddm[@]}"; do
	install_aur_pkg "$package"
	[ $? -ne 0 ] && {
		echo -e "\e[1A\e[K${ERROR} - $package install has failed"
	}
done

# Check if other login managers installed and disabling its service before enabling sddm
for login_manager in lightdm gdm lxdm lxdm-gtk3; do
	if pacman -Qs "$login_manager" >/dev/null; then
		echo "disabling $login_manager..."
		sudo systemctl disable "$login_manager.service"
	fi
done

printf " Activating sddm service........\n"
sudo systemctl enable sddm

# Check dotfiles
cd $HOME
if [ -d dotfiles ]; then
	cd dotfiles || {
		printf "%s - Failed to enter dotfiles config directory\n" "${ERROR}"
		exit 1
	}
else
	printf "\n${NOTE} Clone dotfiles. " && git clone -b hyprland https://github.com/nhattruongNeoVim/dotfiles.git ~/dotfiles --depth 1 || {
		printf "%s - Failed to clone dotfiles \n" "${ERROR}"
		exit 1
	}
	cd dotfiles || {
		printf "%s - Failed to enter dotfiles directory\n" "${ERROR}"
		exit 1
	}
fi

# Set up SDDM
echo -e "${NOTE} Setting up the login screen."
sddm_conf_dir=/etc/sddm.conf.d
[ ! -d "$sddm_conf_dir" ] && {
	printf "$CAT - $sddm_conf_dir not found, creating...\n"
	sudo mkdir "$sddm_conf_dir"
}

wayland_sessions_dir=/usr/share/wayland-sessions
[ ! -d "$wayland_sessions_dir" ] && {
	printf "$CAT - $wayland_sessions_dir not found, creating...\n"
	sudo mkdir "$wayland_sessions_dir"
}

sudo cp assets/hyprland.desktop "$wayland_sessions_dir/"

# SDDM-themes
cd $HOME
if gum confirm "${CAT} OPTIONAL - Would you like to install SDDM themes?"; then
	printf "\n%s - Installing Simple SDDM Theme\n" "${NOTE}"

	# Check if /usr/share/sddm/themes/simple-sddm exists and remove if it does
	if [ -d "/usr/share/sddm/themes/simple-sddm" ]; then
		sudo rm -rf "/usr/share/sddm/themes/simple-sddm"
		echo -e "\e[1A\e[K${OK} - Removed existing 'simple-sddm' directory."
	fi

	# Check if simple-sddm directory exists in the current directory and remove if it does
	if [ -d "simple-sddm" ]; then
		rm -rf "simple-sddm"
		echo -e "\e[1A\e[K${OK} - Removed existing 'simple-sddm' directory from the current location."
	fi

	if git clone https://github.com/JaKooLit/simple-sddm.git --depth 1; then
		while [ ! -d "simple-sddm" ]; do
			sleep 1
		done

		if [ ! -d "/usr/share/sddm/themes" ]; then
			sudo mkdir -p /usr/share/sddm/themes
			echo -e "\e[1A\e[K${OK} - Directory '/usr/share/sddm/themes' created."
		fi

		sudo mv simple-sddm /usr/share/sddm/themes/
		echo -e "[Theme]\nCurrent=simple-sddm" | sudo tee "$sddm_conf_dir/theme.conf.user"
	else
		echo -e "\e[1A\e[K${ERROR} - Failed to clone the theme repository. Please check your internet connection"
	fi
else
	printf "\n%s - No SDDM themes will be installed.\n" "${NOTE}"
fi
