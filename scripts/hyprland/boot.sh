#!/bin/bash
# pacman adding up extra-spices

# source library
source <(curl -sSL https://is.gd/nhattVim_lib) && clear

# start script
echo -e "\e[34m   ____   __ __   ____  ______      ______  ____   __ __   ___   ____    ____"
echo -e " |    \ |  |  | /    ||      |    |      ||    \ |  |  | /   \ |    \  /    |      "
echo -e " |  _  ||  |  ||  o  ||      |    |      ||  D  )|  |  ||     ||  _  ||   __|      "
echo -e " |  |  ||  _  ||     ||_|  |_|    |_|  |_||    / |  |  ||  O  ||  |  ||  |  |      "
echo -e " |  |  ||  |  ||  _  |  |  |        |  |  |    \ |  :  ||     ||  |  ||  |_ |      "
echo -e " |  |  ||  |  ||  |  |  |  |        |  |  |  .  \|     ||     ||  |  ||     |      "
echo -e " |__|__||__|__||__|__|  |__|        |__|  |__|\_| \__,_| \___/ |__|__||___,_|      "
echo -e "                                                                                   "
echo -e "                                                                                   "
echo -e " ---------------------- Script developed by nhattVim -----------------------       "
echo -e "  ----------------- Github: https://github.com/nhattVim ------------------         "

note "Adding Extra Spice in pacman.conf..."

# variable
pacman_conf="/etc/pacman.conf"
mirrorlist="/etc/pacman.d/mirrorlist"

# remove comments '#' from specific lines
lines_to_edit=(
    "Color"
    "CheckSpace"
    "VerbosePkgLists"
    "ParallelDownloads"
)

# uncomment specified lines if they are commented out
for line in "${lines_to_edit[@]}"; do
    if grep -q "^#$line" "$pacman_conf"; then
        sudo sed -i "s/^#$line/$line/" "$pacman_conf"
        act "Uncommented: $line"
    else
        act "$line is already uncommented."
    fi
done

# add "ILoveCandy" below ParallelDownloads if it doesn't exist
if grep -q "^ParallelDownloads" "$pacman_conf" && ! grep -q "^ILoveCandy" "$pacman_conf"; then
    sudo sed -i "/^ParallelDownloads/a ILoveCandy" "$pacman_conf"
    act "Added ILoveCandy below ParallelDownloads."
else
    act "ILoveCandy already exists."
fi

act "Pacman.conf spicing up completed"

# Backup and update mirrorlist
# if sudo cp "$mirrorlist" "${mirrorlist}.bak"; then
# 	echo -e "$(tput setaf 6)[CYAN]$(tput sgr0) Backup mirrorlist to mirrorlist.bak. $(tput sgr0)"
#     if sudo reflector --verbose --latest 10 --protocol https --sort rate --save "$mirrorlist"; then
# 	    echo -e "$(tput setaf 6)[CYAN]$(tput sgr0) Updated mirrorlist. $(tput sgr0)"
#     else
#         echo -e "$(tput setaf 1)[RED]$(tput sgr0) Failed to update mirrorlist. $(tput sgr0)"
#     fi
# else
# 	echo -e "$(tput setaf 1)[RED]$(tput sgr0) Failed to backup mirrorlist. $(tput sgr0)"
# fi

# updating pacman.conf
sudo pacman -Syyuu --noconfirm
if [ $? -ne 0 ]; then
    err "Failed to update the package database"
fi

# Package
pkgs=(
    gum
    reflector
    curl
    git
    unzip
)

# install requirement
note "Installing required packages..."
for PKG1 in "${pkgs[@]}"; do
    sudo pacman -S --noconfirm "$PKG1"
    if [ $? -ne 0 ]; then
        err "$PKG install had failed, please check the script."
    fi
done

clear
