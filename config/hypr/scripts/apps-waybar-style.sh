#!/bin/bash
# Script for waybar styles

set -euo pipefail
IFS=$'\n\t'

waybar_styles="$HOME/.config/waybar/style"
waybar_style="$HOME/.config/waybar/style.css"
script_dir="$HOME/.config/hypr/scripts"
rofi_config="$HOME/.config/rofi/config-waybar-style.rasi"

menu() {
    options=()
    while IFS= read -r file; do
        if [ -f "$waybar_styles/$file" ]; then
            options+=("$(basename "$file" .css)")
        fi
    done < <(find "$waybar_styles" -maxdepth 1 -type f -name '*.css' -exec basename {} \; | sort)

    printf '%s\n' "${options[@]}"
}

apply_style() {
    ln -sf "$waybar_styles/$1.css" "$waybar_style"
    "${script_dir}/hypr-refresh.sh" &
}

main() {
    choice=$(menu | rofi -i -dmenu -config "$rofi_config")

    if [[ -z "$choice" ]]; then
        echo "No option selected. Exiting."
        exit 0
    fi

    apply_style "$choice"
}

if pgrep -x "rofi" >/dev/null; then
    pkill rofi
fi

main
