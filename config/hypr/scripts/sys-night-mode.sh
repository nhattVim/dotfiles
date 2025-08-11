#!/bin/bash

# Path to save the state
STATE_FILE="$HOME/.cache/.nightmode_state"
notif="$HOME/.config/swaync/images/bell.png"

# Ensure state file exists
if [[ ! -f "$STATE_FILE" ]]; then
    echo "off" >"$STATE_FILE"
fi

# Read current state
STATE=$(cat "$STATE_FILE")

# Function to enable Night Mode
enable_night_mode() {
    pkill -x gammastep
    gammastep -O 4000 -m wayland &
    echo "on" >"$STATE_FILE"
    notify-send -e -u low " 🌙 Night Mode: ON"
}

# Function to disable Night Mode
disable_night_mode() {
    pkill -x gammastep
    echo "off" >"$STATE_FILE"
    notify-send -e -u low " 🌞 Night Mode: OFF"
}

# Function to toggle Night Mode
toggle_mode() {
    if [[ "$STATE" == "on" ]]; then
        disable_night_mode
    else
        enable_night_mode
    fi
}

# Check and enable Night Mode on startup
if [[ "$1" == "--startup" && "$STATE" == "on" ]]; then
    enable_night_mode
    exit 0
fi

# Handle input arguments
case "$1" in
--on) enable_night_mode ;;
--off) disable_night_mode ;;
--toggle) toggle_mode ;;
*)
    echo "Usage: $0 {--on|--off|--toggle}"
    echo "Current state: $STATE"
    ;;
esac
