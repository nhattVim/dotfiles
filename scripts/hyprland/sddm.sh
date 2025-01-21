#!/bin/bash
# SDDM

# source library
. <(curl -sSL https://is.gd/nhattVim_lib)

# start
sddm=(
    qt6-5compat
    qt6-declarative
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
        sudo systemctl disable "$login_manager.service"
    fi
done

printf " Activating sddm service........\n"
sudo systemctl enable sddm

# Check dotfiles
cd "$HOME"
if ! cd hyprland_nhattVim 2>/dev/null; then
    note "Clone dotfiles." &&
        git clone -b hyprland https://github.com/nhattVim/dotfiles.git --depth 1 hyprland_nhattVim &&
        cd hyprland_nhattVim &&
        ok "Clone dotfiles successfully" || err "Failed to clone dotfiles" && exit 1
fi

# Set up SDDM
note "Setting up the login screen."
sddm_conf_dir=/etc/sddm.conf.d
[ ! -d "$sddm_conf_dir" ] && {
    note "$sddm_conf_dir not found, creating..."
    sudo mkdir "$sddm_conf_dir"
}

wayland_sessions_dir=/usr/share/wayland-sessions
[ ! -d "$wayland_sessions_dir" ] && {
    note "$wayland_sessions_dir not found, creating..."
    sudo mkdir "$wayland_sessions_dir"
}

sudo cp assets/hyprland.desktop "$wayland_sessions_dir/"

# SDDM-themes
cd $HOME
if gum confirm "${CYAN} OPTIONAL - Would you like to install SDDM themes? ${RESET}"; then

    note "Installing Simple SDDM Theme"

    # Check if /usr/share/sddm/themes/simple-sddm exists and remove if it does
    if [ -d "/usr/share/sddm/themes/simple-sddm-2" ]; then
        sudo rm -rf "/usr/share/sddm/themes/simple-sddm-2"
        ok "Removed existing 'simple-sddm-2' directory."
    fi

    # Check if simple-sddm directory exists in the current directory and remove if it does
    if [ -d "simple-sddm-2" ]; then
        rm -rf "simple-sddm-2"
        ok "Remove existing 'simple-sddm-2' directory from the current location."
    fi

    if git clone https://github.com/JaKooLit/simple-sddm-2.git --depth 1; then
        while [ ! -d "simple-sddm-2" ]; do
            sleep 1
        done

        if [ ! -d "/usr/share/sddm/themes" ]; then
            sudo mkdir -p /usr/share/sddm/themes
            ok "Directory '/usr/share/sddm/themes' created."
        fi

        sudo mv simple-sddm-2 /usr/share/sddm/themes/
        echo -e "[Theme]\nCurrent=simple-sddm-2" | sudo tee "$sddm_conf_dir/theme.conf.user"
    else
        err "Failed to clone the theme repository. Please check your internet connection"
    fi
else
    note "No SSDM themes will be installed."
fi
