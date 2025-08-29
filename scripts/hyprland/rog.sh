#!/bin/bash
# Asus ROG Laptops #

# Source library
. <(curl -sSL https://raw.githubusercontent.com/nhattVim/dotfiles/refs/heads/master/scripts/lib.sh)

# Packages
pkgs=(
    asusctl
    power-profiles-daemon
    supergfxctl
    switcheroo-control
    rog-control-center
    # linux-g14
    # linux-g14-headers
)

# Rog keys
ASUS_KEY="8F654886F17D497FEFE3DB448B15A6B0E9A3FA35"
ASUS_REPO="[g14]"
ASUS_REPO_CONF=$'Server = https://arch.asus-linux.org'

# Add ASUS GPG key if not exists
note "Checking ASUS GPG key..."
if ! pacman-key --list-keys "$ASUS_KEY" &>/dev/null; then
    act "Importing ASUS key..."
    sudo pacman-key --recv-keys "$ASUS_KEY" &&
        sudo pacman-key --finger "$ASUS_KEY" &&
        sudo pacman-key --lsign-key "$ASUS_KEY" &&
        ok "ASUS key added & signed"
else
    note "ASUS GPG key already exists."
fi

# Add G14 repository if not exists
if ! grep -q "^\[g14\]" /etc/pacman.conf; then
    note "Adding G14 repository..."
    echo -e "\n$ASUS_REPO\n$ASUS_REPO_CONF" | sudo tee -a /etc/pacman.conf
else
    note "G14 repository already exists."
fi

# Update package database
sudo pacman -Sy

# Install ASUS ROG packages
note "Installing ASUS ROG packages ..."
for pkg in "${pkgs[@]}"; do
    iPac "$pkg"
done

# Enable ROG services
note "Activating ROG services..."
enable_service "supergfxd.service"
enable_service "switcheroo-control.service"
enable_service "power-profiles-daemon.service"

# ------------------------------------------------------------------------------
# Optional: Set GRUB default to linux-g14 (if installed)
# ------------------------------------------------------------------------------
# if grep -q "Arch Linux, with Linux linux-g14" /boot/grub/grub.cfg; then
#     sudo sed -i 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT="Arch Linux, with Linux linux-g14"/' /etc/default/grub
#     sudo grub-mkconfig -o /boot/grub/grub.cfg
#     ok "GRUB is set to boot linux-g14 by default."
# else
#     note "linux-g14 entry not found in GRUB. Skipping..."
# fi
