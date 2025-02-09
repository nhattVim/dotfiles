#!/bin/bash
# Enhancing pacman with extra features

# Source the library
. <(curl -sSL https://bit.ly/nhattVim_lib)

# Start script
echo -e "\e[34m   ____   __ __   ____  ______      ______  ____   __ __   ___   ____    ____"
echo -e " |    \ |  |  | /    ||      |    |      ||    \ |  |  | /   \ |    \  /    |      "
echo -e " |  _  ||  |  ||  o  ||      |    |      ||  D  )|  |  ||     ||  _  ||   __|      "
echo -e " |  |  ||  _  ||     ||_|  |_|    |_|  |_||    / |  |  ||  O  ||  |  ||  |  |      "
echo -e " |  |  ||  |  ||  _  |  |  |        |  |  |    \ |  :  ||     ||  |  ||  |_ |      "
echo -e " |  |  ||  |  ||  |  |  |  |        |  |  |  .  \|     ||     ||  |  ||     |      "
echo -e " |__|__||__|__||__|__|  |__|        |__|  |__|\_| \__,_| \___/ |__|__||___,_|      "
echo -e "                                                                                   "
echo -e " ---------------------- Script developed by nhattVim -----------------------       "
echo -e "  ----------------- Github: https://github.com/nhattVim ------------------         "

note "Enhancing pacman.conf with extra features..."

# ==============================================================================
# Configure Mirrorlist
# ==============================================================================
note "Updating mirrorlist..."

# Variables
mirrorlist="/etc/pacman.d/mirrorlist"
mirrorlist_backup="/etc/pacman.d/mirrorlist.bak"

# Check and install reflector if not available
if ! command -v reflector &>/dev/null; then
    iPac reflector
    if [ $? -ne 0 ]; then
        err "reflector install had failed"
    fi
fi

# Backup existing mirrorlist
act "Backing up mirrorlist..."
if sudo cp -v "$mirrorlist" "$mirrorlist_backup"; then
    ok "Mirrorlist backup successful: $mirrorlist_backup"
else
    err "Failed to back up mirrorlist!"
fi

# Update mirrorlist with best mirrors
act "Updating mirrorlist..."
if sudo reflector \
    --verbose \
    --latest 20 \
    --protocol https \
    --sort rate \
    --save "$mirrorlist"; then

    ok "Mirrorlist updated successfully!"
    note "Top 5 best mirrors:"
    grep -E '^Server' "$mirrorlist" | head -n5 | sed 's/^/    /'
else
    err "Failed to update mirrorlist!"
    note "Restoring mirrorlist from backup..."
    sudo mv -v "$mirrorlist_backup" "$mirrorlist"
fi

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
    "ParallelDownloads"
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

# Enable ILoveCandy feature
if ! grep -q "^ILoveCandy" "$pacman_conf"; then
    sudo sed -i "/ParallelDownloads/a ILoveCandy" "$pacman_conf"
    ok "ILoveCandy feature enabled"
else
    note "ILoveCandy is already enabled"
fi

# ==============================================================================
# System Update
# ==============================================================================
note "Starting system update..."
act "Synchronizing package database..."
sudo pacman -Syy || {
    err "Failed to synchronize package database"
}

# ==============================================================================
# Install Required Packages
# ==============================================================================
required_pkgs=(
    archlinux-keyring
    gum
    reflector
    curl
    git
    unzip
    base-devel
)

note "Installing essential packages..."
for pkg in "${required_pkgs[@]}"; do
    iPac "$pkg"
    if [ $? -ne 0 ]; then
        err "$pkg install had failed"
    fi
done

ok "All configurations completed successfully!"
