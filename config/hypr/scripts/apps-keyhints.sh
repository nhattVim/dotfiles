#!/bin/bash
# Keyhints - Idea from Garuda Hyprland

set -euo pipefail

# Get monitor info for focused monitor
monitor_info=$(hyprctl -j monitors | jq '.[] | select(.focused==true)')
x_mon=$(jq -r '.width' <<<"$monitor_info")
y_mon=$(jq -r '.height' <<<"$monitor_info")
hypr_scale=$(jq -r '.scale' <<<"$monitor_info")

# Configurable constants
max_width=1200
max_height=1000
percentage_width=70
percentage_height=70

# Calculate scaled resolution
scaled_width=$(awk "BEGIN {print $x_mon * $hypr_scale}")
scaled_height=$(awk "BEGIN {print $y_mon * $hypr_scale}")

# Calculate dynamic size
dynamic_width=$(awk -v sw="$scaled_width" -v pw="$percentage_width" \
    'BEGIN {print int(sw * pw / 100)}')
dynamic_height=$(awk -v sh="$scaled_height" -v ph="$percentage_height" \
    'BEGIN {print int(sh * ph / 100)}')

# Apply max limits
((dynamic_width > max_width)) && dynamic_width=$max_width
((dynamic_height > max_height)) && dynamic_height=$max_height

# Show keybindings
yad --width="$dynamic_width" --height="$dynamic_height" \
    --center \
    --title="Keybindings" \
    --no-buttons \
    --list \
    --column=Key: \
    --column=Description: \
    --column=Command: \
    --timeout-indicator=bottom \
    " = " "SUPER KEY (Windows Key)" "(SUPER KEY)" \
    " T" "terminal" "(kitty)" \
    " D" "app launcher" "(rofi)" \
    " E" "view keybinds, settings, monitor" "" \
    " R" "reload waybar swaync rofi" "CHECK NOTIFICATION FIRST!!!" \
    " F" "open file manager" "(thunar)" \
    " Q" "close active window" "(not kill)" \
    " V" "clipboard manager" "(cliphist)" \
    " W" "choose wallpaper" "(wallpaper Menu)" \
    " B" "hide / unhide waybar" "waybar" \
    " M" "fullscreen mode 0" "toggles to full screen mode 0" \
    " Shift M" "fullscreen mode 1" "toggles to full screen mode 1" \
    " Shift Q" "closes a specified window" "(window)" \
    " Shift W" "choose waybar styles" "(waybar styles)" \
    " Shift N" "launch notification panel" "swaync notification center" \
    " Shift Print" "screenshot region" "(grim + slurp)" \
    " Shift S" "screenshot region" "(swappy)" \
    " Shift F" "toggle float" "single window" \
    " Shift B" "toggle Blur" "normal or less blur" \
    " Shift G" "gamemode! All animations OFF or ON" "toggle" \
    " Print" "screenshot" "(grim)" \
    " Ctrl W" "choose waybar layout" "(waybar layout)" \
    " Alt F" "toggle all windows to float" "all windows" \
    " Escape" "power-menu" "(wlogout)" \
    "Alt Print" "Screenshot active window" "active window only" \
    "Ctrl Alt L" "screen lock" "(swaylock)" \
    "Ctrl Alt W" "random wallpaper" "(via swww)" \
    "Ctrl Alt Del" "hyprland exit" "SAVE YOUR WORK!!!" \
    "Ctrl Space" "toggle dwindle | master layout" "hyprland layout"
