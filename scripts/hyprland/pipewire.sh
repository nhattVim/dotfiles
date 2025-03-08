#!/bin/bash
# Pipewire and Pipewire Audio Stuff #

# source library
. <(curl -sSL https://raw.githubusercontent.com/nhattVim/dotfiles/refs/heads/master/scripts/lib.sh)

# start
install=(
    pipewire
    wireplumber
    pipewire-audio
    pipewire-alsa
    pipewire-pulse
)

uninstall=(
    pulseaudio
    pulseaudio-alsa
    pulseaudio-bluetooth
)

# Removal of pulseaudio
note "Removing pulseaudio stuff... if exist"
for PKG in "${uninstall[@]}"; do
    uPac "$PKG"
done

# Disabling pulseaudio to avoid conflicts
note "Disabling pulseaudio if exits"
if systemctl --user is-active --quiet pulseaudio.service; then
    systemctl --user disable --now pulseaudio.socket pulseaudio.service
    note "Pulseaudio has been disabled"
else
    note "Pulseaudio is not running, skipping disable."
fi

# Pipewire
note "Installing pipewire packages..."
for PIPEWIRE in "${install[@]}"; do
    iAur "$PIPEWIRE"
    if [ $? -ne 0 ]; then
        exit 1
    fi
done

# Enable and start Pipewire services
note "Enabling and starting Pipewire services..."
systemctl --user enable --now pipewire.socket pipewire-pulse.socket wireplumber.service
systemctl --user enable --now pipewire.service
note "Pipewire services have been activated"
