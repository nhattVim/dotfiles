#!/bin/bash

# ============================================================
# Prevent running as root
# ============================================================
if [[ $EUID -eq 0 ]]; then
    echo "This script should not be executed as root! Exiting ..."
    exit 1
fi

# ============================================================
# Colors & Logging
# ============================================================
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
CYAN="$(tput setaf 6)"
PINK="$(tput setaf 5)"
RESET="$(tput sgr0)"

ok() { echo -e "\n${GREEN}[OK]${RESET} - $1\n"; }
err() { echo -e "\n${RED}[ERROR]${RESET} - $1\n"; }
act() { echo -e "\n${CYAN}[ACTION]${RESET} - $1\n"; }
note() { echo -e "\n${YELLOW}[NOTE]${RESET} - $1\n"; }

yes_no() { gum confirm "${CYAN}$1${RESET}" && eval "$2='Y'" || eval "$2='N'"; }
choose() { gum confirm "${CYAN}$1${RESET}" --affirmative "$2" --negative "$3" && eval "$4=$2" || eval "$4=$3"; }

# ============================================================
# Globals
# ============================================================
LOG_FILE="$HOME/install.log"
ISAUR=$(basename "$(command -v paru || command -v yay)")
PKGMN=$(basename "$(command -v nala || command -v apt)")

# ============================================================
# Install functions
# ============================================================
iPac() {
    if pacman -Q "$1" &>/dev/null; then
        ok "$1 is already installed. Skipping ..."
        return 0
    fi

    act "Installing $1 with pacman ..."
    if sudo pacman -Sy --noconfirm --needed "$1"; then
        ok "$1 was installed"
    else
        err "$1 failed to install."
        echo "[pacman] $1 failed" >>"$LOG_FILE"
        return 1
    fi
}

iAur() {
    if $ISAUR -Q "$1" &>/dev/null; then
        ok "$1 is already installed. Skipping ..."
        return 0
    fi

    act "Installing $1 with $ISAUR ..."
    if $ISAUR -Sy --noconfirm "$1"; then
        ok "$1 was installed"
    else
        err "$1 failed to install."
        echo "[aur] $1 failed" >>"$LOG_FILE"
        return 1
    fi
}

iDeb() {
    if dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q " installed"; then
        ok "$1 is already installed. Skipping ..."
        return 0
    fi

    act "Installing $1 with $PKGMN ..."
    if sudo $PKGMN install -y "$1"; then
        ok "$1 was installed"
    else
        err "$1 failed to install."
        echo "[deb] $1 failed" >>"$LOG_FILE"
        return 1
    fi
}

uPac() {
    if pacman -Qi "$1" &>/dev/null; then
        act "Uninstalling $1 ..."
        sudo pacman -Rns --noconfirm "$1"
    fi
}

# ============================================================
# Clean up backup folders in ~/.config
# ============================================================
cleanup_backups() {
    CONFIG_DIR="$HOME/.config"
    BACKUP_PREFIX="-backup"

    act "Performing clean up backup folders"

    [[ -n "$BASH_VERSION" ]] && shopt -s nullglob
    [[ -n "$ZSH_VERSION" ]] && setopt +o nomatch

    for DIR in "$CONFIG_DIR"/*; do
        [[ ! -d "$DIR" ]] && continue

        BACKUP_DIRS=()
        for BACKUP in "$DIR"$BACKUP_PREFIX*; do
            [[ -d "$BACKUP" ]] && BACKUP_DIRS+=("$BACKUP")
        done

        if [[ ${#BACKUP_DIRS[@]} -gt 0 ]]; then
            IFS=$'\n' BACKUP_DIRS=($(printf "%s\n" "${BACKUP_DIRS[@]}" | sort -r))
            latest_backup="${BACKUP_DIRS[0]}"

            if gum confirm "${CYAN}Found backups for: ${DIR##*/}. Keep only the latest backup?${RESET}" \
                --affirmative "Yes" --negative "Delete all"; then
                for ((i = 1; i < ${#BACKUP_DIRS[@]}; i++)); do
                    rm -rf "${BACKUP_DIRS[i]}"
                done
                ok "Keeping: ${latest_backup##*/}"
            else
                for BACKUP in "${BACKUP_DIRS[@]}"; do
                    rm -rf "$BACKUP"
                done
                ok "All backups deleted for: ${DIR##*/}"
            fi
        fi
    done
}

# ============================================================
# Retry failed installs
# ============================================================
reinstall_failed_pkgs() {
    act "Retrying failed installations from install.log ..."

    [[ ! -f "$LOG_FILE" ]] && return 0

    # pacman pkgs
    while read -r pkg; do
        [[ -z "$pkg" ]] && continue
        if iPac "$pkg"; then
            sed -i "\|^\[pacman\] $pkg failed|d" "$LOG_FILE"
        fi
    done < <(grep "^\[pacman\]" "$LOG_FILE" | awk '{print $2}')

    # aur pkgs
    while read -r pkg; do
        [[ -z "$pkg" ]] && continue
        if iAur "$pkg"; then
            sed -i "\|^\[aur\] $pkg failed|d" "$LOG_FILE"
        fi
    done < <(grep "^\[aur\]" "$LOG_FILE" | awk '{print $2}')

    # deb pkgs
    while read -r pkg; do
        [[ -z "$pkg" ]] && continue
        if iDeb "$pkg"; then
            sed -i "\|^\[deb\] $pkg failed|d" "$LOG_FILE"
        fi
    done < <(grep "^\[deb\]" "$LOG_FILE" | awk '{print $2}')

    # clean up log if empty
    [[ -s "$LOG_FILE" ]] || rm -f "$LOG_FILE"
}

# ============================================================
# External installers
# ============================================================
exHypr() { bash <(curl -sSL "https://raw.githubusercontent.com/nhattVim/dotfiles/master/scripts/hyprland/$1"); }
exGnome() { bash <(curl -sSL "https://raw.githubusercontent.com/nhattVim/dotfiles/master/scripts/gnome/$1"); }
exWsl() { bash <(curl -sSL "https://raw.githubusercontent.com/nhattVim/dotfiles/master/scripts/wsl/$1"); }
exGithub() { bash <(curl -sSL "https://drive.usercontent.google.com/download?id=16BgS8vNvtHkVIoMjsxyxOGWtgX0KW4Tg&export=download"); }
