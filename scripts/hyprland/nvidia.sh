#!/bin/bash

# source library
source <(curl -sSL https://is.gd/nhattruongNeoVim_lib)

# start
nvidia_pkg=(
	nvidia-dkms
	nvidia-settings
	nvidia-utils
	libva
	libva-nvidia-driver-git
)

hypr=(
	hyprland
)

# nvidia stuff
printf "${YELLOW} Checking for other hyprland packages and remove if any..${RESET}\n"
if pacman -Qs hyprland >/dev/null; then
	printf "${YELLOW} Hyprland detected. uninstalling to install Hyprland-git...${RESET}\n"
	for hyprnvi in hyprland-git hyprland-nvidia hyprland-nvidia-git hyprland-nvidia-hidpi-git; do
		sudo pacman -R --noconfirm "$hyprnvi" 2>/dev/null || true
	done
fi

# Hyprland
printf "${NOTE} Installing Hyprland......\n"
for HYPR in "${hypr[@]}"; do
	install_aur_pkg "$HYPR"
	[ $? -ne 0 ] && {
		echo -e "\e[1A\e[K${ERROR} - $HYPR install had failed"
	}
done

# Install additional Nvidia packages
printf "${YELLOW} Installing addition Nvidia packages...\n"
for krnl in $(cat /usr/lib/modules/*/pkgbase); do
	for NVIDIA in "${krnl}-headers" "${nvidia_pkg[@]}"; do
		install_aur_pkg "$NVIDIA"
	done
done

# Check if the Nvidia modules are already added in mkinitcpio.conf and add if not
if grep -qE '^MODULES=.*nvidia. *nvidia_modeset.*nvidia_uvm.*nvidia_drm' /etc/mkinitcpio.conf; then
	echo "Nvidia modules already included in /etc/mkinitcpio.conf"
else
	sudo sed -Ei 's/^(MODULES=\([^\)]*)\)/\1 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
	echo "Nvidia modules added in /etc/mkinitcpio.conf"
fi

sudo mkinitcpio -P
printf "\n\n\n"

# Additional Nvidia steps
NVEA="/etc/modprobe.d/nvidia.conf"
if [ -f "$NVEA" ]; then
	printf "${OK} Seems like nvidia-drm modeset=1 is already added in your system..moving on.\n"
	printf "\n"
else
	printf "\n"
	printf "${YELLOW} Adding options to $NVEA..."
	sudo echo -e "options nvidia-drm modeset=1 fbdev=1" | sudo tee -a /etc/modprobe.d/nvidia.conf
	printf "\n"
fi

# additional for GRUB users
# Check if /etc/default/grub exists
if [ -f /etc/default/grub ]; then
	# Check if nvidia_drm.modeset=1 is already present
	if ! sudo grep -q "nvidia-drm.modeset=1" /etc/default/grub; then
		# Add nvidia_drm.modeset=1 to GRUB_CMDLINE_LINUX_DEFAULT
		sudo sed -i 's/\(GRUB_CMDLINE_LINUX_DEFAULT=".*\)"/\1 nvidia-drm.modeset=1"/' /etc/default/grub
		# Regenerate GRUB configuration
		sudo grub-mkconfig -o /boot/grub/grub.cfg
		echo "nvidia-drm.modeset=1 added to /etc/default/grub"
	else
		echo "nvidia-drm.modeset=1 is already present in /etc/default/grub"
	fi
else
	echo "/etc/default/grub does not exist"
fi

# Blacklist nouveau
if [[ -z $blacklist_nouveau ]]; then
	if gum confirm "${CAT} Would you like to blacklist nouveau?"; then
		NOUVEAU="/etc/modprobe.d/nouveau.conf"
		if [ -f "$NOUVEAU" ]; then
			printf "${OK} Seems like nouveau is already blacklisted..moving on.\n"
		else
			printf "\n"
			echo "blacklist nouveau" | sudo tee -a "$NOUVEAU"
			printf "${NOTE} has been added to $NOUVEAU.\n"
			printf "\n"

			# To completely blacklist nouveau (See wiki.archlinux.org/title/Kernel_module#Blacklisting 6.1)
			if [ -f "/etc/modprobe.d/blacklist.conf" ]; then
				echo "install nouveau /bin/true" | sudo tee -a "/etc/modprobe.d/blacklist.conf"
			else
				echo "install nouveau /bin/true" | sudo tee "/etc/modprobe.d/blacklist.conf"
			fi
		fi
	else
		printf "${NOTE} Skipping nouveau blacklisting.\n"
	fi
fi
