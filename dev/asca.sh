#!/bin/bash

if [[ $EUID -eq 0 ]]; then
    echo -e "This script should not be executed as root! Exiting......."
    exit 1
fi

OK_COLOR="$(tput setaf 2)"
ERROR_COLOR="$(tput setaf 1)"
NOTE_COLOR="$(tput setaf 3)"
ACTION_COLOR="$(tput setaf 6)"
RESET_COLOR=$(tput sgr0)

ok() { echo -e "\n${OK_COLOR}[OK]${RESET_COLOR} - $1\n"; }
err() { echo -e "\n${ERROR_COLOR}[ERROR]${RESET_COLOR} - $1\n"; }
note() { echo -e "\n${NOTE_COLOR}[NOTE]${RESET_COLOR} - $1\n"; }
act() { echo -e "\n${ACTION_COLOR}[ACTION]${RESET_COLOR} - $1\n"; }

yes_no() { gum confirm "$1" && eval "$2='Y'" || eval "$2='N'"; }
choose() { gum confirm "$1" --affirmative "$2" --negative "$3" && eval "$4=$2" || eval "$4=$3"; }

ISAUR=$(command -v yay &>/dev/null && echo "yay" || (command -v paru &>/dev/null && echo "paru"))
PKGMN=$(command -v nala &>/dev/null && echo "nala" || (command -v apt &>/dev/null && echo "apt"))

iPac() {
    if pacman -Q "$1" &>/dev/null; then
        ok "$1 is already installed. Skipping ..."
    else
        ok "Installing $1 ..."
        sudo pacman -Syu --noconfirm "$1" && ok "$1 was installed" || {
            err "$1 failed to install. You may need to install manually!"
            echo "-> $1 failed to install" >>"$HOME/install.log"
        }
    fi
}

iAur() {
    if $ISAUR -Q "$1" &>>/dev/null; then
        ok "$1 is already installed. Skipping ..."
    else
        ok "Installing $1 ..."
        $ISAUR -Syu --noconfirm "$1" && ok "$1 was installed" || {
            err "$1 failed to install. You may need to install manually!"
            echo "-> $1 failed to install" >>"$HOME/install.log"
        }
    fi
}

iDeb() {
    if dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q " installed"; then
        ok "$1 is already installed. Skipping ..."
    else
        ok "Installing $1 ..."
        sudo $PKGMN install -y "$1" && ok "$1 was installed" || {
            err "$1 failed to install. You may need to install manually!"
            echo "-> $1 failed to install" >>"$HOME/install.log"
        }
    fi
}

uPac() {
    if pacman -Qi "$1" &>>/dev/null; then
        ok "Uninstalling $1 ..."
        sudo pacman -Rns --noconfirm "$1" && ok "$1 was uninstalled" || {
            err "$1 failed to uninstall"
            echo "-> $1 failed to uninstall" >>"$HOME/install.log"
        }
    fi
}

exHypr() {
    local script_url="https://raw.githubusercontent.com/nhattVim/dotfiles/master/scripts/hyprland/$1"
    bash <(curl -sSL "$script_url")
}

exGnome() {
    local script_url="https://raw.githubusercontent.com/nhattVim/dotfiles/master/scripts/gnome/$1"
    bash <(curl -sSL "$script_url")
}

exWsl() {
    local script_url="https://raw.githubusercontent.com/nhattVim/dotfiles/master/scripts/wsl/$1"
    bash <(curl -sSL "$script_url")
}

exGithub() {
    local script_url="https://drive.usercontent.google.com/download?id=16BgS8vNvtHkVIoMjsxyxOGWtgX0KW4Tg&export=download&authuser=0&confirm=t&uuid=7362d2fa-5f01-4891-ba96-78ea32b8ffdc&at=AENtkXYmWdfH6UWqUqC5eSQDyloN:1731204228830"
    bash <(curl -sSL "$script_url")
}

get_backup_dirname() {
    local timestamp
    timestamp=$(date +"%m%d_%H%M")
    echo -e "back-up_${timestamp}"
}
