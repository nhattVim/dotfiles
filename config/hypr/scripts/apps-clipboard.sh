#!/bin/bash
# Clipboard Manager using cliphist, rofi, and wl-copy.
# Keybinds: Ctrl+Del = delete entry, Alt+Del = clear clipboard history.

ROFI_CONFIG="$HOME/.config/rofi/config-clipboard.rasi"
CLIPHIST_CACHE="$HOME/.cache/cliphist"

# Kill existing rofi if running
pkill -x rofi 2>/dev/null || true

show_menu() {
    cliphist list | rofi -dmenu \
        -config "$ROFI_CONFIG" \
        -kb-custom-1 "Control-Delete" \
        -kb-custom-2 "Alt-Delete"
}

while true; do
    selection=$(show_menu)
    rofi_exit=$?

    case $rofi_exit in
    1) exit ;;
    0)
        [[ -n $selection ]] && cliphist decode <<<"$selection" | wl-copy
        exit
        ;;
    10) cliphist delete <<<"$selection" ;;
    11) rm -rf "$CLIPHIST_CACHE" ;;
    esac
done
