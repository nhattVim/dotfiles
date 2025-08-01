#!/bin/bash
# Aylur's GTK Shell v 1.8.2#

# source library
. <(curl -sSL https://raw.githubusercontent.com/nhattVim/dotfiles/refs/heads/master/scripts/lib.sh)

ags=(
    typescript
    npm
    meson
    glib2-devel
    gjs
    gtk3
    gtk-layer-shell
    upower
    networkmanager
    gobject-introspection
    libdbusmenu-gtk3
    libsoup3
)

# specific tags to download
ags_tag="v1.9.0"

# Check if AGS is installed
if command -v ags &>/dev/null; then
    AGS_VERSION=$(ags -v | awk '{print $NF}')
    if [[ "$AGS_VERSION" == "1.9.0" ]]; then
        note "Aylur's GTK Shell v1.9.0 is already installed. Skipping installation."
        exit 0
    fi
fi

# Installation of main components
note "Installing AGS Dependencies"

# Installing ags Dependencies
for PKG1 in "${ags[@]}"; do
    iPac "$PKG1"
done

# ags
note "Install and Compiling Aylurs GTK shell $ags_tag.."

# create a temporary directory
temp_dir=$(mktemp -d)

# Clone nwg-look repository with the specified tag
if git clone --depth=1 https://github.com/JaKooLit/ags_v1.9.0.git "$temp_dir"; then
    cd $temp_dir || exit 1
    # Build and install ags
    npm install
    meson setup build
    if sudo meson install -C build; then
        ok "ags installed successfully"
    else
        err "Installing failed for ags"
    fi
    rm -rf $temp_dir
else
    err "Failed to download ags. Please check your connection"
fi
