#!/bin/bash
# required

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

GUM_VERSION="0.14.3"
GUM_LINKDOWNLOADS="https://github.com/charmbracelet/gum/releases/download/v${GUM_VERSION}/gum_${GUM_VERSION}_amd64.deb"

# update system
printf "\n%s - Update system .... \n" "${NOTE}"
if sudo apt update && sudo apt upgrade -y; then
    printf "\n%s - Update system successfully \n" "${OK}"
else
    printf "\n%s - Failed to update your system \n" "${ERROR}"
fi

# install nala
printf "\n%s - Check nala ... \n" "${NOTE}"
if ! command -v nala &>/dev/null; then
    printf "\n%s - Installing and initializing nala... \n" "${CAT}"
    if sudo apt install nala -y && sudo nala update && sudo nala upgrade -y; then
        printf "\n%s - Press 1 2 3 and press Enter \n" "${NOTE}"
        sudo nala fetch
    else
        printf "\n%s - Failed to install nala \n" "${ERROR}"
    fi
else
    printf "\n%s - Nala is already installed. Skipping... \n" "${OK}"
fi

# reload package manager
PKGMN=$(command -v nala || command -v apt)

# package
pkgs=(
    curl
    wget
    git
    unzip
)

# install some required packages
printf "\n%s - Installing required packages ... \n" "${NOTE}"
for PKG in "${pkgs[@]}"; do
    sudo $PKGMN install -y "$PKG"
    if [ $? -ne 0 ]; then
        printf "\n%s - $PKG install had failed, please check the script. \n" "${ERROR}"
    fi
done

# install gum (requirement)
printf "\n%s - Download gum.deb ... \n" "${NOTE}"
if wget -O /tmp/gum.deb "$GUM_LINKDOWNLOADS"; then
    printf "\n%s - Download gum.deb successfully \n" "${OK}"
    printf "\n%s - Installing gum ... \n" "${NOTE}"
    if sudo $PKGMN install -y /tmp/gum.deb; then
        printf "\n%s - Install gum successfully \n" "${OK}"
    else
        printf "\n%s - Failed to install gum \n" "${ERROR}"
    fi
else
    printf "\n%s - Failed to download gum \n" "${ERROR}"
fi

clear
