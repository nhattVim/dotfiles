#!/bin/bash
# Script for Random Wallpaper (triggered by CTRL+ALT+W)

SHELL_FILE="$HOME/.cache/current_shell"
CURRENT_SHELL=$(<"$SHELL_FILE")

# === Caelestia ===
if [[ "$CURRENT_SHELL" == "caelestia" ]]; then
    caelestia wallpaper -r -N
    current_wall=$(caelestia shell wallpaper get)
    ln -sf "$current_wall" "$HOME/.cache/swww/.current_wallpaper"
    wallust run "$current_wall" -s &
    exit 0
fi

# === Base ===
wallDIR="$HOME/Pictures/Wallpapers"
SCRIPTSDIR="$HOME/.config/hypr/scripts"

# Get focused monitor
focused_monitor=$(hyprctl monitors | awk '/^Monitor/ { name=$2 } /focused: yes/ { print name; exit }')

# Collect image files
mapfile -t PICS < <(find "$wallDIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \))
((${#PICS[@]})) || exit 1

# Pick random image
RANDOMPICS="${PICS[RANDOM % ${#PICS[@]}]}"

# Transition config
SWWW_PARAMS=(
    --transition-fps 30
    --transition-type random
    --transition-duration 1
    --transition-bezier .43,1.19,1,.4
)

# Ensure daemon running
swww query &>/dev/null || {
    swww-daemon --format xrgb &
    sleep 1
}

# Set wallpaper
swww img -o "$focused_monitor" "$RANDOMPICS" "${SWWW_PARAMS[@]}"

# Run extra scripts
"$SCRIPTSDIR/apps-wall-swww.sh"
sleep .5
"$SCRIPTSDIR/hypr-refresh.sh"
