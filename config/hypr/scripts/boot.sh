#!/bin/bash
# Boot initialization script - runs only once after dotfiles are installed
# Safe to delete after first successful boot (marker in startup.lua will be commented)

# variables
wallpaper="$HOME/Pictures/Wallpapers/anime-night.jpg"
color_scheme="prefer-dark"
gtk_theme="adw-gtk3-dark"
icon_theme="Tokyonight-SE"
cursor_theme="Bibata-Modern-Ice"
cursor_size=24

sleep 2

# Apply theme
caelestia shell wallpaper set "$wallpaper"
caelestia scheme set -n dynamic
gsettings set org.gnome.desktop.interface color-scheme "$color_scheme"
gsettings set org.gnome.desktop.interface gtk-theme "$gtk_theme"
gsettings set org.gnome.desktop.interface icon-theme "$icon_theme"
gsettings set org.gnome.desktop.interface cursor-theme "$cursor_theme"
gsettings set org.gnome.desktop.interface cursor-size "$cursor_size"

sed -Ei '/boot\.sh/ {
    /^[[:space:]]*--/! s/^([[:space:]]*)/\1-- /
}' "$HOME/.config/hypr/configs/startup.lua"

sleep 2

notify-send "Boot script finished"
