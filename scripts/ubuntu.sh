#!/bin/bash
# config ubuntu

# source library
source <(curl -sSL https://is.gd/nhattVim_lib) && clear

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
    --foreground 6 --border-foreground 6 --border rounded \
    --align left --width 90 --margin "1 2" --padding "2 4" \
    "$(tput setaf 3)NOTE:$(tput setaf 6) Ensure that you have a stable internet connection $(tput setaf 3)(Highly Recommended!!!!)$(tput sgr0)" \
    "                                                                                                                             $(tput sgr0)" \
    "$(tput setaf 3)NOTE:$(tput setaf 6) You will be required to answer some questions during the installation!!                  $(tput sgr0)" \
    "                                                                                                                             $(tput sgr0)" \
    "$(tput setaf 3)NOTE:$(tput setaf 6) If you are installing on a VM, ensure to enable 3D acceleration!                         $(tput sgr0)"

echo -e "\n"
yes_no "Do you dual boot with window?" dual_boot
echo -e "\n"
yes_no "Do you want to download pre-configured Gnome dotfiles?" dots
echo -e "\n"
yes_no "Do you want to set battery charging limit (only for laptop)?" battery
echo -e "\n"

if [ "$dual_boot" == "Y" ]; then
    echo -e "\n${CAT} - I will set the local time on Ubuntu to display the correct time on Windows. \n"
    timedatectl set-local-rtc 1 --adjust-system-clock
fi

# install package
exGnome "pkgs.sh"

# Check if dotfiles exist
cd $HOME || exit 1
if [ -d dotfiles ]; then
    rm -rf dotfiles
    echo -e "\n${OK} - Remove dotfile successfully \n"
fi

# Clone dotfiles
echo -e "\n${NOTE} - Clone dotfiles. \n"
if git clone -b gnome https://github.com/nhattVim/dotfiles.git --depth 1; then
    echo -e "\n${OK} - Clone dotfiles succesfully. \n"
else
    echo -e "\n${ERROR} - Failed to clone dotfiles. \n"
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
    echo -e "\n${NOTE} - Remove dotfile successfully \n"
fi

# check log
if [ -f $HOME/install.log ]; then
    gum confirm "${CAT} Do you want to check log?" && gum pager <$HOME/install.log
fi

echo -e "\n${OK} - Yey! Installation Completed. Rebooting... \n"
if gum confirm "${CAT} Would you like to reboot now?"; then
    sudo reboot
fi
