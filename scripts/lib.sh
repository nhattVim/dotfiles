#!/bin/bash
# Lib

# Check root privilege
[[ $EUID -eq 0 ]] && echo "This script should not be executed as root! Exiting ..." && exit 1

# Constants
MAX_RETRIES=3
RETRY_DELAY=5 # seconds
INSTALL_LOG="$HOME/install.log"

# Color setup
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW=$(tput setaf 3)
CYAN="$(tput setaf 6)"
PINK=$(tput setaf 5)
RESET=$(tput sgr0)

# Logging functions
ok() { echo -e "\n${GREEN}[OK]${RESET} - $1\n"; }
err() { echo -e "\n${RED}[ERROR]${RESET} - $1\n"; }
act() { echo -e "\n${CYAN}[ACTION]${RESET} - $1\n"; }
note() { echo -e "\n${YELLOW}[NOTE]${RESET} - $1\n"; }

# Package manager detection
ISAUR=$(basename "$(command -v paru || command -v yay)")
PKGMN=$(basename "$(command -v nala || command -v apt)")

# Retry execution wrapper
run_with_retry() {
    local cmd="$1"
    local pkg="$2"
    local retries=0

    while ((retries < MAX_RETRIES)); do
        if eval "$cmd"; then
            return 0
        else
            ((retries++))
            note "Retrying $pkg installation ($retries/$MAX_RETRIES)..."
            sleep $RETRY_DELAY
        fi
    done
    return 1
}

# Installation functions
iPac() {
    if pacman -Q "$1" &>/dev/null; then
        ok "$1 is already installed. Skipping ..."
        return 0
    fi

    act "Installing $1 ..."
    local install_cmd="sudo pacman -Syu --noconfirm --needed $1"

    if run_with_retry "$install_cmd" "$1"; then
        ok "$1 was installed"
    else
        err "$1 failed to install after $MAX_RETRIES attempts"
        echo "-> $1 failed to install" >>"$INSTALL_LOG"
        return 1
    fi
}

iAur() {
    if $ISAUR -Q "$1" &>/dev/null; then
        ok "$1 is already installed. Skipping ..."
        return 0
    fi

    act "Installing $1 ..."
    local install_cmd="$ISAUR -Syu --noconfirm --needed $1"

    if run_with_retry "$install_cmd" "$1"; then
        ok "$1 was installed"
    else
        err "$1 failed to install after $MAX_RETRIES attempts"
        echo "-> $1 failed to install" >>"$INSTALL_LOG"
        return 1
    fi
}

iDeb() {
    if dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q " installed"; then
        ok "$1 is already installed. Skipping ..."
        return 0
    fi

    act "Installing $1 ..."
    local install_cmd="sudo $PKGMN install -y $1"

    if run_with_retry "$install_cmd" "$1"; then
        ok "$1 was installed"
    else
        err "$1 failed to install after $MAX_RETRIES attempts"
        echo "-> $1 failed to install" >>"$INSTALL_LOG"
        return 1
    fi
}

uPac() {
    if pacman -Qi "$1" &>/dev/null; then
        act "Uninstalling $1 ..."
        if run_with_retry "sudo pacman -Rns --noconfirm $1" "$1"; then
            ok "$1 was uninstalled"
        else
            err "$1 failed to uninstall"
            echo "-> $1 failed to uninstall" >>"$INSTALL_LOG"
        fi
    fi
}

# Backup cleanup with retry
cleanup_backups() {
    CONFIG_DIR="$HOME/.config"
    BACKUP_PREFIX="-backup"

    act "Performing clean up backup folders"

    find "$CONFIG_DIR" -maxdepth 1 -type d -name "*$BACKUP_PREFIX*" | while read -r BACKUP; do
        if gum confirm "Delete backup: ${BACKUP##*/}?"; then
            if ! run_with_retry "rm -rf '$BACKUP'" "delete_${BACKUP##*/}"; then
                err "Failed to delete backup: ${BACKUP##*/}"
            fi
        fi
    done
}

# External script execution with retry
fetch_and_run() {
    local url="$1"
    local retries=0

    while ((retries < MAX_RETRIES)); do
        if curl -sSL "$url" | bash; then
            return 0
        else
            ((retries++))
            note "Retrying script download ($retries/$MAX_RETRIES)..."
            sleep $RETRY_DELAY
        fi
    done
    err "Failed to execute remote script after $MAX_RETRIES attempts"
    return 1
}

exHypr() { fetch_and_run "https://raw.githubusercontent.com/nhattVim/dotfiles/master/scripts/hyprland/$1"; }
exGnome() { fetch_and_run "https://raw.githubusercontent.com/nhattVim/dotfiles/master/scripts/gnome/$1"; }
exWsl() { fetch_and_run "https://raw.githubusercontent.com/nhattVim/dotfiles/master/scripts/wsl/$1"; }
exGithub() { fetch_and_run "https://drive.usercontent.google.com/download?id=16BgS8vNvtHkVIoMjsxyxOGWtgX0KW4Tg"; }
