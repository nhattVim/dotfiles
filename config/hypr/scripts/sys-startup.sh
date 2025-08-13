#!/bin/bash

KEYBINDS_DIR="$HOME/.config/hypr/configs/keybinds"
KEYBINDS_LINK="$HOME/.config/hypr/configs/keybinds.conf"
SHELL_FILE="$HOME/.cache/current_shell"
SCRIPTS_DIR="$HOME/.config/hypr/scripts"
WALL_DIR="$HOME/Pictures/Wallpapers"

CURRENT_SHELL=$(cat "$SHELL_FILE" 2>/dev/null || echo "base")

case "$CURRENT_SHELL" in
base)
    ln -sf "$KEYBINDS_DIR/base.conf" "$KEYBINDS_LINK"
    hyprctl reload

    # Start waybar / swaync if not running
    pgrep -x "waybar" >/dev/null || waybar &
    pgrep -x "swaync" >/dev/null || swaync &

    # Wallpaper daemon
    swww-daemon --format xrgb &
    sleep .5
    "$SCRIPTS_DIR/apps-wall-auto.sh" "$WALL_DIR" &

    exit 0
    ;;
caelestia)
    ln -sf "$KEYBINDS_DIR/shell.conf" "$KEYBINDS_LINK"

    caelestia shell -d >/dev/null &
    hyprctl reload

    exit 0
    ;;
esac
