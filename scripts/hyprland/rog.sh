#!/bin/bash
# Asus ROG Laptops #

# Source library
. <(curl -sSL https://is.gd/nhattVim_lib)

pkgs=(
    asusctl
    power-profiles-daemon
    supergfxctl
    switcheroo-control
    rog-control-center
    # linux-g14
    # linux-g14-headers
)

# Add ASUS GPG key
declare -a key_cmds=(
    "--recv-keys 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35"
    "--finger 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35"
    "--lsign-key 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35"
    "--finger 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35"
)

# Add ASUS GPG key
note "Adding ASUS GPG key..."
for cmd in "${key_cmds[@]}"; do
    if sudo pacman-key $cmd; then
        ok "Executed: pacman-key $cmd"
        sleep 1
    else
        err "Failed: pacman-key $cmd"
        exit 1
    fi
done

# Add G14 repository
if ! grep -q "\[g14\]" /etc/pacman.conf; then
    note "Adding G14 repository..."
    echo -e "\n[g14]\nServer = https://arch.asus-linux.org" | sudo tee -a /etc/pacman.conf
else
    note "G14 repository already exists."
fi

# Update package database
sudo pacman -Sy

# Install ASUS ROG packages
note "Installing ASUS ROG packages ...\n"
for pkg in "${pkgs[@]}"; do
    iPac "$pkg"
done

# Enable ROG services
note "Activating ROG services..."
sudo systemctl enable --now supergfxd
sudo systemctl enable --now switcheroo-control

# Enable power-profiles-daemon
note "Enabling power-profiles-daemon..."
sudo systemctl enable --now power-profiles-daemon.service

# Set GRUB default to linux-g14
# note "Setting linux-g14 as default kernel in GRUB..."

# Check if the entry exists in grub.cfg
# if grep -q "Arch Linux, with Linux linux-g14" /boot/grub/grub.cfg; then
#     sudo sed -i 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT="Arch Linux, with Linux linux-g14"/' /etc/default/grub
#     sudo grub-mkconfig -o /boot/grub/grub.cfg
#     ok "GRUB is set to boot linux-g14 by default."
# else
#     err "linux-g14 entry not found in GRUB. Check installation."
# fi
