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
gsettings set org.gnome.desktop.wm.preferences resize-with-right-button true
gsettings set org.gnome.desktop.wm.preferences button-layout "menu:minimize,maximize,close"
gsettings set org.gnome.shell favorite-apps "@as []"

gsettings set org.gnome.desktop.default-applications.terminal exec 'kitty'
gsettings set org.gnome.desktop.default-applications.terminal exec-arg ''

# gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Control><Shift>b', 'XF86Keyboard']"
# gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "['<Shift><Control>', '<Shift>XF86Keyboard']"
#
# gsettings get org.gnome.desktop.wm.keybindings switch-input-source
# gsettings reset org.gnome.desktop.wm.keybindings switch-input-source
#
# gsettings get org.gnome.desktop.wm.keybindings switch-input-source-backward
# gsettings reset org.gnome.desktop.wm.keybindings switch-input-source-backward
#
# gsettings set org.freedesktop.ibus.general.hotkey triggers "['<Control><Shift>']"
# # gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "['<Shift><Alt>']"
