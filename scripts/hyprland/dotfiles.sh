#!/bin/bash

# source library
. <(curl -sSL https://is.gd/nhattVim_lib)

# Dotfiles directory
DOTFILES_DIR="$HOME/hyprland_nhattVim"

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

# Remove old dotfiles if exist
if [ -d "$DOTFILES_DIR" ]; then
    rm -rf "$DOTFILES_DIR"
fi

# Clone dotfiles
note "Cloning dotfiles..."
if git clone -b hyprland https://github.com/nhattVim/dotfiles.git --depth 1 "$DOTFILES_DIR"; then
    ok "Cloned dotfiles successfully"
else
    err "Failed to clone dotfiles" && exit 1
fi

note "Copying config files"

folder=(
    ranger btop cava hypr ags
    kitty Kvantum qt5ct qt6ct rofi swappy
    swaync swaylock waybar wlogout
    fastfetch Thunar wallust
)

for DIR in "${folder[@]}"; do
    DIRPATH=$HOME/.config/"$DIR"
    if [ -d "$DIRPATH" ]; then
        note "Config for $DIR found, attempting to back up."
        BACKUP_DIR="$DIRPATH-backup-$(date +%m%d_%H%M)"
        mv "$DIRPATH" "$BACKUP_DIR"
        note "Backup $DIRPATH to $BACKUP_DIR"
    fi
done

# Copying config files
mkdir -p $HOME/.config
cp -r "$DOTFILES_DIR/config/." "$HOME/.config/" && { ok "Copy config files completed"; } || {
    err "Failed to copy config files"
}

# Copying wallpapers
mkdir -p "$HOME/Pictures/wallpapers"
cp -r "$DOTFILES_DIR/wallpapers" "$HOME/Pictures/" && { ok "Copy wallpapers completed"; } || {
    err "Failed to copy wallpapers"
}

# Copying assets files
cp "$DOTFILES_DIR/assets/.ideavimrc" "$HOME" &&
    cp "$DOTFILES_DIR/assets/.zshrc" "$HOME" &&
    cp "$DOTFILES_DIR/assets/.zprofile" "$HOME" && { ok "Copy assets files completed"; } || {
    err "Failed to copy assets files"
}

# performing clean up backup folders
cleanup_backups

# Set some files as executable
chmod +x "$HOME/.config/hypr/scripts/"*

# additional wallpapers
note "By default only a few wallpapers are copied..." && cd "$HOME"
while true; do
    if gum confirm "${CAT} Would you like to download additional wallpapers?"; then
        note "Downloading additional wallpapers..."
        if git clone https://github.com/nhattVim/wallpapers --depth 1; then
            note "Wallpapers downloaded successfully."

            if cp -R wallpapers/wallpapers/* "$HOME/Pictures/wallpapers/"; then
                note "Wallpapers copied successfully."
                rm -rf wallpapers
                break
            else
                err "Copying wallpapers failed."
            fi
        else
            err "Downloading additional wallpapers failed"
        fi
    else
        note "You chose not to download additional wallpapers."
        break
    fi
done

# remove dotfiles
if [ -d "$DOTFILES_DIR" ]; then
    rm -rf "$DOTFILES_DIR"
fi
