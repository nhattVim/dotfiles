#!/bin/bash
# SDDM

# Source library
. <(curl -sSL https://is.gd/nhattVim_lib)

# Packages to install
sddm_packages=(
    qt6-5compat
    qt6-declarative
    qt6-virtualkeyboard
    qt6-multimedia-ffmpeg
    qt6-svg
    sddm
)

# Install SDDM and dependencies
note "Installing SDDM and dependencies..."
for package in "${sddm_packages[@]}"; do
    iAur "$package" || {
        err "$package installation failed!"
        exit 1
    }
done

# Disable other login managers
note "Checking for conflicting login managers..."
for login_manager in lightdm gdm lxdm lxdm-gtk3; do
    if pacman -Qs "$login_manager" >/dev/null; then
        note "Disabling $login_manager..."
        sudo systemctl disable --now "$login_manager.service" 2>/dev/null
    fi
done

# Enable SDDM service
note "Activating SDDM service..."
sudo systemctl enable sddm

# Setup SDDM config directory
sddm_conf_dir="/etc/sddm.conf.d"
[ ! -d "$sddm_conf_dir" ] && {
    note "Creating $sddm_conf_dir..."
    sudo mkdir -p "$sddm_conf_dir"
}

# Theme selection function
select_theme_variant() {
    local theme_dir="/usr/share/sddm/themes/sddm-astronaut-theme"
    local metadata_file="$theme_dir/metadata.desktop"

    [ ! -f "$metadata_file" ] && {
        err "Metadata file not found in theme directory!"
        return 1
    }

    # Get available theme variants
    local variants=()
    while IFS= read -r file; do
        variants+=("$(basename "$file" .conf)")
    done < <(find "$theme_dir/Themes" -maxdepth 1 -type f -name "*.conf" 2>/dev/null)

    [ ${#variants[@]} -eq 0 ] && {
        err "No theme variants found!"
        return 1
    }

    # User selection
    note "${YELLOW}Select theme variant (Preview: ${CYAN}https://github.com/keyitdev/sddm-astronaut-theme):${RESET}"
    local selected=$(gum choose "${variants[@]}")

    # Apply selection
    sudo sed -i "s|^ConfigFile=.*|ConfigFile=Themes/$selected.conf|" "$metadata_file"
    ok "Selected variant: ${CYAN}$selected${RESET}"
}

# Theme installation
if gum confirm "${CYAN}Install SDDM theme?${RESET}"; then
    note "Installing SDDM Astronaut Theme..."

    # Cleanup existing installations
    [ -d "/usr/share/sddm/themes/sddm-astronaut-theme" ] && {
        note "Removing old theme installation..."
        sudo rm -rf "/usr/share/sddm/themes/sddm-astronaut-theme"
    }

    # Clone theme safely
    temp_dir=$(mktemp -d)
    note "Cloning theme repository..."
    if git clone -b master --depth 1 https://github.com/keyitdev/sddm-astronaut-theme.git "$temp_dir"; then
        sudo mv "$temp_dir" "/usr/share/sddm/themes/sddm-astronaut-theme"

        # Install fonts
        note "Installing fonts..."
        sudo cp -rf "/usr/share/sddm/themes/sddm-astronaut-theme/Fonts/"* "/usr/share/fonts/"
        sudo fc-cache -fv >/dev/null

        # Set default theme
        note "Configuring SDDM..."
        echo -e "[Theme]\nCurrent=sddm-astronaut-theme" | sudo tee "$sddm_conf_dir/theme.conf.user" >/dev/null

        # Select theme variant
        select_theme_variant

        # Restart SDDM to apply changes
        note "Installation successful"
    else
        err "Failed to clone theme repository!"
        exit 1
    fi
else
    note "Skipping theme installation."
fi
