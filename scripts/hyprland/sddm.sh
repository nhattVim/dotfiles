#!/bin/bash
# SDDM

# source library
. <(curl -sSL https://is.gd/nhattVim_lib)

# Dotfiles directory
DOTFILES_DIR="$HOME/hyprland_nhattVim"

# start
sddm=(
    qt6-5compat
    qt6-declarative
    qt6-virtualkeyboard
    qt6-multimedia-ffmpeg
    qt6-svg
    sddm
)

# Install SDDM and SDDM theme
note "Installing SDDM and dependencies ..."
for package in "${sddm[@]}"; do
    iAur "$package"
    if [ $? -ne 0 ]; then
        err "$package install has failed"
    fi
done

# Check if other login managers installed and disabling its service before enabling sddm
for login_manager in lightdm gdm lxdm lxdm-gtk3; do
    if pacman -Qs "$login_manager" >/dev/null; then
        note "Disabling $login_manager..."
        sudo systemctl disable --now "$login_manager.service"
    fi
done

printf " Activating sddm service........\n"
sudo systemctl enable sddm

# Set up SDDM
note "Setting up the login screen."
sddm_conf_dir=/etc/sddm.conf.d
[ ! -d "$sddm_conf_dir" ] && {
    note "$sddm_conf_dir not found, creating..."
    sudo mkdir "$sddm_conf_dir"
}

select_theme() {
    theme_dir="/usr/share/sddm/themes/sddm-astronaut-theme"
    metadata_file="$theme_dir/metadata.desktop"

    [ ! -f "$metadata_file" ] && {
        err "Metadata file not found!"
        return 1
    }

    themes=()
    while IFS= read -r file; do
        themes+=("$(basename "$file" .conf)")
    done < <(find "$theme_dir/Themes" -maxdepth 1 -type f -name "*.conf")

    [ ${#themes[@]} -eq 0 ] && {
        err "No themes found!"
        return 1
    }

    note "${YELLOW}Select your SDDM theme variant. You can see themes preview on ${CYAN}https://github.com/keyitdev/sddm-astronaut-theme"
    selected_theme=$(gum choose "${themes[@]}")
    sudo sed -i "s|^ConfigFile=.*|ConfigFile=Themes/$selected_theme.conf|" "$metadata_file"
    ok "Theme variant '$selected_theme' selected!"
}

# SDDM-themes
if gum confirm "${CYAN} OPTIONAL - Would you like to install SDDM themes? ${RESET}"; then

    cd $HOME
    note "Installing SDDM Theme"

    if [ -d "/usr/share/sddm/themes/sddm-astronaut-theme" ]; then
        sudo rm -rf "/usr/share/sddm/themes/sddm-astronaut-theme"
        ok "Removed existing 'sddm-astronaut-theme' directory."
    fi

    if [ -d "$HOME/sddm-astronaut-theme" ]; then
        rm -rf "$HOME/sddm-astronaut-theme"
        ok "Removed existing 'sddm-astronaut-theme' directory."
    fi

    if git clone -b master --depth 1 https://github.com/keyitdev/sddm-astronaut-theme.git sddm-astronaut-theme; then

        if [ ! -d "/usr/share/sddm/themes" ]; then
            sudo mkdir -p /usr/share/sddm/themes
            ok "Directory '/usr/share/sddm/themes' created."
        fi

        sudo mv sddm-astronaut-theme /usr/share/sddm/themes/sddm-astronaut-theme
        sudo cp -r /usr/share/sddm/themes/sddm-astronaut-theme/Fonts/* /usr/share/fonts/
        echo -e "[Theme]\nCurrent=sddm-astronaut-theme" | sudo tee "$sddm_conf_dir/theme.conf.user"

        select_theme
    else
        err "Failed to clone the theme repository. Please check your internet connection"
    fi
else
    note "No SSDM themes will be installed."
fi
