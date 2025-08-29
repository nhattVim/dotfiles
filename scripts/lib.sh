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
    sudo pacman -S --noconfirm --needed "$1"

    if pacman -Q "$1" &>/dev/null; then
        ok "$1 was installed"
        return 0
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
    $ISAUR -S --noconfirm --needed "$1"

    if $ISAUR -Q "$1" &>/dev/null; then
        ok "$1 was installed"
        return 0
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
    sudo $PKGMN install -y "$1"

    if dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q " installed"; then
        ok "$1 was installed"
        return 0
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
# Enable / disable services
# ============================================================
enable_service() {
    local svc_list=()
    local scope="system"
    local with_now=true

    # Parse flags
    while [[ $# -gt 0 ]]; do
        case "$1" in
        --now) with_now=true ;;
        --not-now) with_now=false ;;
        --user) scope="user" ;;
        --system) scope="system" ;;
        *) svc_list+=("$1") ;;
        esac
        shift
    done

    # Check if service list is empty
    if [[ ${#svc_list[@]} -eq 0 ]]; then
        err "No service specified"
        return 1
    fi

    # Choose systemctl command
    local cmd=("systemctl")
    [[ "$scope" == "system" && $EUID -ne 0 ]] && cmd=("sudo" "systemctl")
    [[ "$scope" == "user" ]] && cmd=("systemctl" "--user")

    # Loop qua từng service
    for svc in "${svc_list[@]}"; do
        note "Checking $svc ($scope)..."

        # Check if service exists or is masked
        if ! "${cmd[@]}" status "$svc" &>/dev/null; then
            err "$svc not found or masked"
            continue
        fi

        # Check if service is already enabled
        if "${cmd[@]}" is-enabled "$svc" &>/dev/null; then
            if [[ "$with_now" == true ]] && "${cmd[@]}" is-active "$svc" &>/dev/null; then
                ok "$svc is already enabled and running"
                continue
            elif [[ "$with_now" == false ]]; then
                ok "$svc is already enabled"
                continue
            fi
        fi

        # Enable/start service
        if [[ "$with_now" == true ]]; then
            act "Enabling and starting $svc..."
            "${cmd[@]}" enable --now "$svc"
            ok "$svc enabled and started"
        else
            act "Enabling $svc (will start on next boot)..."
            "${cmd[@]}" enable "$svc"
            ok "$svc enabled (not started now)"
        fi
    done
}

disable_service() {
    local svc_list=()
    local scope="system"
    local with_now=true

    # Parse flags
    while [[ $# -gt 0 ]]; do
        case "$1" in
        --now) with_now=true ;;
        --not-now) with_now=false ;;
        --user) scope="user" ;;
        --system) scope="system" ;;
        *) svc_list+=("$1") ;;
        esac
        shift
    done

    # Check if any service provided
    if [[ ${#svc_list[@]} -eq 0 ]]; then
        err "No service specified"
        return 1
    fi

    # Choose systemctl command
    local cmd=("systemctl")
    [[ "$scope" == "system" && $EUID -ne 0 ]] && cmd=("sudo" "systemctl")
    [[ "$scope" == "user" ]] && cmd=("systemctl" "--user")

    # Loop through services
    for svc in "${svc_list[@]}"; do
        act "Checking $svc ($scope)..."

        # Check if service exists
        if ! "${cmd[@]}" status "$svc" &>/dev/null; then
            note "$svc not found or masked, skipping."
            continue
        fi

        # Check if service is already disabled
        if ! "${cmd[@]}" is-enabled "$svc" &>/dev/null; then
            ok "$svc is already disabled"
            continue
        fi

        # Disable / stop service
        if [[ "$with_now" == true ]]; then
            act "Disabling and stopping $svc..."
            "${cmd[@]}" disable --now "$svc"
            ok "$svc disabled and stopped"
        else
            act "Disabling $svc (will not stop now)..."
            "${cmd[@]}" disable "$svc"
            ok "$svc disabled (not stopped)"
        fi
    done
}

# ============================================================
# Github ssh keys
# ============================================================
exGithub() {
    TOKEN="$1"

    # Check if token is empty
    if [[ -z "$TOKEN" ]]; then
        err "GitHub token is empty. Exiting."
        return 1
    fi

    # Define variables
    TEMP_DIR="$HOME/temp_secrets_$$"
    REPO_URL="https://$TOKEN@github.com/nhattVim/sshKey"

    # Clone repository
    act "Cloning .env repository..."
    if git -c credential.helper= clone "$REPO_URL" "$TEMP_DIR" &>/dev/null; then
        ok "Repository cloned successfully"
    else
        err "Failed to clone repo. Check token or access rights."
        return 1
    fi

    # Prepare SSH directory
    SSH_DIR="$HOME/.ssh"
    mkdir -p "$SSH_DIR"

    # Copy SSH keys
    act "Copying SSH keys from repo..."
    if cp "$TEMP_DIR/linux/id_ed25519" "$SSH_DIR/id_ed25519" 2>/dev/null &&
        cp "$TEMP_DIR/linux/id_ed25519.pub" "$SSH_DIR/id_ed25519.pub" 2>/dev/null; then
        chmod 600 "$SSH_DIR/id_ed25519"
        ok "SSH keys copied"
    else
        err "Failed to copy SSH keys"
        return 1
    fi

    # Configure SSH
    cat >"$SSH_DIR/config" <<EOF
Host github.com
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
EOF
    ok "SSH config applied"

    # Configure Git safely
    act "Configuring Git..."
    git config --global user.name "nhattvim"
    git config --global user.email "nhattruong13112000@gmail.com"
    git config --global core.autocrlf false
    ok "Git configuration applied"

    # Cleanup temporary folder
    rm -rf "$TEMP_DIR"
    ok "GitHub setup completed"
}

# ============================================================
# External installers
# ============================================================
exHypr() { bash <(curl -sSL "https://raw.githubusercontent.com/nhattVim/dotfiles/master/scripts/hyprland/$1"); }
exGnome() { bash <(curl -sSL "https://raw.githubusercontent.com/nhattVim/dotfiles/master/scripts/gnome/$1"); }
exWsl() { bash <(curl -sSL "https://raw.githubusercontent.com/nhattVim/dotfiles/master/scripts/wsl/$1"); }
