#!/bin/bash
# pacman adding up extra-spices

# source library
source <(curl -sSL https://is.gd/nhattruongNeoVim_lib) && clear

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
echo -e "-------------------- Script developed by nhattruongNeoVim --------------------     "
echo -e " -------------- Github: https://github.com/nhattruongNeoVim -----------------      "

printf "\n%s - Adding Extra Spice in pacman.conf ... \n" "${NOTE}"

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
        printf "\n%s - Uncommented: $line \n" "${CAT}"
    else
        printf "\n%s - $line is already uncommented. \n" "${CAT}"
    fi
done

# add "ILoveCandy" below ParallelDownloads if it doesn't exist
if grep -q "^ParallelDownloads" "$pacman_conf" && ! grep -q "^ILoveCandy" "$pacman_conf"; then
    sudo sed -i "/^ParallelDownloads/a ILoveCandy" "$pacman_conf"
    printf "\n%s - Added ILoveCandy below ParallelDownloads. \n" "${CAT}"
else
    printf "\n%s - ILoveCandy already exists \n" "${CAT}"
fi

printf "\n%s - Pacman.conf spicing up completed \n" "${CAT}"

# Backup and update mirrorlist
# if sudo cp "$mirrorlist" "${mirrorlist}.bak"; then
# 	echo -e "$(tput setaf 6)[ACTION]$(tput sgr0) Backup mirrorlist to mirrorlist.bak. $(tput sgr0)"
#     if sudo reflector --verbose --latest 10 --protocol https --sort rate --save "$mirrorlist"; then
# 	    echo -e "$(tput setaf 6)[ACTION]$(tput sgr0) Updated mirrorlist. $(tput sgr0)"
#     else
#         echo -e "$(tput setaf 1)[ERROR]$(tput sgr0) Failed to update mirrorlist. $(tput sgr0)"
#     fi
# else
# 	echo -e "$(tput setaf 1)[ERROR]$(tput sgr0) Failed to backup mirrorlist. $(tput sgr0)"
# fi

# updating pacman.conf
sudo pacman -Syyuu --noconfirm
if [ $? -ne 0 ]; then
    printf "\n%s - Failed to update the package database. \n" "${ERROR}"
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
printf "\n%s - Installing required packages ... \n" "${NOTE}"
for PKG1 in "${pkgs[@]}"; do
    sudo pacman -S --noconfirm "$PKG1"
    if [ $? -ne 0 ]; then
        printf "\n%s - $PKG install had failed, please check the script. \n" "${ERROR}"
    fi
done
