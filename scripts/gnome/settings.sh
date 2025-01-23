#!/bin/bash
# Install packages

# Source library
. <(curl -sSL https://is.gd/nhattVim_lib)

note "Setting up Gnome."
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface cursor-theme "M200"
gsettings set org.gnome.desktop.interface icon-theme "Candy-icons"
gsettings set org.gnome.desktop.interface gtk-theme "(Modded) Catppuccin-Macchiato-Standard-Lavender-dark"

gsettings set org.gnome.desktop.background picture-uri "$HOME/Pictures/wallpapers/lady-light.png"
gsettings set org.gnome.desktop.background picture-uri-dark "$HOME/Pictures/wallpapers/anime-night.jpg"

gsettings set org.gnome.mutter dynamic-workspaces false
gsettings set org.gnome.desktop.wm.preferences num-workspaces 5
