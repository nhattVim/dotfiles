#!/bin/bash
# Aylur's GTK Shell v 1.8.2#

# source library
source <(curl -sSL https://is.gd/nhattVim_lib)

ags=(
    typescript
    npm
    meson
    glib2-devel
    gjs
    gtk3
    gtk-layer-shell
    upower networkmanager
    gobject-introspection
    libdbusmenu-gtk3
    libsoup3
)

# specific tags to download
ags_tag="v1.9.0"

# Installation of main components
note "Installing AGS Dependencies"

# Installing ags Dependencies
for PKG1 in "${ags[@]}"; do
    iPac "$PKG1"
    if [ $? -ne 0 ]; then
        err "$PKG1 install had failed"
    fi
done

# ags
note "Install and Compiling Aylurs GTK shell $ags_tag.."

# Check if folder exists and remove it
if [ -d "ags" ]; then
    note "Removing existing ags folder..."
    rm -rf ags
fi

# Clone nwg-look repository with the specified tag
if git clone --recursive -b "$ags_tag" --depth 1 https://github.com/Aylur/ags.git; then
    cd ags || exit 1
    # Build and install ags
    npm install
    meson setup build
    if sudo meson install -C build; then
        ok "ags installed successfully"
    else
        err "Installing failed for ags"
    fi
    cd .. && rm -rf ags
else
    err "Failed to download ags. Please check your connection"
    exit 1
fi
