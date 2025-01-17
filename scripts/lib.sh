#!/bin/bash

if [[ $EUID -eq 0 ]]; then
    echo "This script should not be executed as root! Exiting ..."
    exit 1
fi

RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW=$(tput setaf 3)
CYAN="$(tput setaf 6)"
PINK=$(tput setaf 212)
RESET=$(tput sgr0)

ok() { echo -e "\n${GREEN}[OK]${RESET} - $1\n"; }
err() { echo -e "\n${RED}[ERROR]${RESET} - $1\n"; }
act() { echo -e "\n${CYAN}[ACTION]${RESET} - $1\n"; }
note() { echo -e "\n${YELLOW}[NOTE]${RESET} - $1\n"; }

yes_no() { gum confirm "$1" && eval "$2='Y'" || eval "$2='N'"; }
choose() { gum confirm "$1" --affirmative "$2" --negative "$3" && eval "$4=$2" || eval "$4=$3"; }

ISAUR=$(basename "$(command -v paru || command -v yay)")
PKGMN=$(basename "$(command -v nala || command -v apt)")

iPac() {
    if pacman -Q "$1" &>/dev/null; then
        ok "$1 is already installed. Skipping ..."
    else
        act "Installing $1 ..."
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
        act "Installing $1 ..."
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
        act "Installing $1 ..."
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

cleanup_backups() {
    CONFIG_DIR=$HOME/.config
    BACKUP_PREFIX="-backup"

    act "Performing clean up backup folders"

    for DIR in "$CONFIG_DIR"/*; do
        if [ -d "$DIR" ]; then
            BACKUP_DIRS=()

            for BACKUP in "$DIR"$BACKUP_PREFIX*; do
                if [ -d "$BACKUP" ]; then
                    BACKUP_DIRS+=("$BACKUP")
                fi
            done

            if [ ${#BACKUP_DIRS[@]} -gt 0 ]; then

                if gum confirm "Found backups for: ${DIR##*/}. Keep only the latest backup?" --affirmative "Yes" --negative "Delete all"; then
                    latest_backup="${BACKUP_DIRS[0]}"
                    for BACKUP in "${BACKUP_DIRS[@]}"; do
                        [ "$BACKUP" != "$latest_backup" ] && rm -rf "$BACKUP"
                    done
                    ok "Keeping: ${latest_backup##*/}"
                else
                    for BACKUP in "${BACKUP_DIRS[@]}"; do
                        rm -rf "$BACKUP"
                    done
                    ok "All backups deleted for: ${DIR##*/}"
                fi
            fi
        fi
    done
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
