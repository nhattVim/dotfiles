#!/bin/bash
# config ubuntu

# source library
. <(curl -sSL https://is.gd/nhattVim_lib)

RUNNING_GNOME=$([[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]] && echo true || echo false)

# check ubuntu version
if [ ! -f /etc/os-release ]; then
    err "Unable to determine OS. /etc/os-release file not found."
    note "Installation stopped"
    exit 1
else
    # check ubuntu version
    . /etc/os-release
    if [ "$ID" != "ubuntu" ] || [ $(echo "$VERSION_ID >= 24.04" | bc) != 1 ]; then
        err "You are currently running: $ID $VERSION_ID"
        note "OS required: Ubuntu 24.04 or higher"
        note "Installation stopped"
        exit 1
    fi

    # check gnome
    if ! $RUNNING_GNOME; then
        err "Script is only compatible with GNOME"
        note "Installation stopped"
        exit 1
    fi
fi

# Ensure computer doesn't go to sleep or lock while installing
gsettings set org.gnome.desktop.screensaver lock-enabled false
gsettings set org.gnome.desktop.session idle-delay 0

# require
exGnome "boot.sh"

# start script
gum style \
    --foreground 213 --border-foreground 213 --border rounded \
    --align center --width 90 --margin "1 2" --padding "2 4" \
    "  ____   __ __   ____  ______      ______  ____   __ __   ___   ____    ____  " \
    " |    \ |  |  | /    ||      |    |      ||    \ |  |  | /   \ |    \  /    | " \
    " |  _  ||  |  ||  o  ||      |    |      ||  D  )|  |  ||     ||  _  ||   __| " \
    " |  |  ||  _  ||     ||_|  |_|    |_|  |_||    / |  |  ||  O  ||  |  ||  |  | " \
    " |  |  ||  |  ||  _  |  |  |        |  |  |    \ |  :  ||     ||  |  ||  |_ | " \
    " |  |  ||  |  ||  |  |  |  |        |  |  |  .  \|     ||     ||  |  ||     | " \
    " |__|__||__|__||__|__|  |__|        |__|  |__|\_| \__,_| \___/ |__|__||___,_| " \
    "                                                                              " \
    " ---------------------- Script developed by nhattVim ------------------------ " \
    "                                                                              " \
    "  ----------------- Github: https://github.com/nhattVim --------------------  " \
    "                                                                              "

gum style \
    --border-foreground 6 --border rounded \
    --align left --width 90 --margin "1 2" --padding "2 4" \
    "${YELLOW}WARN:${PINK} Ensure that you have a stable internet connection ${YELLOW}(Highly Recommended)  ${RESET}" \
    "                                                                                                       ${RESET}" \
    "${YELLOW}WARN:${PINK} You will be required to answer some questions during the installation            ${RESET}" \
    "                                                                                                       ${RESET}" \
    "${YELLOW}WARN:${PINK} If you are installing on a VM, ensure to enable 3D acceleration else             ${RESET}"

while true; do
    yes_no "Do you dual boot with window?" dual_boot
    yes_no "Do you want to set battery charging limit (only for laptop)?" battery
    yes_no "Install & configure firefox with firefoxcss?" firefox

    gum style \
        --border-foreground 6 --border rounded \
        --align left --width 50 --margin "1 2" --padding "2 4" \
        "${CYAN}Your selected options:" \
        "Dual Boot:${YELLOW} $dual_boot" \
        "Battery Charging Limit (Laptop Only):${YELLOW} $battery" \
        "Firefoxcss:${YELLOW} $firefox ${RESET}"

    if gum confirm "Are these options correct?"; then
        break
    fi
done

if [ "$dual_boot" == "Y" ]; then
    act "I will set the local time on Ubuntu to display the correct time on Windows"
    sudo timedatectl set-local-rtc 1 --adjust-system-clock
fi

if [ "$battery" == "Y" ]; then
    exHypr "battery.sh"
fi

# install package
exGnome "pkgs.sh"

# copy dotfiles
exGnome "dotfiles.sh"

if [ "$firefox" == "Y" ]; then
    exGnome "firefox.sh"
fi

# settings gnome
exGnome "settings.sh"

# change keybindings
exGnome "hotkeys.sh"

# install gnome extensions
exGnome "extensions.sh"

# change keybindings
exGnome "hotkeys.sh"

# Revert to normal idle and lock settings
gsettings set org.gnome.desktop.screensaver lock-enabled true
gsettings set org.gnome.desktop.session idle-delay 300

# Check log
if [ -f $HOME/install.log ]; then
    gum confirm "${CYAN} Do you want to check log?" && gum pager <$HOME/install.log
    gum confirm "${CYAN} Do you want to reinstall failed packages?" && reinstall_failed_pkgs
fi

# successfully
ok "Yey! Installation Completed. Rebooting..."
gum confirm "${CYAN} Would you like to reboot now?" && sudo reboot
