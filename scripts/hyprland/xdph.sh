#!/bin/bash
# XDG-Desktop-Portals #

# source library
source <(curl -sSL https://is.gd/nhattVim_lib)

# start script
xdg=(
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
)

# XDG-DESKTOP-PORTAL-HYPRLAND
for xdgs in "${xdg[@]}"; do
    iAur "$xdgs"
    if [ $? -ne 0 ]; then
        err "$xdgs install had failed"
    fi
done

printf "\n"
note "Checking for other xdg-desktop-portal implementations..."
sleep 1
printf "\n"
note "XDG-desktop-portal-KDE & GNOME (if installed) should be manually disabled or removed! I can't remove it... sorry..."
if gum confirm "${CYAN} Would you like to try to remove other XDG-Desktop-Portal-Implementations?${RESET}"; then
    sleep 1
    # Clean out other portals
    note "Clearing any other xdg-desktop-portal implementations..."
    # Check if packages are installed and uninstall if present
    if pacman -Qs xdg-desktop-portal-wlr >/dev/null; then
        echo "Removing xdg-desktop-portal-wlr..."
        sudo pacman -R --noconfirm xdg-desktop-portal-wlr
    fi
    if pacman -Qs xdg-desktop-portal-lxqt >/dev/null; then
        echo "Removing xdg-desktop-portal-lxqt..."
        sudo pacman -R --noconfirm xdg-desktop-portal-lxqt
    fi
else
    echo "No other XDG-implementations will be removed."
fi
