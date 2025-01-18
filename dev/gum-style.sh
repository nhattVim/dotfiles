#!/bin/bash

source <(curl -sSL https://is.gd/nhattVim_lib) && clear

gum style \
    --border-foreground 212 --border rounded \
    --align left --width 80 --margin "1 2" --padding "2 4" \
    "${CYAN}GREAT Copy Completed." "" \
    "${CYAN}YOU NEED to logout and re-login or reboot to avoid issues"
