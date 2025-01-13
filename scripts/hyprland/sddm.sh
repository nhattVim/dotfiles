#!/bin/bash
# SDDM

# source library
source <(curl -sSL https://is.gd/nhattVim_lib)

# start
sddm=(
    sddm
    qt5-graphicaleffects
    qt5-quickcontrols2
    qt5-svg
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
        echo "disabling $login_manager..."
        sudo systemctl disable "$login_manager.service"
    fi
done

printf " Activating sddm service........\n"
sudo systemctl enable sddm

# Check dotfiles
cd $HOME
if [ -d dotfiles ]; then
    cd dotfiles || {
        err "Failed to enter dotfiles directory"
        exit 1
    }
else
    note "Clone dotfiles." && git clone -b hyprland https://github.com/nhattVim/dotfiles.git ~/dotfiles --depth 1 || {
        err "Failed to clone dotfiles"
        exit 1
    }
    cd dotfiles || {
        err "Failed to enter dotfiles directory"
        exit 1
    }
fi

# Set up SDDM
note "Setting up the login screen."
sddm_conf_dir=/etc/sddm.conf.d
[ ! -d "$sddm_conf_dir" ] && {
    printf "$CYAN - $sddm_conf_dir not found, creating... $RESET\n"
    sudo mkdir "$sddm_conf_dir"
}

wayland_sessions_dir=/usr/share/wayland-sessions
[ ! -d "$wayland_sessions_dir" ] && {
    printf "$CYAN - $wayland_sessions_dir not found, creating... $RESET\n"
    sudo mkdir "$wayland_sessions_dir"
}

sudo cp assets/hyprland.desktop "$wayland_sessions_dir/"

# SDDM-themes
cd $HOME
if gum confirm "${CYAN} OPTIONAL - Would you like to install SDDM themes? ${RESET}"; then

    note "Installing Simple SDDM Theme"

    # Check if /usr/share/sddm/themes/simple-sddm exists and remove if it does
    if [ -d "/usr/share/sddm/themes/simple-sddm" ]; then
        sudo rm -rf "/usr/share/sddm/themes/simple-sddm"
        ok "Removed existing 'simple-sddm' directory."
    fi

    # Check if simple-sddm directory exists in the current directory and remove if it does
    if [ -d "simple-sddm" ]; then
        rm -rf "simple-sddm"
        ok "Remove existing 'simple-sddm' directory from the current location."
    fi

    if git clone https://github.com/JaKooLit/simple-sddm.git --depth 1; then
        while [ ! -d "simple-sddm" ]; do
            sleep 1
        done

        if [ ! -d "/usr/share/sddm/themes" ]; then
            sudo mkdir -p /usr/share/sddm/themes
            ok "Directory '/usr/share/sddm/themes' created."
        fi

        sudo mv simple-sddm /usr/share/sddm/themes/
        echo -e "[Theme]\nCurrent=simple-sddm" | sudo tee "$sddm_conf_dir/theme.conf.user"
    else
        err "Failed to clone the theme repository. Please check your internet connection"
    fi
else
    printf "\n%s - No SDDM themes will be installed.\n" "${YELLOW}"
    note "No SSDM themes will be installed."
fi
