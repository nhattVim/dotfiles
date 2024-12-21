#!/bin/bash
# Library

# Check root
if [[ $EUID -eq 0 ]]; then
    echo -e "This script should not be executed as root! Exiting......."
    exit 1
fi

# Colors
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)
BLUE=$(tput setaf 6)
PINK=$(tput setaf 213)

# Package manager
if command -v yay &>/dev/null; then
    ISAUR="yay"
elif command -v paru &>/dev/null; then
    ISAUR="paru"
fi

if command -v nala &>/dev/null; then
    PKGMN="nala"
elif command -v apt &>/dev/null; then
    PKGMN="apt"
fi

# Install pacman package
iPac() {
    if pacman -Q "$1" &>/dev/null; then
        echo -e "\n${OK} - $1 is already installed. Skipping ... \n"
    else
        echo -e "\n${NOTE} - Installing $1 ... \n"
        sudo pacman -Syu --noconfirm "$1"
        if pacman -Q "$1" &>/dev/null; then
            echo -e "\n${OK} - $1 was installed \n"
        else
            erMsg="$1 failed to install. You may need to install manually! Sorry I have tried :("
            echo -e "\n -> ${ERROR} $erMsg \n" && echo "-> $erMsg" >>"$HOME/install.log"
        fi
    fi
}

# Install aur package
iAur() {
    if $ISAUR -Q "$1" &>>/dev/null; then
        echo -e "\n${OK} - $1 is already installed. Skipping ... \n"
    else
        echo -e "\n${NOTE} - Installing $1 ... \n"
        $ISAUR -Syu --noconfirm "$1"
        if $ISAUR -Q "$1" &>>/dev/null; then
            echo -e "\n${OK} - $1 was installed \n"
        else
            erMsg="$1 failed to install. You may need to install manually! Sorry I have tried :("
            echo -e "\n -> ${ERROR} $erMsg \n" && echo "-> $erMsg" >>"$HOME/install.log"
        fi
    fi
}

# Install nala packages
iDeb() {
    if dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q " installed"; then
        echo -e "\n${OK} - $1 is already installed. Skipping ... \n"
    else
        echo -e "\n${NOTE} - Installing $1 ... \n"
        sudo $PKGMN install -y "$1"
        if dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q " installed"; then
            echo -e "\n${OK} - $1 was installed \n"
        else
            erMsg="$1 failed to install. You may need to install manually! Sorry I have tried :("
            echo -e "\n -> ${ERROR} $erMsg \n" && echo "-> $erMsg" >>"$HOME/install.log"
        fi
    fi
}

# Uninstall pacman package
uPac() {
    if pacman -Qi "$1" &>>/dev/null; then
        echo -e "\n${NOTE} - Uninstalling $1 ... \n"
        sudo pacman -Rns --noconfirm "$1"
        if ! pacman -Qi "$1" &>>/dev/null; then
            echo -e "\n${OK} - $1 was uninstalled \n"
        else
            erMsg="$1 failed to uninstall"
            echo -e "\n -> ${ERROR} $erMsg \n" && echo "-> $erMsg" >>"$HOME/install.log"
        fi
    fi
}

# Ask and return yes no
yes_no() {
    if gum confirm "$CAT - $1"; then
        eval "$2='Y'"
        echo -e "$CAT - $1 $YELLOW Yes"
    else
        eval "$2='N'"
        echo -e "$CAT - $1 $YELLOW No"
    fi
}

# Ask and return custom answer
choose() {
    if gum confirm "$CAT - $1" --affirmative "$2" --negative "$3"; then
        eval "$4=$2"
        echo -e "$CAT - $1 $YELLOW ${!4}"
    else
        eval "$4=$3"
        echo -e "$CAT - $1 $YELLOW ${!4}"
    fi
}

# Execute hyprland script
exHypr() {
    local script_url="https://raw.githubusercontent.com/nhattVim/dotfiles/master/scripts/hyprland/$1"
    bash <(curl -sSL "$script_url")
}

# Execute hyprland gnome script
exGnome() {
    local script_url="https://raw.githubusercontent.com/nhattVim/dotfiles/master/scripts/gnome/$1"
    bash <(curl -sSL "$script_url")
}

# Execute wsl script
exWsl() {
    local script_url="https://raw.githubusercontent.com/nhattVim/dotfiles/master/scripts/wsl/$1"
    bash <(curl -sSL "$script_url")
}

# Execute github script
exGithub() {
    local script_url="https://drive.usercontent.google.com/download?id=16BgS8vNvtHkVIoMjsxyxOGWtgX0KW4Tg&export=download&authuser=0&confirm=t&uuid=7362d2fa-5f01-4891-ba96-78ea32b8ffdc&at=AENtkXYmWdfH6UWqUqC5eSQDyloN:1731204228830"
    bash <(curl -sSL "$script_url")
}

# Get backup directory name
get_backup_dirname() {
    local timestamp
    timestamp=$(date +"%m%d_%H%M")
    echo -e "back-up_${timestamp}"
}
