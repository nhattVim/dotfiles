#!/bin/bash
set -euo pipefail

SHELL_FILE="$HOME/.cache/current_shell"

# Parse option
NO_WAYBAR=false
for arg in "$@"; do
    if [[ "$arg" == "--no-waybar" ]]; then
        NO_WAYBAR=true
    fi
done

# Only run on base shell
if [[ "$(cat "$SHELL_FILE")" == "caelestia" ]]; then
    exit 0
fi

# Kill processes
if [[ "$NO_WAYBAR" == false ]]; then
    pkill -x waybar 2>/dev/null || true
fi
pkill -x swaync 2>/dev/null || true
pkill -x ags 2>/dev/null || true
pkill -x swaybg 2>/dev/null || true

# Restart processes
if [[ "$NO_WAYBAR" == false ]]; then
    nohup waybar >/dev/null 2>&1 &
fi
nohup swaync >/dev/null 2>&1 &
nohup ags >/dev/null 2>&1 &

exit 0
