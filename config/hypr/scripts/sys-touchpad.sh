#!/bin/bash
# Toggle touchpad on Hyprland

notif="$HOME/.config/swaync/images/bell.png"
device_name="elan1203:00-04f3:307a-touchpad"
status_file="$XDG_RUNTIME_DIR/touchpad.status"

enable_touchpad() {
    echo "true" > "$status_file"
    notify-send -u low -i "$notif" "Enabling touchpad"
    hyprctl keyword "device[$device_name]:enabled" true
}

disable_touchpad() {
    echo "false" > "$status_file"
    notify-send -u low -i "$notif" "Disabling touchpad"
    hyprctl keyword "device[$device_name]:enabled" false
}

if [[ ! -f "$status_file" ]]; then
    enable_touchpad
else
    if [[ $(<"$status_file") == "true" ]]; then
        disable_touchpad
    else
        enable_touchpad
    fi
fi
