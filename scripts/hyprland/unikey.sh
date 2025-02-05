#!/bin/bash
# Script to install and setup Fcitx5 with Unikey support

# source library
. <(curl -sSL https://is.gd/nhattVim_lib)

pkgs=(
    fcitx5
    fcitx5-unikey
    fcitx5-gtk
    fcitx5-qt
    fcitx5-im
    fcitx5-configtool
)

# Install packages
note "Installing Fcitx5..."
for PKG in "${pkgs[@]}"; do
    iPac "$PKG"
done

# Setup Unikey
note "Setup Unikey (Vietnamese keyboard)..."
mkdir -p $HOME/.config/fcitx5
cat <<EOF | tee $HOME/.config/fcitx5/profile
[Groups/0]
# Group Name
Name=Default
# Layout
Default Layout=us
# Default Input Method
DefaultIM=unikey

[Groups/0/Items/0]
# Name
Name=keyboard-us
# Layout
Layout=

[Groups/0/Items/1]
# Name
Name=unikey
# Layout
Layout=

[GroupOrder]
0=Default
EOF

# Update Hotkey/TriggerKeys in Fcitx5 config to change the shortcut
note "Updating Fcitx5 Hotkey/TriggerKeys to Control + Left Shift"
cat <<EOF | tee $HOME/.config/fcitx5/config
[Hotkey/TriggerKeys]
0=Control+Shift+Shift_L
EOF

# Restart Fcitx5
note "Starting Fcitx5..."
fcitx5 -d >/dev/null 2>&1
