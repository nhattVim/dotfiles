#!/bin/bash

# source library
source <(curl -sSL https://is.gd/nhattVim_lib) && clear

# variables
wallpaper=$HOME/Pictures/wallpapers/anime-kanji.jpg
waybar_style="$HOME/.config/waybar/style/simple [pywal].css"

HYPR_FOLDER="config/hypr/configs"
ENV_FILE="$HYPR_FOLDER/env_variables.conf"
MONITOR_FILE="$HYPR_FOLDER/monitors.conf"
SETTINGS_FILE="$HYPR_FOLDER/settings.conf"
STARTUP_FILE="$HYPR_FOLDER/execs.conf"

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
    " ---------------------- Script developed by nhattVim ------------------------ " \
    "                                                                              " \
    "  ----------------- Github: https://github.com/nhattVim --------------------  " \
    "                                                                              "

# check dotfiles
cd "$HOME" || exit 1
if [ -d dotfiles ]; then
    cd dotfiles || {
        err "Failed to enter dotfiles directory"
        exit 1
    }
else
    note "Clone dotfiles." && git clone -b hyprland https://github.com/nhattVim/dotfiles.git --depth 1 || {
        err "Failed to clone dotfiles"
        exit 1
    }
    cd dotfiles || {
        err "Failed to enter dotfiles directory"
        exit 1
    }
fi

# uncommenting WLR_NO_HARDWARE_CURSORS if nvidia is detected
if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq nvidia; then
    note "Nvidia GPU detected. Setting up proper env's and configs"
    sed -i '/env = LIBVA_DRIVER_NAME,nvidia/s/^#//' "$ENV_FILE"
    sed -i '/env = __GLX_VENDOR_LIBRARY_NAME,nvidia/s/^#//' "$ENV_FILE"
    sed -i '/env = NVD_BACKEND,direct/s/^#//' "$ENV_FILE"
    # enabling no hardware cursors if nvidia detected
    sed -i 's/^\([[:space:]]*no_hardware_cursors[[:space:]]*=[[:space:]]*\)2/\1true/' "$SETTINGS_FILE"
fi

# uncommenting WLR_RENDERER_ALLOW_SOFTWARE,1 if running in a VM is detected
if hostnamectl | grep -q 'Chassis: vm'; then
    note "System is running in a virtual machine"
    sed -i 's/^\([[:space:]]*no_hardware_cursors[[:space:]]*=[[:space:]]*\)2/\1true/' "$SETTINGS_FILE"
    sed -i '/env = WLR_RENDERER_ALLOW_SOFTWARE,1/s/^#//' "$ENV_FILE"
    sed -i '/monitor = Virtual-1, 1920x1080@60,auto,1/s/^#//' "$MONITOR_FILE"
fi

# activating hyprcursor on env by checking if the directory ~/.icons/Bibata-Modern-Ice/hyprcursors exists
if [ -d "$HOME/.icons/Bibata-Modern-Ice/hyprcursors" ]; then
    # Define the config file path
    sed -i 's/^#env = HYPRCURSOR_THEME,Bibata-Modern-Ice/env = HYPRCURSOR_THEME,Bibata-Modern-Ice/' "$ENV_FILE"
    sed -i 's/^#env = HYPRCURSOR_SIZE,24/env = HYPRCURSOR_SIZE,24/' "$ENV_FILE"
fi

# Function to detect keyboard layout using localectl or setxkbmap
detect_layout() {
    if command -v localectl >/dev/null 2>&1; then
        layout=$(localectl status --no-pager | awk '/X11 Layout/ {print $3}')
        if [ -n "$layout" ]; then
            echo "$layout"
        fi
    elif command -v setxkbmap >/dev/null 2>&1; then
        layout=$(setxkbmap -query | grep layout | awk '{print $2}')
        if [ -n "$layout" ]; then
            echo "$layout"
        fi
    fi
}

# Detect the current keyboard layout
layout=$(detect_layout)

if [ "$layout" = "(unset)" ]; then
    gum style \
        --border-foreground 212 --border rounded \
        --align left --width 80 --margin "1 2" --padding "2 4" \
        "${RED}IMPORTANT WARNING${RESET}" \
        "   - The Default Keyboard Layout could not be detected" \
        "   - You need to set it Manually" \
        "${YELLOW}WARNING${RESET}" \
        "   - Setting a wrong Keyboard Layout will cause Hyprland to crash" \
        "   - If you are not sure, just type us" \
        "${YELLOW}NOTE:${RESET}" \
        "   - You can also set more than 2 keyboard layouts" \
        "   - For example us, vn, kr, gb"

    act "Please enter a keyboard layout"
    while true; do
        new_layout=$(gum input --prompt="-> " --placeholder "Keyboard layout")
        if [ -n "$new_layout" ]; then
            layout="$new_layout"
            break
        fi
    done
fi

note "Deteacting keyboard layout to prepare necessary changes in hyprland.conf before copying"

# Prompt the user to confirm whether the detected layout is correct
if gum confirm "${CYAN}Detected current keyboard layout is: ${YELLOW}'$layout'${RESET}${CYAN}.Is this correct?"; then
    # If the detected layout is correct, update the 'kb_layout=' line in the file
    awk -v layout="$layout" '/kb_layout/ {$0 = "  kb_layout=" layout} 1' "$SETTINGS_FILE" >temp.conf
    mv temp.conf "$SETTINGS_FILE"
    note "kb_layout $layout configured in settings."
else
    gum style \
        --border-foreground 212 --border rounded \
        --align left --width 80 --margin "1 2" --padding "2 4" \
        "${RED}IMPORTANT WARNING${RESET}" \
        "   - The Default Keyboard Layout could not be detected" \
        "   - You need to set it Manually" \
        "${YELLOW}WARNING${RESET}" \
        "   - Setting a wrong Keyboard Layout will cause Hyprland to crash" \
        "   - If you are not sure, just type us" \
        "${YELLOW}NOTE:${RESET}" \
        "   - You can also set more than 2 keyboard layouts" \
        "   - For example us, vn, kr, gb"

    act "Please enter a keyboard layout"
    new_layout=$(gum input --prompt="-> " --placeholder "Keyboard layout")

    # Update the 'kb_layout=' line with the correct layout in the file
    awk -v new_layout="$new_layout" '/kb_layout/ {$0 = "  kb_layout=" new_layout} 1' "$SETTINGS_FILE" >temp.conf
    mv temp.conf "$SETTINGS_FILE"
    note "kb_layout $new_layout configured in settings."
fi

# Check if asusctl is installed  on Startup
if command -v asusctl >/dev/null 2>&1; then
    sed -i '/exec-once = rog-control-center &/s/^#//' "$STARTUP_FILE"
fi

# Check if blueman-applet is installed and add blueman-applet on Startup
if command -v blueman-applet >/dev/null 2>&1; then
    sed -i '/exec-once = blueman-applet &/s/^#//' "$STARTUP_FILE"
fi

# Action to do for better rofi and kitty appearance
gum style \
    --border-foreground 212 --border rounded \
    --align left --width 80 --margin "1 2" --padding "2 4" \
    "${CYAN}Select monitor resolution to properly configure appearance and fonts:" "" \
    "   - 1. for monitor res 1440p or less (< 1440p)" \
    "   - 2. for monitors res higher than 1440p (≥ 1440p)"

if gum confirm "${PINK} Enter the number of your choice: " --affirmative "≤ 1080p" --negative "≥ 1440p"; then
    resolution="< 1440p"
else
    resolution="≥ 1440p"
fi

# Use the selected resolution in your existing script
note "You chose $resolution resolution."

# Add your commands based on the resolution choice
if [ "$resolution" == "< 1440p" ]; then
    cp -r config/rofi/resolution/1080p/* config/rofi/
    # hyprlock matters
    # mv config/hypr/hyprlock.conf config/hypr/hyprlock-2k.conf
    # mv config/hypr/hyprlock-1080p.conf config/hypr/hyprlock.conf
elif [ "$resolution" == "≥ 1440p" ]; then
    cp -r config/rofi/resolution/1440p/* config/rofi/
    sed -i 's/font_size 13.0/font_size 16.0/' config/kitty/kitty.conf
fi

set -e

note "Copying config files"

folder=(
    ranger alacritty btop cava hypr
    kitty Kvantum qt5ct qt6ct rofi swappy
    swaync swaylock wal waybar wlogout
    neofetch Thunar xfce4
)

for DIR in "${folder[@]}"; do
    DIRPATH=$HOME/.config/"$DIR"
    if [ -d "$DIRPATH" ]; then
        note "Config for $DIR found, attempting to back up."
        BACKUP_DIR=$(get_backup_dirname)
        mv "$DIRPATH" "$DIRPATH-backup-$BACKUP_DIR"
        note "Backup $DIRPATH to $DIRPATH-backup-$BACKUP_DIR"
    fi
done

# Copying config files
mkdir -p $HOME/.config
cp -r config/* $HOME/.config/ && { ok "Copy config files completed"; } || {
    err "Failed to copy config files"
}

# Copying wallpapers
mkdir -p $HOME/Pictures/wallpapers
cp -r wallpapers $HOME/Pictures/ && { ok "Copy wallpapers completed"; } || {
    err "Failed to copy wallpapers"
}

# Copying assets files
cp assets/.ideavimrc $HOME && cp assets/.zshrc $HOME && cp assets/.zprofile $HOME && { ok "Copy assets files completed"; } || {
    err "Failed to copy assets files"
}

# Set some files as executable
chmod +x $HOME/.config/hypr/scripts/*
chmod +x $HOME/.config/hypr/boot.sh

# Detect machine type and set Waybar configurations accordingly, logging the output
if hostnamectl | grep -q 'Chassis: desktop'; then
    # Configurations for a desktop
    ln -sf "$HOME/.config/waybar/configs/default [TOP]" "$HOME/.config/waybar/config"
    rm -r "$HOME/.config/waybar/configs/default laptop [TOP]" "$HOME/.config/waybar/configs/default laptop [BOT]"
else
    # Configurations for a laptop or any system other than desktop
    ln -sf "$HOME/.config/waybar/configs/default laptop [TOP]" "$HOME/.config/waybar/config"
    rm -r "$HOME/.config/waybar/configs/default [TOP]" "$HOME/.config/waybar/configs/default [BOT]"
fi

# additional wallpapers
note "By default only a few wallpapers are copied..." && cd $HOME
while true; do
    if gum confirm "${CAT} Would you like to download additional wallpapers?"; then
        note "Downloading additional wallpapers..."
        if git clone https://github.com/nhattVim/wallpapers --depth 1; then
            note "Wallpapers downloaded successfully."

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
    else
        note "You chose not to download additional wallpapers."
        break
    fi
done

# symlinks for waybar style
ln -sf "$waybar_style" "$HOME/.config/waybar/style.css" &&

    # initialize pywal to avoid config on hyprland
    # wal -i $wallpaper -s -t
    # initialize wallust to avoid config error on hyprland
    wallust run -s $wallpaper

# Change shell to zsh
note "Changing default shell to zsh..."

while ! chsh -s /bin/zsh; do
    err "Authentication failed. Please enter the correct password."
    sleep 1
done

note "Shell changed successfully to zsh."

# Successfully
gum style \
    --border-foreground 212 --border rounded \
    --align left --width 80 --margin "1 2" --padding "2 4" \
    "${CYAN}GREAT Copy Completed." "" \
    "${CYAN}YOU NEED to logout and re-login or reboot to avoid issues"
