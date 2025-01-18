#!/bin/bash
# Pipewire and Pipewire Audio Stuff #

# source library
source <(curl -sSL https://is.gd/nhattVim_lib)

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
    if [ $? -ne 0 ]; then
        err "$PKG uninstallation had failed"
    fi
done

# Disabling pulseaudio to avoid conflicts
note "Disabling pulseaudio if exits"
systemctl --user disable --now pulseaudio.socket pulseaudio.service

# Pipewire
note "Installing pipewire packages..."
for PIPEWIRE in "${install[@]}"; do
    iAur "$PIPEWIRE"
    [ $? -ne 0 ] && {
        err "$PIPEWIRE install had failed"
        exit 1
    }
done

note "Activating Pipewire Services..."
systemctl --user enable --now pipewire.socket pipewire-pulse.socket wireplumber.service
systemctl --user enable --now pipewire.service
