#!/bin/bash
# Thunar

# source library
. <(curl -sSL https://is.gd/nhattVim_lib)

# start script
thunar=(
    thunar
    thunar-volman
    tumbler
    ffmpegthumbnailer
    thunar-archive-plugin
    file-roller
)

# install thunar
note "Installing Thunar Packages..."
for THUNAR in "${thunar[@]}"; do
    iPac "$THUNAR"
done

# Ask the user if they want to use Thunar as the default file manager
if gum confirm "${CYAN} Do you want to set Thunar as the default file manager? ${RESET}"; then
    xdg-mime default thunar.desktop inode/directory
    xdg-mime default thunar.desktop application/x-wayland-gnome-saved-search
    ok "Thunar has been set as the default file manager"
else
    note "You choose not to set Thunar as the default file manager"
fi
