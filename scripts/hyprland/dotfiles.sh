#!/bin/bash

# source library
. <(curl -sSL https://raw.githubusercontent.com/nhattVim/dotfiles/refs/heads/master/scripts/lib.sh) && clear

# variables
wallpaper="$HOME/Pictures/Wallpapers/car-2.png"
kvantum_theme="Tokyo-Night"
color_scheme="prefer-dark"
gtk_theme="adw-gtk3-dark"
icon_theme="Tokyonight-SE"
cursor_theme="Bibata-Modern-Ice"
cursor_size=24

DOTFILES_DIR=$(mktemp -d)
trap 'rm -rf "$DOTFILES_DIR"' EXIT
HYPR_FOLDER="$HOME/.config/hypr/configs"
ENV_FILE="$HYPR_FOLDER/envs.lua"
MONITOR_FILE="$HYPR_FOLDER/monitors.lua"
SETTINGS_FILE="$HYPR_FOLDER/settings.lua"
STARTUP_FILE="$HYPR_FOLDER/execs.lua"
KEYBINDS_DIR="$HYPR_FOLDER/keybinds.lua"

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

# Clone dotfiles
note "Cloning dotfiles..."
if git clone -b hyprland https://github.com/nhattVim/dotfiles.git --depth 1 "$DOTFILES_DIR"; then
    ok "Cloned dotfiles successfully"
else
    err "Failed to clone dotfiles" && exit 1
fi

note "Copying config files"

for DIR in "$DOTFILES_DIR"/config/*; do
    BASENAME=$(basename "$DIR")
    DIRPATH="$HOME/.config/$BASENAME"

    if [ -d "$DIRPATH" ]; then
        note "Config for $BASENAME found, attempting to back up."
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
mkdir -p "$HOME/Pictures/Wallpapers"
cp -r "$DOTFILES_DIR/Wallpapers" "$HOME/Pictures/" && { ok "Copy wallpapers completed"; } || {
    err "Failed to copy wallpapers"
}

# Copying assets files
cp "$DOTFILES_DIR/assets/.ideavimrc" "$HOME" &&
    cp "$DOTFILES_DIR/assets/.zshrc" "$HOME" &&
    { ok "Copy assets files completed"; } || {
    err "Failed to copy assets files"
}

# Copy GTK themes file
note "Copying gtk themes file"
for dir in .icons .fonts .themes; do
    mkdir -p "$HOME/$dir"
    if cp -r "$DOTFILES_DIR/assets/$dir/." "$HOME/$dir/"; then
        ok "Copied $dir successfully"
        [[ "$dir" == ".fonts" ]] && fc-cache -fv
    else
        err "Failed to copy $dir"
    fi
done

# performing clean up backup folders
cleanup_backups

# Set some files as executable
chmod +x "$HOME/.config/hypr/scripts/"*

# Add apps to startup
declare -A startup_apps=(
    ["asusctl"]="rog-control-center"
    ["fcitx5"]="fcitx5 -d"
)

# Check if each app is installed and enable it in Startup
for app in "${!startup_apps[@]}"; do
    CMD="${startup_apps[$app]}"

    if command -v "$app" >/dev/null 2>&1; then
        sed -i "s|^[[:space:]]*--[[:space:]]*exec(\"$CMD\")|    exec(\"$CMD\")|" "$STARTUP_FILE"
        note "Enabled startup app: $CMD"
    fi
done

# Setup Fcitx5
if command -v fcitx5 >/dev/null 2>&1; then
    act "Setting up Fcitx5..."
    echo "--ozone-platform-hint=x11" >>"$HOME/.config/electron-flags.conf"
    echo "--ozone-platform-hint=x11" >>"$HOME/.config/code-flags.conf"
fi

# uncommenting if nvidia is detected
if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq nvidia; then
    note "Nvidia GPU detected. Setting up proper env's and configs"
    sed -i 's/^[[:space:]]*--[[:space:]]*\(env(\"LIBVA_DRIVER_NAME\", \"nvidia\")\)/\1/' "$ENV_FILE"
    sed -i 's/^[[:space:]]*--[[:space:]]*\(env(\"__GLX_VENDOR_LIBRARY_NAME\", \"nvidia\")\)/\1/' "$ENV_FILE"
fi

# if running in a VM is detected
if hostnamectl | grep -q 'Chassis: vm'; then
    note "Change default termial from kitty to foot"
    sed -i 's/kitty/foot/g' "$KEYBINDS_DIR"
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
    awk -v layout="$layout" '/kb_layout/ {$0 = "        kb_layout = \"" layout "\","} 1' "$SETTINGS_FILE" >temp.lua
    mv temp.lua "$SETTINGS_FILE"
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
    awk -v new_layout="$new_layout" '/kb_layout/ {$0 = "        kb_layout = \"" new_layout "\","} 1' "$SETTINGS_FILE" >temp.lua
    mv temp.lua "$SETTINGS_FILE"
    note "kb_layout $new_layout configured in settings."
fi

# Generate scheme stuff
caelestia scheme set -n shadotheme

# additional wallpapers
note "By default only a few wallpapers are copied..." && cd "$HOME"
while true; do
    if gum confirm "${CAT} Would you like to download additional wallpapers?"; then
        note "Downloading additional wallpapers..."
        if git clone https://github.com/nhattVim/wallpapers --depth 1; then
            note "Wallpapers downloaded successfully."

            if cp -R wallpapers/wallpapers/* "$HOME/Pictures/Wallpapers/"; then
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

act "Apply GTK theme..."
gsettings set org.gnome.desktop.interface color-scheme "$color_scheme"
gsettings set org.gnome.desktop.interface gtk-theme "$gtk_theme"
gsettings set org.gnome.desktop.interface icon-theme "$icon_theme"
gsettings set org.gnome.desktop.interface cursor-theme "$cursor_theme"
gsettings set org.gnome.desktop.interface cursor-size "$cursor_size"

# Change shell to zsh
note "Changing default shell to zsh..."

if ! chsh -s "$(which zsh)"; then
    err "Failed to change shell"
fi

note "Shell changed successfully to zsh."
