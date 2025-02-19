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
    pkill gammastep
    gammastep -O 3500 -m wayland &
    echo "on" >"$STATE_FILE"
    notify-send -e -u low " 🌙 Night Mode: ON"
}

# Function to disable Night Mode
disable_night_mode() {
    if pgrep -x "gammastep" &>/dev/null; then
        pkill gammastep
        wait $!
        echo "off" >"$STATE_FILE"
        notify-send -e -u low " 🌞 Night Mode: OFF"
    fi
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
