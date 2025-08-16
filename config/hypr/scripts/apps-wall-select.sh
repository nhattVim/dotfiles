#!/bin/bash
# Wallpaper Selector Script (SUPER + W)
# Support swww (base) and caelestia wallpaper (caelestia shell)

set -euo pipefail

WALL_DIR="$HOME/Pictures/Wallpapers"
SCRIPT_SDIR="$HOME/.config/hypr/scripts"
SHELL_FILE="$HOME/.cache/current_shell"

FPS=60
TYPE="any" # wipe, simple, etc.
DURATION=2
SWWW_PARAMS="--transition-fps $FPS --transition-type $TYPE --transition-duration $DURATION"

focused_monitor=$(hyprctl monitors | awk '/^Monitor/{name=$2} /focused: yes/{print name; exit}')

if pidof swaybg >/dev/null; then
    pkill swaybg
fi

mapfile -d '' PICS < <(find "$WALL_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) -print0)

RANDOM_PIC="${PICS[RANDOM % ${#PICS[@]}]}"
RANDOM_PIC_NAME=". random"

rofi_command="rofi -i -show -dmenu -config ~/.config/rofi/config-wallpaper.rasi"

menu() {
    IFS=$'\n' sorted_options=($(sort <<<"${PICS[*]}"))

    printf "%s\x00icon\x1f%s\n" "$RANDOM_PIC_NAME" "$RANDOM_PIC"

    for pic_path in "${sorted_options[@]}"; do
        pic_name=$(basename "$pic_path")
        if [[ ! "$pic_name" =~ \.gif$ ]]; then
            printf "%s\x00icon\x1f%s\n" "${pic_name%.*}" "$pic_path"
        else
            printf "%s\n" "$pic_name"
        fi
    done
}

# Get current shell
if [[ -f "$SHELL_FILE" ]]; then
    CURRENT_SHELL=$(<"$SHELL_FILE")
else
    CURRENT_SHELL="base"
fi

# If swww-daemon is not running, start it
if [[ "$CURRENT_SHELL" == "base" && ! $(swww query 2>/dev/null) ]]; then
    pkill swww-daemon 2>/dev/null || true
    swww-daemon --format xrgb &
    sleep 0.5
fi

main() {
    choice=$(menu | $rofi_command)
    choice=$(echo "$choice" | xargs)

    if [[ -z $choice ]]; then
        echo "No choice selected. Exiting."
        exit 0
    fi

    # Random
    if [[ "$choice" == "$RANDOM_PIC_NAME" ]]; then
        if [[ "$CURRENT_SHELL" == "base" ]]; then
            swww img -o "$focused_monitor" "$RANDOM_PIC" $SWWW_PARAMS
            sleep 1
            "$SCRIPT_SDIR/apps-wall-swww.sh"
            sleep 0.5
            "$SCRIPT_SDIR/hypr-refresh.sh"
        else
            caelestia wallpaper -f "$RANDOM_PIC"
        fi
        exit 0
    fi

    # Get the index of the selected image
    pic_index=-1
    for i in "${!PICS[@]}"; do
        filename=$(basename "${PICS[$i]}")
        if [[ "$filename" == "$choice"* ]]; then
            pic_index=$i
            break
        fi
    done

    # Set the wallpaper
    if ((pic_index != -1)); then
        if [[ "$CURRENT_SHELL" == "base" ]]; then
            swww img -o "$focused_monitor" "${PICS[$pic_index]}" $SWWW_PARAMS
            sleep 1
            "$SCRIPT_SDIR/apps-wall-swww.sh"
            sleep 0.5
            "$SCRIPT_SDIR/hypr-refresh.sh"
        else
            caelestia wallpaper -f "${PICS[$pic_index]}"
        fi
    else
        echo "Image not found."
        exit 1
    fi
}

if pidof rofi >/dev/null; then
    pkill rofi
    exit 0
fi

main
