#!/bin/bash

SHELL_FILE="$HOME/.cache/current_shell"
KEYBINDS_DIR="$HOME/.config/hypr/configs/keybinds"
KEYBINDS_LINK="$HOME/.config/hypr/configs/keybinds.conf"

WALL_DIR="$HOME/Pictures/Wallpapers"
SCRIPTS_DIR="$HOME/.config/hypr/scripts"

if [[ ! -f "$SHELL_FILE" ]]; then
    echo "base" >"$SHELL_FILE"
fi

CURRENT_SHELL=$(<"$SHELL_FILE")

if [[ "$CURRENT_SHELL" == "caelestia" ]]; then
    # Switch to base shell
    echo "base" >"$SHELL_FILE"
    ln -sf "$KEYBINDS_DIR/base.conf" "$KEYBINDS_LINK"
    hyprctl reload

    caelestia shell -k

    swww-daemon --format xrgb &
    sleep .5
    "$SCRIPTS_DIR/apps-wall-auto.sh" "$WALL_DIR" &
else
    # Switch to caelestia shell
    echo "caelestia" >"$SHELL_FILE"
    ln -sf "$KEYBINDS_DIR/shell.conf" "$KEYBINDS_LINK"
    hyprctl reload

    pgrep -f "apps-wall-auto.sh" >/dev/null && pkill -f "apps-wall-auto.sh"
    pidof "waybar" >/dev/null && pkill waybar
    pidof "swww-daemon" >/dev/null && pkill swww-daemon
    pidof "swaync" >/dev/null && pkill swaync

    caelestia shell -d >/dev/null &
fi
