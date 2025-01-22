#!/bin/bash
# Install packages

# Source library
. <(curl -sSL https://is.gd/nhattVim_lib)

note "Setting up Gnome."
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface cursor-theme "M200"
# gsettings set org.gnome.desktop.interface gtk-theme ""
gsettings set org.gnome.desktop.interface gtk-theme "(Modded) Catppuccin-Mocha-Standard-Mauve-Dark"
gsettings set org.gnome.desktop.interface icon-theme "Candy-icons"
gsettings set org.gnome.shell.extensions.user-theme name "(Modded) Catppuccin-Mocha-Standard-Mauve-Dark"

note "Downloading additional wallpapers..."
if git clone https://github.com/nhattVim/wallpapers --depth 1; then
    note "Wallpapers downloaded successfully."

    mkdir -p $HOME/Pictures/wallpapers
    if cp -R wallpapers/wallpapers/* $HOME/Pictures/wallpapers/; then
        note "Wallpapers copied successfully."
        rm -rf wallpapers
        break
    else
        err "Copying wallpapers failed."
    fi
else
    err "Downloading additional wallpapers failed"
fi

gsettings set org.gnome.desktop.background picture-uri "$HOME/Pictures/wallpapers/lady-light.png"
gsettings set org.gnome.desktop.background picture-uri-dark "$HOME/Pictures/wallpapers/anime-night.jpg"
