#!/bin/bash
# Thunar

# source library
. <(curl -sSL https://raw.githubusercontent.com/nhattVim/dotfiles/refs/heads/master/scripts/lib.sh)

# start script
thunar=(
    thunar thunar-volman tumbler
    ffmpegthumbnailer thunar-archive-plugin
    file-roller xdg-user-dirs xdg-utils
    gvfs gvfs-mtp
)

# install thunar
note "Installing Thunar Packages..."
for THUNAR in "${thunar[@]}"; do
    iAur "$THUNAR"
done

# Ask the user if they want to use Thunar as the default file manager
if gum confirm "${CYAN} Do you want to set Thunar as the default file manager? ${RESET}"; then
    xdg-mime default thunar.desktop inode/directory
    gio mime inode/directory thunar.desktop
    ok "Thunar has been set as the default file manager"
else
    note "You choose not to set Thunar as the default file manager"
fi

# Init standard workspace folder
note "Init standard workspace folder"
xdg-user-dirs-update
