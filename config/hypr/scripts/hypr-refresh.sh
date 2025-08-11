#!/bin/bash
# Scripts for refreshing ags, waybar, rofi, swaync, wallust

SHELL_FILE="$HOME/.cache/current_shell"
SCRIPTSDIR="$HOME/.config/hypr/scripts"

# Only run on base shell
if [[ "$(cat "$SHELL_FILE")" == "caelestia" ]]; then
    exit 0
fi

# Kill already running processes
_ps=(waybar rofi swaync ags)
for _prs in "${_ps[@]}"; do
    if pidof "${_prs}" >/dev/null; then
        pkill "${_prs}"
    fi
done

# added since wallust sometimes not applying
killall -SIGUSR2 waybar
killall -SIGUSR2 swaync

# quit ags & relaunch ags
ags -q && ags &

# some process to kill
for pid in $(pidof waybar rofi swaync ags swaybg); do
    kill -SIGUSR1 "$pid"
done

#Restart waybar
sleep 1
waybar &

# relaunch swaync
sleep 0.5
swaync >/dev/null 2>&1 &

exit 0
