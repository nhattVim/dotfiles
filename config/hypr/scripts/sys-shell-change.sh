#!/bin/bash

SHELL_FILE="$HOME/.cache/current_shell"
KEYBINDS_DIR="$HOME/.config/hypr/configs/keybinds"
KEYBINDS_LINK="$HOME/.config/hypr/configs/keybinds.conf"
WALL_DIR="$HOME/Pictures/Wallpapers"
SCRIPTS_DIR="$HOME/.config/hypr/scripts"

CURRENT_SHELL=$(cat "$SHELL_FILE" 2>/dev/null || echo "base")

if [[ "$CURRENT_SHELL" == "caelestia" ]]; then
    # Switch to base shell
    echo "base" >"$SHELL_FILE"
    ln -sf "$KEYBINDS_DIR/base.conf" "$KEYBINDS_LINK"
    hyprctl reload

    caelestia shell -k

    swww-daemon --format argb &
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
    sleep .5
    current_wall=$(caelestia shell wallpaper get)

    if [[ -z "$current_wall" ]]; then
        caelestia wallpaper -r -N
        current_wall=$(caelestia shell wallpaper get)
    fi

    ln -sf "$current_wall" $HOME/.cache/swww/.current_wallpaper
    wallust run "$current_wall" -s &
fi
