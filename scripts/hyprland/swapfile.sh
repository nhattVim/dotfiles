#!/bin/bash
# set swapfile

# source library
source <(curl -sSL https://is.gd/nhattruongNeoVim_lib)

# start script
printf "\n%.0s" {1..2}
if ! gum confirm "${NOTE} Do you want to set up swapfile?"; then
	exit 1
fi

printf "\n%.0s" {1..2}
echo -e "${NOTE} Setting up swapfile."

total_ram=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
recommended_size=$((((total_ram / 1024 / 1024) + 1) / 2))

if [[ -f "/swapfile" ]]; then
	if gum confirm "${NOTE} Swap file already exists. Do you want to delete old swapfile?"; then
		sudo swapoff /swapfile
		sudo rm -f /swapfile
		printf "\n%.0s" {1..2}
		echo "${OK} Old swapfile deleted."

		if grep -q "/swapfile" /etc/fstab; then
			sudo sed -i '/swapfile/d' /etc/fstab
			echo "${OK} Old swapfile deleted and removed from /etc/fstab."
		fi
	else
		exit 1
	fi
fi

while true; do
	printf "\n%.0s" {1..2}
	read -rep "${NOTE} Enter the size of swapfile(GB), recommend ${recommended_size}(GB): " number
	if [[ "$number" =~ ^[1-9][0-9]*$ && "$number" -le 100 ]]; then
        printf "\n%.0s" {1..2}
		echo -e "${CAT} Creating swapfile..."
		if sudo dd if=/dev/zero of=/swapfile bs=1G count="$number" status=progress >/dev/null && sudo chmod 600 /swapfile >/dev/null; then
			echo -e "${OK} Created and permissioned swapfile successfully."
		else
			echo "${ERROR} Failed to create swapfile or set permissions."
			exit 1
		fi

		echo -e "${CAT} Formatting and activating swapfile..."
		if sudo mkswap -U clear /swapfile >/dev/null && sudo swapon /swapfile >/dev/null; then
			echo -e "${OK} Formatted and activated swapfile successfully."
		else
			echo "${ERROR} Failed to format and activate swapfile."
			exit 1
		fi

		if [[ ! -f "/etc/fstab" ]]; then
			printf "\n%.0s" {1..2}
			echo "${ERROR} /etc/fstab not found."
			exit 1
		fi

		echo -e "${CAT} Configuring /etc/fstab..."
		if echo "/swapfile none swap defaults 0 0" | sudo tee -a /etc/fstab >/dev/null; then
			echo -e "${OK} Done"
		else
			echo "${ERROR} Failed to configure /etc/fstab."
			exit 1
		fi

		break
	else
		echo "${ERROR} Invalid input. Please enter a valid number between 0 and 100."
	fi
done
