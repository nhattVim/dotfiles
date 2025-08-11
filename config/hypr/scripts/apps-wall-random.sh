#!/bin/bash
# Script for Random Wallpaper (triggered by CTRL+ALT+W)

set -euo pipefail

wallDIR="$HOME/Pictures/Wallpapers"
SCRIPTSDIR="$HOME/.config/hypr/scripts"

# Get the name of the currently focused monitor
focused_monitor=$(hyprctl monitors | awk '
    /^Monitor/ { name=$2 }
    /focused: yes/ { print name; exit }
')

# Find image files with common extensions in wallpaper directory
mapfile -t PICS < <(find "$wallDIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \))

# Pick a random image
RANDOMPICS="${PICS[RANDOM % ${#PICS[@]}]}"

# Transition configuration for swww
FPS=30
TYPE="random"
DURATION=1
BEZIER=".43,1.19,1,.4"
SWWW_PARAMS="--transition-fps $FPS --transition-type $TYPE --transition-duration $DURATION --transition-bezier $BEZIER"

# Ensure swww daemon is running, then set wallpaper on focused monitor with transition
if ! swww query &>/dev/null; then
    swww-daemon --format xrgb &
    sleep 1
fi

swww img -o "$focused_monitor" "$RANDOMPICS" $SWWW_PARAMS

wait $!
"$SCRIPTSDIR/apps-wall-swww.sh"
wait $!
sleep 1
"$SCRIPTSDIR/hypr-refresh.sh"
