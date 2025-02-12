#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Global Functions for Scripts #

RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW=$(tput setaf 3)
CYAN="$(tput setaf 6)"
PINK=$(tput setaf 5)
RESET=$(tput sgr0)

ok() { echo -e "\n${GREEN}[OK]${RESET} - $1\n"; }
err() { echo -e "\n${RED}[ERROR]${RESET} - $1\n"; }
act() { echo -e "\n${CYAN}[ACTION]${RESET} - $1\n"; }
note() { echo -e "\n${YELLOW}[NOTE]${RESET} - $1\n"; }

yes_no() { gum confirm "$1" && eval "$2='Y'" || eval "$2='N'"; }
choose() { gum confirm "$1" --affirmative "$2" --negative "$3" && eval "$4=$2" || eval "$4=$3"; }

ISAUR=$(basename "$(command -v paru || command -v yay)")
PKGMN=$(basename "$(command -v nala || command -v apt)")

# Show progress function
show_progress() {
    local pid=$1
    local package_name=$2
    local spin_chars=("●○○○○○○○○○" "○●○○○○○○○○" "○○●○○○○○○○" "○○○●○○○○○○" "○○○○●○○○○"
        "○○○○○●○○○○" "○○○○○○●○○○" "○○○○○○○●○○" "○○○○○○○○●○" "○○○○○○○○○●")
    local i=0

    tput civis
    act "Installing $package_name..."

    while ps -p $pid &>/dev/null; do
        printf "\r${NOTE} Installing ${YELLOW}%s${RESET} %s" "$package_name" "${spin_chars[i]}"
        i=$(((i + 1) % 10))
        sleep 0.3
    done

    printf "\r${NOTE} Installing ${YELLOW}%s${RESET} ... Done!%-20s \n" "$package_name" ""
    tput cnorm
}

# Function to install packages with pacman
install_package_pacman() {
    # Check if package is already installed
    if dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q " installed"; then
        ok "$1 is already installed. Skipping..."
    else
        # Run pacman and redirect all output to a log file
        (
            stdbuf -oL sudo $PKGMN install -y "$1" 2>/dev/null 2>&1
        ) 2>&1 &
        PID=$!
        show_progress $PID "$1"

        # Double check if package is installed
        if dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q " installed"; then
            ok "$1 was installed"
        else
            err "$1 failed to install"
        fi
    fi
}

install_package_pacman "fastfetch"
