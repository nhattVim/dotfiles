#!/bin/bash
# Script to install and setup Fcitx5 with Unikey support

# source library
. <(curl -sSL https://nhattVim.github.io/lib.sh)

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

# Fcitx5 config directory
CONFIG_DIR="$HOME/.config/fcitx5"

# Setup Unikey
note "Setup Unikey (Vietnamese keyboard)..."
mkdir -p "$CONFIG_DIR"

cat <<EOF | tee "$CONFIG_DIR/profile"
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

# Update Hotkey/TriggerKeys in Fcitx5 config
act "Updating Fcitx5 Hotkey/TriggerKeys to Control + Left Shift"
{
    echo "[Hotkey/TriggerKeys]"
    echo "0=Control+Shift+Shift_L"
} | tee -a "$CONFIG_DIR/config"

# Check if Fcitx5 is running
if pgrep -x "fcitx5" >/dev/null; then
    note "Fcitx5 is running. Stopping it first..."
    pkill fcitx5
    # Wait for the process to actually stop
    while pgrep -x "fcitx5" >/dev/null; do sleep 0.5; done
fi

# Restart Fcitx5
note "Starting Fcitx5..."
fcitx5 -d >/dev/null 2>&1 &
disown

# Check if Fcitx5 is running
sleep 2
if ! pgrep -x "fcitx5" >/dev/null; then
    err "Failed to start Fcitx5! Try running 'fcitx5 -d' manually."
    exit 1
fi

ok "Fcitx5 is now running!"
