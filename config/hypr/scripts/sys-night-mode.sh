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
    hyprctl hyprsunset temperature 3500
    hyprctl hyprsunset gamma 90
    echo "on" >"$STATE_FILE"
    notify-send -e -u low " 🌙 Night Mode: ON"
}

# Function to disable Night Mode
disable_night_mode() {
    hyprctl hyprsunset identity
    hyprctl hyprsunset gamma 100
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
