#!/bin/bash

# source library
. <(curl -sSL https://is.gd/nhattVim_lib) && clear

# variables
wallpaper="$HOME/Pictures/wallpapers/art-3.png"
waybar_style="$HOME/.config/waybar/style/[Wallust] Simple.css"
waybar_config="$HOME/.config/waybar/configs/[TOP] Default_v4"
waybar_config_laptop="$HOME/.config/waybar/configs/[TOP] Default Laptop_v4"

HYPR_FOLDER="$HOME/.config/hypr/configs"
ENV_FILE="$HYPR_FOLDER/env_variables.conf"
MONITOR_FILE="$HYPR_FOLDER/monitors.conf"
SETTINGS_FILE="$HYPR_FOLDER/settings.conf"
STARTUP_FILE="$HYPR_FOLDER/execs.conf"

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

# uncommenting WLR_NO_HARDWARE_CURSORS if nvidia is detected
if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq nvidia; then
    note "Nvidia GPU detected. Setting up proper env's and configs"
    sed -i '/env = LIBVA_DRIVER_NAME,nvidia/s/^#//' "$ENV_FILE"
    sed -i '/env = __GLX_VENDOR_LIBRARY_NAME,nvidia/s/^#//' "$ENV_FILE"
    sed -i '/env = NVD_BACKEND,direct/s/^#//' "$ENV_FILE"
    # enabling no hardware cursors if nvidia detected
    sed -i 's/^\([[:space:]]*no_hardware_cursors[[:space:]]*=[[:space:]]*\)false/\1true/' "$SETTINGS_FILE"
fi

# uncommenting WLR_RENDERER_ALLOW_SOFTWARE,1 if running in a VM is detected
if hostnamectl | grep -q 'Chassis: vm'; then
    note "System is running in a virtual machine"
    sed -i 's/^\([[:space:]]*no_hardware_cursors[[:space:]]*=[[:space:]]*\)false/\1true/' "$SETTINGS_FILE"
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
    cp -r $HOME/.config/rofi/resolution/1080p/* $HOME/.config/rofi/
    # hyprlock matters
    # mv config/hypr/hyprlock.conf config/hypr/hyprlock-2k.conf
    # mv config/hypr/hyprlock-1080p.conf config/hypr/hyprlock.conf
elif [ "$resolution" == "≥ 1440p" ]; then
    cp -r $HOME/.config/rofi/resolution/1440p/* $HOME/.config/rofi/
    sed -i 's/font_size 13.0/font_size 16.0/' $HOME/.config/kitty/kitty.conf
fi

# Detect machine type and set Waybar configurations accordingly, logging the output
if hostnamectl | grep -q 'Chassis: desktop'; then
    # Configurations for a desktop
    ln -sf "$waybar_config" "$HOME/.config/waybar/config"
    # Remove waybar configs for laptop
    rm -rf "$HOME/.config/waybar/configs/[TOP] Default Laptop" \
        "$HOME/.config/waybar/configs/[BOT] Default Laptop" \
        "$HOME/.config/waybar/configs/[TOP] Default Laptop_v2" \
        "$HOME/.config/waybar/configs/[TOP] Default Laptop_v3" \
        "$HOME/.config/waybar/configs/[TOP] Default Laptop_v4"
else
    # Configurations for a laptop or any system other than desktop
    ln -sf "$waybar_config_laptop" "$HOME/.config/waybar/config"
    # Remove waybar configs for desktop
    rm -rf "$HOME/.config/waybar/configs/[TOP] Default" \
        "$HOME/.config/waybar/configs/[BOT] Default" \
        "$HOME/.config/waybar/configs/[TOP] Default_v2" \
        "$HOME/.config/waybar/configs/[TOP] Default_v3" \
        "$HOME/.config/waybar/configs/[TOP] Default_v4"
fi

# symlinks for waybar style
ln -sf "$waybar_style" "$HOME/.config/waybar/style.css" &&

    # initialize wallust to avoid config error on hyprland
    export PATH="$HOME/.cargo/bin:$PATH" && wallust run -s $wallpaper

# check log
if [ -f $HOME/install.log ]; then
    gum confirm "${CYAN} Do you want to check log?" &&
        gum pager <$HOME/install.log
fi

# clear packages
note "Clear packages." &&
    sudo pacman -Sc --noconfirm && yay -Sc --noconfirm && yay -Yc --noconfirm &&
    ok "Clearing packages succesfully" || err "Failed to clear packages"

# Change shell to zsh
note "Changing default shell to zsh..."

while ! chsh -s $(which zsh); do
    err "Authentication failed. Please enter the correct password."
    sleep 1
done

note "Shell changed successfully to zsh."
