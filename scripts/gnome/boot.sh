#!/bin/bash
# required

. <(curl -sSL https://is.gd/nhattVim_lib) && clear

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
note "Updating system..."
if sudo apt update && sudo apt upgrade -y; then
    ok "System updated successfully."
else
    err "Failed to update the system."
fi

# install nala
note "Checking nala..."
if ! command -v nala &>/dev/null; then
    note "Installing nala..."
    if sudo apt install nala -y && sudo nala update && sudo nala upgrade -y; then
        ok "Nala installed successfully."
        note "Fetching package lists..."
        sudo nala fetch
    else
        err "Failed to install nala."
    fi
else
    ok "Nala is already installed."
fi

# reload package manager
PKGMN=$(command -v nala || command -v apt)

# package list
pkgs=(
    curl
    wget
    git
    unzip
    zip
)

# install some required packages
note "Installing required packages..."
for PKG in "${pkgs[@]}"; do
    sudo $PKGMN install -y "$PKG"
    if [ $? -ne 0 ]; then
        err "Failed to install $PKG, please check the script."
    else
        ok "$PKG installed successfully."
    fi
done

# install gum (requirement)
note "Download gum"
if dpkg-query -W -f='${Status}' "gum" 2>/dev/null | grep -q " installed"; then
    ok "gum is already installed. Skipping ..."
else
    if wget -O /tmp/gum.deb "$GUM_LINKDOWNLOADS"; then
        ok "gum.deb downloaded successfully."
        note "Installing gum..."
        if sudo $PKGMN install -y /tmp/gum.deb; then
            ok "Installing gum successfully."
        else
            err "Failed to install gum."
        fi
    else
        err "Failed to download gum."
    fi
fi

clear
