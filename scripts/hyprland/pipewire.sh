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
disable_service --user pulseaudio.socket
disable_service --user pulseaudio.service

# Pipewire
note "Installing pipewire packages..."
for PIPEWIRE in "${install[@]}"; do
    iAur "$PIPEWIRE"
done

# Enable and start Pipewire services
note "Enabling and starting Pipewire services..."
enable_service --user pipewire.socket pipewire-pulse.socket wireplumber.service
enable_service --user pipewire.socket pipewire.service
note "Pipewire services have been activated"
