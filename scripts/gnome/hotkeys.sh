#!/bin/bash

# Source library
. <(curl -sSL https://is.gd/nhattVim_lib)

note "Changing hotkeys."

# Diasble application hotkeys to avoid conflicts
gsettings set org.gnome.shell.keybindings switch-to-application-1 "@as []"
gsettings set org.gnome.shell.keybindings switch-to-application-2 "@as []"
gsettings set org.gnome.shell.keybindings switch-to-application-3 "@as []"
gsettings set org.gnome.shell.keybindings switch-to-application-4 "@as []"
gsettings set org.gnome.shell.keybindings switch-to-application-5 "@as []"
gsettings set org.gnome.shell.keybindings switch-to-application-6 "@as []"
gsettings set org.gnome.shell.keybindings switch-to-application-7 "@as []"
gsettings set org.gnome.shell.keybindings switch-to-application-8 "@as []"
gsettings set org.gnome.shell.keybindings switch-to-application-9 "@as []"
gsettings set org.gnome.shell.keybindings open-new-window-application-1 "@as []"
gsettings set org.gnome.shell.keybindings open-new-window-application-2 "@as []"
gsettings set org.gnome.shell.keybindings open-new-window-application-3 "@as []"
gsettings set org.gnome.shell.keybindings open-new-window-application-4 "@as []"
gsettings set org.gnome.shell.keybindings open-new-window-application-5 "@as []"
gsettings set org.gnome.shell.keybindings open-new-window-application-6 "@as []"
gsettings set org.gnome.shell.keybindings open-new-window-application-7 "@as []"
gsettings set org.gnome.shell.keybindings open-new-window-application-8 "@as []"
gsettings set org.gnome.shell.keybindings open-new-window-application-9 "@as []"
gsettings set org.gnome.desktop.wm.keybindings minimize "@as []"
gsettings set org.gnome.desktop.wm.keybindings show-desktop "@as []"
gsettings set org.gnome.settings-daemon.plugins.media-keys screensaver "@as []"

# General
gsettings set org.gnome.desktop.wm.keybindings close "['<Super>q']"
gsettings set org.gnome.desktop.wm.keybindings activate-window-menu "@as []"
gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "@as []"
gsettings set org.gnome.desktop.default-applications.terminal exec 'kitty'
gsettings set org.gnome.desktop.default-applications.terminal exec-arg ''
gsettings set org.gnome.desktop.wm.keybindings toggle-maximized "['<Super>M']"
gsettings set org.gnome.desktop.wm.keybindings toggle-fullscreen "['<Super><Shift>M', 'F11']"
gsettings set org.gnome.settings-daemon.plugins.media-keys terminal "['<Super>T']"
gsettings set org.gnome.settings-daemon.plugins.media-keys home "['<Super>F']"
gsettings set org.gnome.settings-daemon.plugins.media-keys www "['<Super>B']"
gsettings set org.gnome.shell.keybindings toggle-message-tray "['<Super>N']"

# Navigation
gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left "['<Super><Shift>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "['<Super>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['<Super>1']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-2 "['<Super>2']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-3 "['<Super>3']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-4 "['<Super>4']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-5 "['<Super>5']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-6 "['<Super>6']"

# Windows
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-left "['<Super><Control>H']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-right "['<Super><Control>L']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-1 "['<Super><Control>1']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-2 "['<Super><Control>2']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-3 "['<Super><Control>3']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-4 "['<Super><Control>4']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-5 "['<Super><Control>5']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-6 "['<Super><Control>6']"
