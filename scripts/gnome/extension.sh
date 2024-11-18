#!/bin/bash

RUNNING_GNOME=$([[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]] && echo true || echo false)

# script only run on GNOME
if $RUNNING_GNOME; then
    gsettings set org.gnome.desktop.screensaver lock-enabled false
    gsettings set org.gnome.desktop.session idle-delay 0
else
    echo "$(tput setaf 3)[NOTE]$(tput sgr0) This script is only available on Gnome, Exit."
    exit 1
fi
