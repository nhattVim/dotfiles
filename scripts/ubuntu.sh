#!/bin/bash
# config ubuntu

# source library
source <(curl -sSL https://is.gd/nhattVim_lib)

# require
exGnome "base.sh"

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
    yes_no "Do you want to download pre-configured Gnome dotfiles?" dots
    yes_no "Do you want to set battery charging limit (only for laptop)?" battery

    gum style \
        --border-foreground 6 --border rounded \
        --align left --width 50 --margin "1 2" --padding "2 4" \
        "${CYAN}Your selected options:" \
        "${PINK}Dual Boot:${YELLOW} $dual_boot" \
        "${PINK}Download Gnome dotfiles:${YELLOW} $dots" \
        "${PINK}Battery Charging Limit (Laptop Only):${YELLOW} $battery"

    if gum confirm "Are these options correct?"; then
        break
    fi
done

if [ "$dual_boot" == "Y" ]; then
    act "I will set the local time on Ubuntu to display the correct time on Windows"
    timedatectl set-local-rtc 1 --adjust-system-clock
fi

# install package
exGnome "pkgs.sh"

# Check if dotfiles exist
cd $HOME || exit 1
if [ -d dotfiles ]; then
    rm -rf dotfiles
    ok "Remove dotfile successfully"
fi

# Clone dotfiles
note "Clone dotfiles."
if git clone -b gnome https://github.com/nhattVim/dotfiles.git --depth 1; then
    ok "Clone dotfiles successfully"
else
    err "Failed to clone dotfiles"
    exit 1
fi

if [ "$battery" == "Y" ]; then
    exHypr "battery.sh"
fi

if [ "$dots" == "Y" ]; then
    exGnome "dotfiles.sh"
fi

# remove dotfiles
cd $HOME || exit 1
if [ -d dotfiles ]; then
    rm -rf dotfiles
    note "Remove dotfile successfully"
fi

# check log
if [ -f $HOME/install.log ]; then
    gum confirm "${CYAN} Do you want to check log?" && gum pager <$HOME/install.log
fi

ok "Yey! Installation Completed. Rebooting..."
if gum confirm "${CYAN} Would you like to reboot now?"; then
    sudo reboot
fi
