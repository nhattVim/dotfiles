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
        err "Failed to enter dotfiles config directory"
        exit 1
    }
else
    note "Clone dotfiles..."
    git clone -b gnome https://github.com/nhattVim/dotfiles.git --depth 1 || {
        err "Failed to clone dotfiles"
        exit 1
    }
    cd dotfiles || {
        err "Failed to enter dotfiles directory"
        exit 1
    }
fi

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
        note "Config for $DIR found, attempting to back up."
        BACKUP_DIR="$DIRPATH-backup-$(date +%m%d_%H%M)"
        mv "$DIRPATH" "$BACKUP_DIR"
        note "Backup $DIRPATH to $BACKUP_DIR"
    fi
done

# delete old files
rm ~/.zshrc ~/.ideavimrc && rm -rf ~/.fonts ~/.icons ~/.themes

# copy config folder
mkdir -p $HOME/.config
cp -r config/* $HOME/.config/ && { ok "Copy config folder completed"; } || { err "Failed to copy config files."; }

# copying assets folder
cp -r assets/* $HOME/ && { ok "Copy assets completed"; } || { err "Failed to copy assets."; }

# Copy gtk-4.0 config for themes
cd $HOME/.themes/Catppuccin-Mocha-Standard-Mauve-Dark
mkdir -p $HOME/.config/gtk-4.0
cp -rf gtk-4.0 $HOME/.config

# Reload fonts
fc-cache -fv

# config Neovim
note "Backing up existing nvim folder"
[ -d "$HOME/.config/nvim" ] && mv $HOME/.config/nvim $HOME/.config/nvim.bak || { ok "Backup of nvim folder successful"; }
[ -d "$HOME/.local/share/nvim" ] && mv $HOME/.local/share/nvim $HOME/.local/share/nvim.bak || { ok "Backup of nvim data folder successful"; }
if git clone https://github.com/nhattVim/MYnvim.git $HOME/.config/nvim --depth 1; then
    npm install neovim -g
    ok "MYnvim setup completed successfully."
else
    err "Failed to set up MYnvim."
fi
