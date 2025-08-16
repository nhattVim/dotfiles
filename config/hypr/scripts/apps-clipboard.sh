#!/bin/bash
# Clipboard Manager using cliphist, rofi, and wl-copy.
# Keybinds:
#   Enter      = copy entry
#   Ctrl+Del   = delete entry
#   Alt+Del    = clear clipboard history
#   Esc        = thoát

ROFI_CONFIG="$HOME/.config/rofi/config-clipboard.rasi"
CLIPHIST_CACHE="$HOME/.cache/cliphist"

if pidof rofi >/dev/null; then
    pkill rofi
    exit 0
fi

while true; do
    selection=$(cliphist list | rofi -dmenu \
        -config "$ROFI_CONFIG" \
        -kb-custom-1 "Control-Delete" \
        -kb-custom-2 "Alt-Delete")

    rofi_exit=$?

    case $rofi_exit in
    1)
        exit 0
        ;;
    0)
        [[ -n $selection ]] && cliphist decode <<<"$selection" | wl-copy
        exit 0
        ;;
    10)
        [[ -n $selection ]] && cliphist delete <<<"$selection"
        ;;
    11)
        rm -rf "$CLIPHIST_CACHE"
        ;;
    *)
        exit 0
        ;;
    esac
done
