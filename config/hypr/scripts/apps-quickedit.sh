#!/bin/bash
# Rofi menu for Quick Edit / View of Settings (SUPER E)

set -euo pipefail

configs="$HOME/.config/hypr/configs"

declare -A files=(
    ["view envs"]="envs.conf"
    ["view rules"]="rules.conf"
    ["view execs"]="execs.conf"
    ["view monitors"]="monitors.conf"
    ["view keybinds"]="keybinds.conf"
    ["view laptops"]="laptop.conf"
    ["view settings"]="settings.conf"
)

choice=$(printf '%s\n' "${!files[@]}" | sort | rofi -dmenu -config ~/.config/rofi/config-compact.rasi)

if [[ -n "$choice" && -f "$configs/${files[$choice]}" ]]; then
    kitty -e nvim "$configs/${files[$choice]}"
fi
