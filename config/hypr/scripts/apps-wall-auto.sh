#!/bin/bash
# Script to randomly change wallpaper from a directory at regular intervals
# Source: https://wiki.archlinux.org/title/Hyprland#Using_a_script_to_change_wallpaper_every_X_minutes

set -euo pipefail

SCRIPTSDIR="$HOME/.config/hypr/scripts"

# Get the focused monitor name
focused_monitor=$(hyprctl monitors | awk '
    /^Monitor/ { name=$2 }
    /focused: yes/ { print name; exit }
')

# Check if directory argument is provided and is valid
if [[ $# -lt 1 || ! -d $1 ]]; then
    echo "Usage: $0 <dir containing images>"
    exit 1
fi

IMAGE_DIR="$1"

# Configure wallpaper transition settings
export SWWW_TRANSITION_FPS=60
export SWWW_TRANSITION_TYPE=simple

# Interval between wallpaper changes in seconds
INTERVAL=900

while true; do
    # Find image files, shuffle them randomly
    mapfile -t images < <(find "$IMAGE_DIR" -type f | shuf)

    for img in "${images[@]}"; do
        swww img -o "$focused_monitor" "$img"
        "$SCRIPTSDIR/apps-wall-swww.sh"
        "$SCRIPTSDIR/hypr-refresh.sh"
        sleep "$INTERVAL"
    done
done
