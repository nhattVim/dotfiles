#!/bin/bash

# source library
source <(curl -sSL https://is.gd/nhattVim_lib) && clear

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
    " ---------------------- Script developed by nhattVim ------------------------ " \
    "                                                                              " \
    "  ----------------- Github: https://github.com/nhattVim --------------------  " \
    "                                                                              "

# check dotfiles
cd "$HOME" || exit 1
if [ -d dotfiles ]; then
    cd dotfiles || {
        echo -e "${ERROR} - Failed to enter dotfiles config directory"
        exit 1
    }
else
    echo -e "${NOTE} - Cloning dotfiles..."
    git clone -b gnome https://github.com/nhattVim/dotfiles.git --depth 1 || {
        echo -e "${ERROR} - Failed to clone dotfiles"
        exit 1
    }
    cd dotfiles || {
        echo -e "${ERROR} - Failed to enter dotfiles directory"
        exit 1
    }
fi

# exit immediately if a command exits with a non-zero status.
set -e

# list folders to backup
folders=(
    alacritty
    kitty
    neofetch
    ranger
    rofi
    tmux
    gtk-4.0
)

# backup folders
for DIR in "${folders[@]}"; do
    DIRPATH=~/.config/"$DIR"
    if [ -d "$DIRPATH" ]; then
        echo -e "${NOTE} - Config for $DIR found, attempting to back up."
        BACKUP_DIR=$(get_backup_dirname)
        mv "$DIRPATH" "$DIRPATH-backup-$BACKUP_DIR"
        echo -e "${NOTE} - Backed up $DIR to $DIRPATH-backup-$BACKUP_DIR."
    fi
done

# delete old files
rm ~/.zshrc ~/.ideavimrc && rm -rf ~/.fonts ~/.icons ~/.themes

# copy config folder
mkdir -p $HOME/.config
cp -r config/* $HOME/.config/ && { echo -e "${OK} - Copy completed"; } || { echo -e "${ERROR} - Failed to copy config files."; }

# copying assets folder
cp -r assets/* $HOME/ && { echo -e "${OK} - Copy completed"; } || { echo -e "${ERROR} - Failed to copy assets."; }

# Copy gtk-4.0 config for themes
cd $HOME/.themes/Catppuccin-Mocha-Standard-Mauve-Dark
mkdir -p $HOME/.config/gtk-4.0
cp -rf gtk-4.0 $HOME/.config

# Reload fonts
fc-cache -fv

# config Neovim
echo -e "\n${NOTE} - Setting up MYnvim..."
[ -d "$HOME/.config/nvim" ] && mv $HOME/.config/nvim $HOME/.config/nvim.bak || { echo -e "${OK} - Backed up existing nvim folder"; }
[ -d "$HOME/.local/share/nvim" ] && mv $HOME/.local/share/nvim $HOME/.local/share/nvim.bak || { echo -e "${OK} - Backed up existing nvim data"; }

if git clone https://github.com/nhattVim/MYnvim.git $HOME/.config/nvim --depth 1; then
    npm install neovim -g
    echo -e "${OK} - MYnvim setup completed successfully."
else
    echo -e "${ERROR} - Failed to set up MYnvim."
fi
