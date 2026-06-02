#!/bin/bash
# Enhancing pacman with extra features

# Source the library
. <(curl -sSL https://raw.githubusercontent.com/nhattVim/dotfiles/refs/heads/master/scripts/lib.sh)

# Start script
echo "$CYAN"
echo "  ____   __ __   ____  ______      ______  ____   __ __   ___   ____    ____"
echo " |    \ |  |  | /    ||      |    |      ||    \ |  |  | /   \ |    \  /    |      "
echo " |  _  ||  |  ||  o  ||      |    |      ||  D  )|  |  ||     ||  _  ||   __|      "
echo " |  |  ||  _  ||     ||_|  |_|    |_|  |_||    / |  |  ||  O  ||  |  ||  |  |      "
echo " |  |  ||  |  ||  _  |  |  |        |  |  |    \ |  :  ||     ||  |  ||  |_ |      "
echo " |  |  ||  |  ||  |  |  |  |        |  |  |  .  \|     ||     ||  |  ||     |      "
echo " |__|__||__|__||__|__|  |__|        |__|  |__|\_| \__,_| \___/ |__|__||___,_|      "
echo "                                                                                   "
echo " ---------------------- Script developed by nhattVim -----------------------       "
echo "  ----------------- Github: https://github.com/nhattVim ------------------         "
echo "$RESET"

note "Enhancing pacman.conf with extra features..."

# Refresh keyring first to avoid signature errors
note "Refreshing archlinux-keyring..."
sudo pacman -Sy --noconfirm archlinux-keyring

# ==============================================================================
# Configure Pacman
# ==============================================================================
note "Optimizing pacman settings..."

# Configuration file
pacman_conf="/etc/pacman.conf"

# Options to uncomment
lines_to_edit=(
    "Color"
    "CheckSpace"
    "VerbosePkgLists"
)

# Uncomment configuration lines
for line in "${lines_to_edit[@]}"; do
    if grep -q "^#$line" "$pacman_conf"; then
        sudo sed -i "s/^#$line/$line/" "$pacman_conf"
        act "Uncommented: $line"
    else
        note "$line is already enabled"
    fi
done

# Configure ParallelDownloads
if grep -q "^#ParallelDownloads" "$pacman_conf"; then
    sudo sed -i 's/^#ParallelDownloads.*/ParallelDownloads = 10/' "$pacman_conf"
    ok "Enabled ParallelDownloads = 10"
elif grep -q "^ParallelDownloads" "$pacman_conf"; then
    sudo sed -i 's/^ParallelDownloads.*/ParallelDownloads = 10/' "$pacman_conf"
    note "Updated ParallelDownloads = 10"
else
    echo "ParallelDownloads = 10" | sudo tee -a "$pacman_conf" >/dev/null
    ok "Added ParallelDownloads = 10"
fi

# Enable ILoveCandy feature
if ! grep -q "^ILoveCandy" "$pacman_conf"; then
    sudo sed -i '/^ParallelDownloads/a ILoveCandy' "$pacman_conf"
    ok "ILoveCandy feature enabled"
else
    note "ILoveCandy is already enabled"
fi

# Enable multilib repository
if grep -q "^#\[multilib\]" "$pacman_conf"; then
    sudo sed -i 's/^#\[multilib\]/[multilib]/' "$pacman_conf"
    sudo sed -i '/^\[multilib\]/{n;s/^#Include/Include/}' "$pacman_conf"
    ok "Multilib repository enabled"
else
    note "Multilib repository is already enabled"
fi

# System Update
note "Updating system..."
if sudo pacman -Syy; then
    ok "Package database synchronized"
else
    err "Failed to sync database!"
fi

# Install Required Packages
required_pkgs=(
    base-devel
    gum
    reflector
    curl
    git
    unzip
    wget
    libnewt
)

note "Installing essential packages..."

for pkg in "${required_pkgs[@]}"; do
    install_arch_pkg "$pkg"
done

ok "Pacman enhancements completed successfully!"
