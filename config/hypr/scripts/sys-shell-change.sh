#!/bin/bash

SHELL_FILE="$HOME/.cache/current_shell"
KEYBINDS_DIR="$HOME/.config/hypr/configs/keybinds"
KEYBINDS_LINK="$HOME/.config/hypr/configs/keybinds.conf"
NOTIF="$HOME/.config/swaync/images/bell.png"

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
    "$SCRIPTS_DIR/apps-wall-auto.sh" "$WALL_DIR" &

    notify-send -e -u low -i "$NOTIF" "Shell: Base"
else
    # Switch to caelestia shell
    echo "caelestia" >"$SHELL_FILE"
    ln -sf "$KEYBINDS_DIR/shell.conf" "$KEYBINDS_LINK"
    hyprctl reload

    if pgrep -f "apps-wall-auto.sh" >/dev/null; then
        pkill -f "apps-wall-auto.sh"
    fi

    if pidof "waybar" >/dev/null; then
        pkill waybar
    fi

    if pidof "swww-daemon" >/dev/null; then
        pkill swww-daemon
    fi

    if pidof "swaync" >/dev/null; then
        pkill swaync
    fi

    caelestia shell -d >/dev/null &

    notify-send -e -u low -i "$NOTIF" "Shell: Caelestia"
fi
