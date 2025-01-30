#!/bin/bash
# Main Hyprland Package

# source library
. <(curl -sSL https://is.gd/nhattVim_lib)

# Dotfiles directory
DOTFILES_DIR="$HOME/hyprland_nhattVim"

# start script
hypr=(
    hyprcursor
    hyprutils
    aquamarine
    hypridle
    hyprlock
    hyprland
    pyprland
    hyprland-qtutils
    libspng
)

uninstall=(
    hyprland-git
    hyprland-nvidia
    hyprland-nvidia-git
    hyprland-nvidia-hidpi-git
)

# Removing other Hyprland to avoid conflict
note "Checking for other hyprland packages and remove if any..."
if pacman -Qs hyprland >/dev/null; then
    for PKG in "${uninstall[@]}"; do
        uPac "$PKG"
        if [ $? -ne 0 ]; then
            err "$PKG uninstallation had failed"
        fi
    done
fi

# Hyprland
note "Installing Hyprland......"
for HYPR in "${hypr[@]}"; do
    iAur "$HYPR"
    [ $? -ne 0 ] && {
        err "$HYPR install had failed"
    }
done

# Remove old dotfiles if exist
if [ -d "$DOTFILES_DIR" ]; then
    rm -rf "$DOTFILES_DIR"
fi

# Clone dotfiles
note "Cloning dotfiles..."
if git clone -b hyprland https://github.com/nhattVim/dotfiles.git --depth 1 "$DOTFILES_DIR"; then
    ok "Cloned dotfiles successfully"
else
    err "Failed to clone dotfiles" && exit 1
fi

wayland_sessions_dir=/usr/share/wayland-sessions
[ ! -d "$wayland_sessions_dir" ] && {
    note "$wayland_sessions_dir not found, creating..."
    sudo mkdir "$wayland_sessions_dir"
}

sudo cp "$DOTFILES_DIR/assets/hyprland.desktop" "$wayland_sessions_dir/"
