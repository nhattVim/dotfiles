#!/bin/bash
# Wallpaper Selector Script (SUPER + W)
# Supports swww (base) and caelestia shell

set -euo pipefail

WALL_DIR="$HOME/Pictures/Wallpapers"
SCRIPT_SDIR="$HOME/.config/hypr/scripts"
SHELL_FILE="$HOME/.cache/current_shell"

FPS=60
TYPE="any"
DURATION=2
SWWW_PARAMS="--transition-fps $FPS --transition-type $TYPE --transition-duration $DURATION"

# Get focused monitor
focused_monitor=$(hyprctl monitors | awk '/^Monitor/{name=$2} /focused: yes/{print name; exit}')

# Kill swaybg if running
pkill swaybg 2>/dev/null || true

# Collect pictures
shopt -s nullglob
PICS=("$WALL_DIR"/*.{jpg,jpeg,png,gif})
shopt -u nullglob
((${#PICS[@]} == 0)) && {
    echo "No wallpapers found in $WALL_DIR"
    exit 1
}

RANDOM_PIC="${PICS[RANDOM % ${#PICS[@]}]}"
RANDOM_PIC_NAME=". random"

# Rofi config
rofi_command="rofi -i -dmenu -config ~/.config/rofi/config-wallpaper.rasi"

# Menu generator
menu() {
    printf "%s\x00icon\x1f%s\n" "$RANDOM_PIC_NAME" "$RANDOM_PIC"
    for pic_path in "${PICS[@]}"; do
        pic_name=$(basename "$pic_path")
        if [[ $pic_name == *.gif ]]; then
            printf "%s\n" "$pic_name"
        else
            printf "%s\x00icon\x1f%s\n" "${pic_name%.*}" "$pic_path"
        fi
    done | sort
}

# Detect shell
CURRENT_SHELL=$(<"$SHELL_FILE")

# Ensure swww-daemon for base
if [[ $CURRENT_SHELL == "base" ]] && ! swww query &>/dev/null; then
    pkill swww-daemon 2>/dev/null || true
    swww-daemon --format xrgb &
    sleep 0.5
fi

# Apply wallpaper depending on shell
set_wallpaper() {
    local img="$1"
    if [[ $CURRENT_SHELL == "base" ]]; then
        swww img -o "$focused_monitor" "$img" $SWWW_PARAMS
        sleep 0.5
        "$SCRIPT_SDIR/apps-wall-swww.sh"
        "$SCRIPT_SDIR/hypr-refresh.sh"
    elif [[ $CURRENT_SHELL == "caelestia" ]]; then
        ln -sf "$img" "$HOME/.cache/swww/.current_wallpaper"
        wallust run "$img" -s &
        caelestia wallpaper -f "$img"
    else
        echo "Unknown shell: $CURRENT_SHELL"
        exit 1
    fi
}

main() {
    choice=$(menu | $rofi_command)
    [[ -z $choice ]] && exit 0

    if [[ $choice == "$RANDOM_PIC_NAME" ]]; then
        set_wallpaper "$RANDOM_PIC"
        exit 0
    fi

    for pic in "${PICS[@]}"; do
        if [[ $(basename "$pic") == "$choice"* ]]; then
            set_wallpaper "$pic"
            exit 0
        fi
    done

    echo "Image not found." >&2
    exit 1
}

# If rofi is running, kill it
if pidof rofi >/dev/null; then
    pkill rofi
    exit 0
fi

main
