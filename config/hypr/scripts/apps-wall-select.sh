#!/bin/bash
# Wallpaper Selector Script (SUPER + W)

set -euo pipefail

wallDIR="$HOME/Pictures/Wallpapers"
SCRIPTSDIR="$HOME/.config/hypr/scripts"

FPS=60
TYPE="any" # alternatives: wipe, simple, etc.
DURATION=2
BEZIER=".43,1.19,1,.4" # (currently unused but can be added)
SWWW_PARAMS="--transition-fps $FPS --transition-type $TYPE --transition-duration $DURATION"

focused_monitor=$(hyprctl monitors | awk '/^Monitor/{name=$2} /focused: yes/{print name; exit}')

if pidof swaybg >/dev/null; then
    pkill swaybg
fi

mapfile -d '' PICS < <(find "$wallDIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) -print0)

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

if ! swww query &>/dev/null; then
    swww-daemon --format xrgb &
    sleep 1
fi

main() {
    choice=$(menu | $rofi_command)
    choice=$(echo "$choice" | xargs)

    if [[ -z $choice ]]; then
        echo "No choice selected. Exiting."
        exit 0
    fi

    if [[ "$choice" == "$RANDOM_PIC_NAME" ]]; then
        swww img -o "$focused_monitor" "$RANDOM_PIC" $SWWW_PARAMS
        sleep 2
        "$SCRIPTSDIR/apps-wall-swww.sh"
        sleep 0.5
        "$SCRIPTSDIR/hypr-refresh.sh"
        exit 0
    fi

    pic_index=-1
    for i in "${!PICS[@]}"; do
        filename=$(basename "${PICS[$i]}")
        if [[ "$filename" == "$choice"* ]]; then
            pic_index=$i
            break
        fi
    done

    if ((pic_index != -1)); then
        swww img -o "$focused_monitor" "${PICS[$pic_index]}" $SWWW_PARAMS
    else
        echo "Image not found."
        exit 1
    fi
}

if pidof rofi >/dev/null; then
    pkill rofi
fi

main

wait $!
"$SCRIPTSDIR/apps-wall-swww.sh"
wait $!
sleep 1
"$SCRIPTSDIR/hypr-refresh.sh"
