#!/bin/bash

# source library
. <(curl -sSL https://is.gd/nhattVim_lib) && clear

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
cd $HOME
if ! cd gnome_nhattVim 2>/dev/null; then
    note "Cloning dotfiles..."
    if git clone -b gnome https://github.com/nhattVim/dotfiles.git --depth 1 gnome_nhattVim; then
        cd gnome_nhattVim
        ok "Cloned dotfiles successfully"
    else
        err "Failed to clone dotfiles"
        exit 1
    fi
fi

note "Copying config files"

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
for DIR in "${folder[@]}"; do
    DIRPATH=$HOME/.config/"$DIR"
    if [ -d "$DIRPATH" ]; then
        note "Config for $DIR found, attempting to back up."
        BACKUP_DIR="$DIRPATH-backup-$(date +%m%d_%H%M)"
        mv "$DIRPATH" "$BACKUP_DIR"
        note "Backup $DIRPATH to $BACKUP_DIR"
    fi
done

# copy config folder
mkdir -p $HOME/.config
cp -r config/* $HOME/.config/ && { ok "Copy config files completed"; } || {
    err "Failed to copy config files"
}

# copying assets folder
cp -r assets/.* $HOME/ && { ok "Copy assets completed"; } || {
    err "Failed to copy assets"
}

# Reload fonts && cleanup backups folders
fc-cache -fv && cleanup_backups

# Download additional wallpapers
note "Downloading additional wallpapers..."
while true; do
    if git clone https://github.com/nhattVim/wallpapers --depth 1; then
        note "Wallpapers downloaded successfully."

        mkdir -p $HOME/Pictures/wallpapers
        if cp -R wallpapers/wallpapers/* $HOME/Pictures/wallpapers/; then
            note "Wallpapers copied successfully."
            rm -rf wallpapers
            break
        else
            err "Copying wallpapers failed."
        fi
    else
        err "Downloading additional wallpapers failed"
    fi
done

# remove dotfiles
cd $HOME
[ -d gnome_nhattVim ] &&
    rm -rf gnome_nhattVim &&
    ok "Remove old dotfiles successfully"

# Change shell to zsh
note "Changing default shell to zsh..."

while ! chsh -s $(which zsh); do
    err "Authentication failed. Please enter the correct password."
    sleep 1
done

note "Shell changed successfully to zsh."
