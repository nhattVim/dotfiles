#!/bin/bash

show_progress() {
    local pid=$1
    local package_name=$2
    local spin_chars=("●○○○○○" "○●○○○○" "○○●○○○" "○○○●○○" "○○○○●○" "○○○○○●"
        "○○○○●○" "○○○●○○" "○○●○○○" "○●○○○○")
    local i=0

    tput civis

    while ps -p $pid &>/dev/null; do
        printf "\r%s %s" "Installing $package_name..." "${spin_chars[i]}"
        i=$(((i + 1) % 10))
        sleep 0.2
    done

    wait $pid
    exit_status=$?

    if [ $exit_status -eq 0 ]; then
        printf "\r✔ %s installed successfully!%-20s\n" "$package_name" ""
    else
        printf "\r❌ Failed to install %s!%-20s\n" "$package_name" ""
    fi

    tput cnorm # Hiện con trỏ lại
}

install_package_pacman() {
    local package_name="$1"

    if pacman -Q "$package_name" &>/dev/null; then
        printf "✔ %s is already installed. Skipping...\n" "$package_name"
    else
        printf "Installing %s...\n" "$package_name"

        stdbuf -oL sudo pacman -S --noconfirm --needed "$package_name" 2>&1 &
        show_progress $! "$package_name"
    fi
}

packages=(
    vim
    neovim
    tmux
    zsh
    fzf
    ripgrep
)

for package in "${packages[@]}"; do
    install_package_pacman "$package"
done

printf "\n✅ All packages installed!\n"
