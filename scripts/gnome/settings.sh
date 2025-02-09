#!/bin/bash
# Install packages

# Source library
. <(curl -sSL https://is.gd/nhattVim_lib)
. <(curl -sSL https://raw.githubusercontent.com/nhattVim/dotfiles/master/scripts/lib.sh)

note "Setting up Gnome."
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface cursor-theme "M200"
gsettings set org.gnome.desktop.interface icon-theme "Candy-icons"
gsettings set org.gnome.desktop.interface gtk-theme "(Modded) Catppuccin-Macchiato-Standard-Lavender-dark"

gsettings set org.gnome.desktop.background picture-uri "$HOME/Pictures/wallpapers/lady-light.png"
gsettings set org.gnome.desktop.background picture-uri-dark "$HOME/Pictures/wallpapers/anime-night.jpg"

gsettings set org.gnome.mutter dynamic-workspaces false
gsettings set org.gnome.desktop.wm.preferences num-workspaces 5
gsettings set org.gnome.desktop.wm.preferences resize-with-right-button true
gsettings set org.gnome.desktop.wm.preferences button-layout "menu:minimize,maximize,close"
gsettings set org.gnome.shell favorite-apps "@as []"

gsettings set org.gnome.desktop.default-applications.terminal exec 'kitty'
gsettings set org.gnome.desktop.default-applications.terminal exec-arg ''

gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('ibus', 'Unikey')]"

gsettings set org.gnome.login-screen banner-message-enable true
gsettings set org.gnome.login-screen banner-message-text "Welcome to nhattVim's Linux Setup"
