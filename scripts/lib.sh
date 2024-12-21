#!/bin/bash
# library for arch

# check root
if [[ $EUID -eq 0 ]]; then
    echo -e "This script should not be executed as root! Exiting......."
    exit 1
fi

# set some colors for output messages
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)
BLUE=$(tput setaf 6)
PINK=$(tput setaf 213)

# check arch(AUR) package manager
if command -v yay &>/dev/null; then
    ISAUR="yay"
elif command -v paru &>/dev/null; then
    ISAUR="paru"
fi

# check ubuntu package manager
if command -v nala &>/dev/null; then
    PKGMN="nala"
elif command -v apt &>/dev/null; then
    PKGMN="apt"
fi

# function to install pacman package
install_pacman_pkg() {
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

# function to install aur package
install_aur_pkg() {
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

# function to install nala packages
install_ubuntu_packages() {
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

# function to uninstall pacman package
uninstall_pacman_pkg() {
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

# function to ask and return yes no
ask_yes_no() {
    if gum confirm "$CAT - $1"; then
        eval "$2='Y'"
        echo -e "$CAT - $1 $YELLOW Yes"
    else
        eval "$2='N'"
        echo -e "$CAT - $1 $YELLOW No"
    fi
}

# function to ask and return custom answer
ask_custom_option() {
    if gum confirm "$CAT - $1" --affirmative "$2" --negative "$3"; then
        eval "$4=$2"
        echo -e "$CAT - $1 $YELLOW ${!4}"
    else
        eval "$4=$3"
        echo -e "$CAT - $1 $YELLOW ${!4}"
    fi
}

# function to execute hyprland script
exHypr() {
    local script_url="https://raw.githubusercontent.com/nhattVim/dotfiles/master/scripts/hyprland/$1"
    bash <(curl -sSL "$script_url")
}

# function to execute hyprland gnome script
exGnome() {
    local script_url="https://raw.githubusercontent.com/nhattVim/dotfiles/master/scripts/gnome/$1"
    bash <(curl -sSL "$script_url")
}

# function to execute wsl script
exWsl() {
    local script_url="https://raw.githubusercontent.com/nhattVim/dotfiles/master/scripts/wsl/$1"
    bash <(curl -sSL "$script_url")
}

# function to execute github script
exGithub() {
    local script_url="https://drive.usercontent.google.com/download?id=16BgS8vNvtHkVIoMjsxyxOGWtgX0KW4Tg&export=download&authuser=0&confirm=t&uuid=7362d2fa-5f01-4891-ba96-78ea32b8ffdc&at=AENtkXYmWdfH6UWqUqC5eSQDyloN:1731204228830"
    bash <(curl -sSL "$script_url")
}

# function to create a unique backup directory name with month, day, hours, and minutes
get_backup_dirname() {
    local timestamp
    timestamp=$(date +"%m%d_%H%M")
    echo -e "back-up_${timestamp}"
}
