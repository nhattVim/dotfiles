#!/bin/bash
# config ubuntu

# source library
source <(curl -sSL https://is.gd/nhattruongNeoVim_lib) && clear

# require
exScriptGnome "boot.sh"

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
    " ------------------- Script developed by nhattruongNeoVim ------------------- " \
    "                                                                              " \
    "  -------------- Github: https://github.com/nhattruongNeoVim ---------------  " \
    "                                                                              "

gum style \
    --foreground 6 --border-foreground 6 --border rounded \
    --align left --width 90 --margin "1 2" --padding "2 4" \
    "$(tput setaf 3)NOTE:$(tput setaf 6) Ensure that you have a stable internet connection $(tput setaf 3)(Highly Recommended!!!!)$(tput sgr0)" \
    "                                                                                                                             $(tput sgr0)" \
    "$(tput setaf 3)NOTE:$(tput setaf 6) You will be required to answer some questions during the installation!!                  $(tput sgr0)" \
    "                                                                                                                             $(tput sgr0)" \
    "$(tput setaf 3)NOTE:$(tput setaf 6) If you are installing on a VM, ensure to enable 3D acceleration!                         $(tput sgr0)"

printf "\n"
ask_yes_no "Do you dual boot with window?" dual_boot
printf "\n"
ask_yes_no "Do you want to download pre-configured Gnome dotfiles?" dots
printf "\n"
ask_yes_no "Do you want to set battery charging limit (only for laptop)?" battery
printf "\n"

if [ "$dual_boot" == "Y" ]; then
    printf "\n%s - I will set the local time on Ubuntu to display the correct time on Windows. \n" "${CAT}"
    timedatectl set-local-rtc 1 --adjust-system-clock
fi

# install package
exScriptGnome "pkgs.sh"

# Check if dotfiles exist
cd $HOME || exit 1
if [ -d dotfiles ]; then
    rm -rf dotfiles
    printf "\n%s - Remove dotfile successfully \n" "${OK}"
fi

# Clone dotfiles
printf "\n%s - Clone dotfiles. \n" "${NOTE}"
if git clone -b gnome https://github.com/nhattruongNeoVim/dotfiles.git --depth 1; then
    printf "\n%s - Clone dotfiles succesfully. \n" "${OK}"
else
    printf "\n%s - Failed to clone dotfiles. \n" "${ERROR}"
    exit 1
fi

if [ "$battery" == "Y" ]; then
    exScriptHypr "battery.sh"
fi

if [ "$dots" == "Y" ]; then
    exScriptGnome "dotfiles.sh"
fi

# remove dotfiles
cd $HOME || exit 1
if [ -d dotfiles ]; then
    rm -rf dotfiles
    printf "\n%s - Remove dotfile successfully \n" "${NOTE}"
fi

# check log
if [ -f $HOME/install.log ]; then
    if gum confirm "${CAT} - Do you want to check log?"; then
        if pacman -Q bat &>/dev/null; then
            cat_command="bat"
        else
            cat_command="cat"
        fi
        $cat_command $HOME/install.log
    fi
fi

printf "\n%s - Yey! Installation Completed. Rebooting... \n" "${OK}"
if gum confirm "${CAT} Would you like to reboot now?"; then
    sudo reboot
fi
