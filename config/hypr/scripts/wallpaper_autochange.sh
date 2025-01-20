#!/bin/bash
# source https://wiki.archlinux.org/title/Hyprland#Using_a_script_to_change_wallpaper_every_X_minutes

# This script will randomly go through the files of a directory, setting it
# up as the wallpaper at regular intervals
#
# NOTE: this script uses bash (not POSIX shell) for the RANDOM variable

wallust_refresh="$HOME/.config/hypr/scripts/refresh.sh"

if [[ $# -lt 1 ]] || [[ ! -d $1 ]]; then
    echo "Usage: $0 <dir containing images>"
    exit 1
fi

IMAGE_DIR="$1"

# Edit below to control the images transition
export SWWW_TRANSITION_FPS=60
export SWWW_TRANSITION_TYPE=simple

# This controls (in seconds) when to switch to the next image
INTERVAL=900

while true; do
    images=($(find "$IMAGE_DIR" -type f | shuf))

    if [[ ${#images[@]} -eq 0 ]]; then
        notify-send -e -u low -i "$notif" "No images found in $IMAGE_DIR"
        exit 1
    fi

    for img in "${images[@]}"; do
        focused_monitor=$(hyprctl monitors | awk '/^Monitor/{name=$2} /focused: yes/{print name}')
        swww img -o "$focused_monitor" "$img"
        "$wallust_refresh"
        sleep "$INTERVAL"
    done
done
