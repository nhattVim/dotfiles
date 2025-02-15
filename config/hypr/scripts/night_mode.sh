#!/bin/bash

# Path to save the state
STATE_FILE="$HOME/.cache/.nightmode_state"
notif="$HOME/.config/swaync/images/bell.png"

# Function to get latitude and longitude
get_location() {
    location=$(curl -s https://ipinfo.io/loc)
    latitude=$(echo "$location" | cut -d',' -f1)
    longitude=$(echo "$location" | cut -d',' -f2)
}

# Function to enable Night Mode
enable_night_mode() {
    gammastep -O 3500 &
    echo "on" >"$STATE_FILE"
    notify-send -e -u low -i "$notif" "Night Mode: ON"
}

# Function to disable Night Mode
disable_night_mode() {
    pkill gammastep
    echo "off" >"$STATE_FILE"
    notify-send -e -u low -i "$notif" "Night Mode: OFF"
}

# Function for automatic mode with geolocation
auto_mode() {
    pkill gammastep
    get_location
    gammastep -l "$latitude:$longitude" -m wayland &
    echo "auto" >"$STATE_FILE"
}

# Function to toggle Night Mode
toggle_mode() {
    if [[ "$STATE" == "on" ]]; then
        disable_night_mode
    else
        enable_night_mode
    fi
}

# Read current state
if [[ -f "$STATE_FILE" ]]; then
    STATE=$(cat "$STATE_FILE")
else
    STATE="auto"
fi

# Handle input arguments
case "$1" in
--on)
    enable_night_mode
    ;;
--off)
    disable_night_mode
    ;;
--auto)
    auto_mode
    ;;
--toggle)
    toggle_mode
    ;;
*)
    echo "Usage: $0 {--on|--off|--auto|--toggle}"
    echo "Current state: $STATE"
    ;;
esac
