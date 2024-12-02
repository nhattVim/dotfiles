#!/bin/bash
# required

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

GUM_VERSION="0.14.5"
GUM_LINKDOWNLOADS="https://github.com/charmbracelet/gum/releases/download/v${GUM_VERSION}/gum_${GUM_VERSION}_amd64.deb"

# update system
echo -e "\n${NOTE} - Updating system..."
if sudo apt update && sudo apt upgrade -y; then
    echo -e "\n${OK} - System updated successfully."
else
    echo -e "\n${ERROR} - Failed to update the system."
fi

# install nala
echo -e "\n${NOTE} - Checking nala..."
if ! command -v nala &>/dev/null; then
    echo -e "\n${NOTE} - Installing and initializing nala..."
    if sudo apt install nala -y && sudo nala update && sudo nala upgrade -y; then
        echo -e "\n${OK} - Nala installed successfully."
        echo -e "\n${NOTE} - Fetching package lists..."
        sudo nala fetch
    else
        echo -e "\n${ERROR} - Failed to install nala."
    fi
else
    echo -e "\n${OK} - Nala is already installed. Skipping..."
fi

# reload package manager
PKGMN=$(command -v nala || command -v apt)

# package list
pkgs=(
    curl
    wget
    git
    unzip
)

# install some required packages
echo -e "\n${NOTE} - Installing required packages..."
for PKG in "${pkgs[@]}"; do
    sudo $PKGMN install -y "$PKG"
    if [ $? -ne 0 ]; then
        echo -e "\n${ERROR} - Failed to install $PKG, please check the script."
    else
        echo -e "\n${OK} - $PKG installed successfully."
    fi
done

# install gum (requirement)
echo -e "\n${NOTE} - Downloading gum.deb..."
if wget -O /tmp/gum.deb "$GUM_LINKDOWNLOADS"; then
    echo -e "\n${OK} - gum.deb downloaded successfully."
    echo -e "\n${NOTE} - Installing gum..."
    if sudo $PKGMN install -y /tmp/gum.deb; then
        echo -e "\n${OK} - Gum installed successfully."
    else
        echo -e "\n${ERROR} - Failed to install gum."
    fi
else
    echo -e "\n${ERROR} - Failed to download gum."
fi

clear
