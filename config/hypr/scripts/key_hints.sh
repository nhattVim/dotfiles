#!/bin/bash
# Keyhints. Idea got from Garuda Hyprland

# Detect monitor resolution and scale
x_mon=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .width')
y_mon=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .height')
hypr_scale=$(hyprctl -j monitors | jq '.[] | select (.focused == true) | .scale' | sed 's/\.//')

# Calculate width and height based on percentages and monitor resolution
width=$((x_mon * hypr_scale / 100))
height=$((y_mon * hypr_scale / 100))

# Set maximum width and height
max_width=1200
max_height=1000

# Set percentage of screen size for dynamic adjustment
percentage_width=70
percentage_height=70

# Calculate dynamic width and height
dynamic_width=$((width * percentage_width / 100))
dynamic_height=$((height * percentage_height / 100))

# Limit width and height to maximum values
dynamic_width=$(($dynamic_width > $max_width ? $max_width : $dynamic_width))
dynamic_height=$(($dynamic_height > $max_height ? $max_height : $dynamic_height))

# Launch yad with calculated width and height
yad --width=$dynamic_width --height=$dynamic_height \
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
" Shift Q " "closes a specified window" "(window)" \
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
"Ctrl Space" "toggle dwindle | master layout" "hyprland layout" \
