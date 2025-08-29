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

# ==============================================================================
# Configure Mirrorlist
# ==============================================================================
note "Updating mirrorlist..."

# Variables
mirrorlist="/etc/pacman.d/mirrorlist"
mirrorlist_backup="/etc/pacman.d/mirrorlist.bak"

# Ensure reflector is available
iPac reflector

# Backup existing mirrorlist
if [[ ! -f "$mirrorlist_backup" ]]; then
    act "Backing up mirrorlist..."
    if sudo cp -v "$mirrorlist" "$mirrorlist_backup"; then
        ok "Mirrorlist backup created: $mirrorlist_backup"
    else
        err "Failed to create mirrorlist backup!"
    fi
else
    note "Mirrorlist backup already exists: $mirrorlist_backup"
fi

# Update mirrorlist with best mirrors
act "Fetching best mirrors..."
if sudo reflector \
    --verbose \
    --latest 20 \
    --sort rate \
    --save "$mirrorlist"; then

    ok "Mirrorlist updated successfully!"
    note "Top 5 best mirrors:"
    grep -E '^Server' "$mirrorlist" | head -n5 | sed 's/^/    /'
else
    err "Failed to update mirrorlist!"
    if [[ -f "$mirrorlist_backup" ]]; then
        note "Restoring backup mirrorlist..."
        sudo cp -v "$mirrorlist_backup" "$mirrorlist"
    fi
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
note "Updating system..."
if sudo pacman -Syy; then
    ok "Package database synchronized"
else
    err "Failed to sync database!"
fi

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
    wget
    libnewt
)

note "Refreshing archlinux-keyring..."
sudo pacman -Sy --noconfirm archlinux-keyring

note "Installing essential packages..."
for pkg in "${required_pkgs[@]}"; do
    iPac "$pkg"
done

ok "Pacman enhancements completed successfully!"
