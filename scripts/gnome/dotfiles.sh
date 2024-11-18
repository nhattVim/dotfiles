#!/bin/bash

# source library
source <(curl -sSL https://is.gd/nhattruongNeoVim_lib)

# init
clear

# start script
gum style \
    --foreground 213 --border-foreground 213 --border rounded \
    --align center --width 90 --margin "1 2" --padding "2 4" \
    "  ____   __ __   ____  ______      ______  ____   __ __   ___   ____    ____  " \
    " |    \ |  |  | /    ||      |    |      ||    \ |  |  | /   \ |    \  /    | " \
    " |  _  ||  |  ||  o  ||      |    |      ||  D  )|  |  ||     ||  _  ||   __| " \
    " |  |  ||  _  ||     ||_|  |_|    |_|  |_||    / |  |  ||  O  ||  |  ||  |  | " \
    " |  |  ||  |  ||  _  |  |  |        |  |  |    \ |  :  ||     ||  |  ||  |_ | " \
    " |  |  ||  |  ||  |  |  |  |        |  |  |  .  \|     ||     ||  |  ||     | " \
    " |__|__||__|__||__|__|  |__|        |__|  |__|\_| \__,_| \___/ |__|__||___,_| " \
    "                                                                              " \
    " ------------------- Script developed by nhattruongNeoVim ------------------- " \
    "                                                                              " \
    "  -------------- Github: https://github.com/nhattruongNeoVim ---------------  " \
    "                                                                              "

# check dotfiles
cd "$HOME" || exit 1
if [ -d dotfiles ]; then
    cd dotfiles || {
        printf "%s - Failed to enter dotfiles config directory\n" "${ERROR}"
        exit 1
    }
else
    printf "\n%s - Clone dotfiles. \n" "${NOTE}" &&
        git clone -b gnome https://github.com/nhattruongNeoVim/dotfiles.git --depth 1 || {
        printf "%s - Failed to clone dotfiles \n" "${ERROR}"
        exit 1
    }
    cd dotfiles || {
        printf "%s - Failed to enter dotfiles directory\n" "${ERROR}"
        exit 1
    }
fi

# exit immediately if a command exits with a non-zero status.
set -e

# list folders to backup
folder=(
    alacritty
    kitty
    neofetch
    ranger
    rofi
    tmux
    gtk-4.0
)

# backup folders
for DIR in "${folder[@]}"; do
    DIRPATH=~/.config/"$DIR"
    if [ -d "$DIRPATH" ]; then
        printf "\n%s - Config for $DIR found, attempting to back up. \n" "${NOTE}"
        BACKUP_DIR=$(get_backup_dirname)
        mv "$DIRPATH" "$DIRPATH-backup-$BACKUP_DIR"
        printf "\n%s - Backed up $DIR to $DIRPATH-backup-$BACKUP_DIR. \n" "${NOTE}"
    fi
done

printf "\n%.0s" {1..2}

# delete old file
rm ~/.zshrc ~/.ideavimrc && rm -rf ~/.fonts ~/.icons ~/.themes

# coppy config folder
mkdir -p $HOME/.config
cp -r config/* $HOME/.config/ && { echo "${OK} - Copy completed"; } || {
    echo "${ERROR} - Failed to copy config files."
}

# copying assets folder
cp -r assets/* $HOME/ && { echo "${OK} - Copy completed"; } || {
    echo "${ERROR} - Failed to copy config files."
}

cd $HOME/.themes/Catppuccin-Mocha-Standard-Mauve-Dark
mkdir -p $HOME/.config/gtk-4.0
cp -rf gtk-4.0 $HOME/.config

# Reload fonts
fc-cache -fv

# config Neovim
printf "\n%s - Setup MYnvim ... \n" "${NOTE}"
[ -d "$HOME/.config/nvim" ] && mv $HOME/.config/nvim $HOME/.config/nvim.bak || {
    printf "\n%s - Failed to backup nvim folder \n" "${OK}"
}
[ -d "$HOME/.local/share/nvim" ] && mv $HOME/.local/share/nvim $HOME/.local/share/nvim.bak || {
    printf "\n%s - Failed to backup nvim-data folder \n" "${OK}"
}
if git clone https://github.com/nhattruongNeoVim/MYnvim.git $HOME/.config/nvim --depth 1; then
    npm install neovim -g
    printf "\n%s - Setup MYnvim successfully \n" "${OK}"
else
    printf "\n%s - Failed to setup MYnvim \n" "${ERROR}"
fi
