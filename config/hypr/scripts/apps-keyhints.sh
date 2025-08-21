#!/bin/bash
# Keyhints

set -euo pipefail

# Config
KEYHINTS_HELPER="$HOME/.config/hypr/scripts/apps-keyhints.py"
ROFI_THEME="
entry { placeholder: '⌨️ Keybindings'; }
window { width: 70em; height: 40em; border-radius: 10px; }
listview { lines: 20; columns: 2; }
"

# Exit if rofi already running
pidof rofi >/dev/null && {
    pkill rofi
    exit 0
}

# Get all binds once
binds_all="$(python3 "$KEYHINTS_HELPER")"

# Show keybinds in rofi
selected=$(
    printf '%s\n' "$binds_all" |
        awk -F $'\t' '{print $1}' |
        rofi -dmenu -i -p "Keybinds" -theme-str "$ROFI_THEME"
)
[ -z "$selected" ] && exit 0

# Find matching bind line
line="$(printf '%s\n' "$binds_all" | grep -F -- "$selected" | head -n1)"
[ -z "$line" ] && {
    echo "No match" >&2
    exit 1
}

# Parse columns
IFS=$'\t' read -r display dispatcher arg repeat <<<"$line"
dispatcher="${dispatcher#"${dispatcher%%[![:space:]]*}"}"
arg="${arg#"${arg%%[![:space:]]*}"}"
repeat="${repeat#"${repeat%%[![:space:]]*}"}"

# Run dispatcher helper
run_dispatch() {
    if [[ "${dispatcher,,}" == "exec" ]]; then
        hyprctl dispatch "$dispatcher" "${arg}"
    else
        # split args safely
        read -r -a parts <<<"$arg"
        hyprctl dispatch "$dispatcher" "${parts[@]}"
    fi
}

# Execute (handle repeat)
if [[ "${repeat,,}" == "true" ]]; then
    choice="Repeat"
    while [[ "$choice" == "Repeat" ]]; do
        run_dispatch
        choice=$(echo -e "Repeat\nExit" | rofi -dmenu -i -p "Repeat?" \
            -theme-str "entry { placeholder: '${dispatcher} ${arg}'; }")
    done
else
    run_dispatch
fi
