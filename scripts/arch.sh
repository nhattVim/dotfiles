#!/bin/bash
# config arch

# source library
source <(curl -sSL https://is.gd/nhattruongNeoVim_lib)

# start script
exScriptHypr "boot.sh"

# init
clear

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
    --align left --width 104 --margin "1 2" --padding "2 4" \
    "$(tput setaf 3)NOTE:$(tput setaf 6) Ensure that you have a stable internet connection $(tput setaf 3)(Highly Recommended!!!!)$(tput sgr0)" \
    "                                                                                                                             $(tput sgr0)" \
    "$(tput setaf 3)NOTE:$(tput setaf 6) You will be required to answer some questions during the installation!!                  $(tput sgr0)" \
    "                                                                                                                             $(tput sgr0)" \
    "$(tput setaf 3)NOTE:$(tput setaf 6) If you are installing on a VM, ensure to enable 3D acceleration else Hyprland wont start!$(tput sgr0)"

printf "\n"
ask_custom_option "Choose your AUR helper" "yay" "paru" aur_helper
printf "\n"
ask_yes_no "Do you dual boot with window?" dual_boot
printf "\n"
ask_yes_no "Do you want to install GTK themes?" gtk_themes
printf "\n"
ask_yes_no "Do you want to configure Bluetooth?" bluetooth
printf "\n"
ask_yes_no "Do you have any nvidia gpu in your system?" nvidia
printf "\n"
ask_yes_no "Do you want to install Thunar file manager?" thunar
printf "\n"
ask_yes_no "Do you want to install Snap (GUI packages manager)?" snapd
printf "\n"
#ask_yes_no "Do you want to install & configure Firefox browser?" firefox
#printf "\n"
ask_yes_no "Do you want to install Homebrew (CLI package manager)?" homebrew
printf "\n"
ask_yes_no "Do you want to set battery charging limit (only for laptop)?" battery
printf "\n"
ask_yes_no "Install zsh, color scripts (Optional) & zsh plugin (Optional)?" zsh
printf "\n"
ask_yes_no "Install & configure SDDM log-in Manager plus (OPTIONAL) SDDM Theme?" sddm
printf "\n"
ask_yes_no "Install XDG-DESKTOP-PORTAL-HYPRLAND? (For proper Screen Share ie OBS)" xdph
printf "\n"
ask_yes_no "Do you want to download pre-configured Hyprland dotfiles?" dots
printf "\n"

if [ "$dual_boot" == "Y" ]; then
    printf "\n%s - I will set the local time on Arch to display the correct time on Windows. \n" "${CAT}"
    timedatectl set-local-rtc 1 --adjust-system-clock
fi

printf "\n%.0s" {1..2}
if [ "$battery" == "Y" ]; then
    exScriptHypr "battery.sh"
fi

exScriptHypr "swapfile.sh"
sleep 0.5
exScriptHypr "pkgs_pacman.sh"

# Check if dotfiles exist
cd $HOME
if [ -d dotfiles ]; then
    rm -rf dotfiles
    echo -e "${OK} Remove dotfile successfully "
fi

# Clone dotfiles
printf "\n${NOTE} Clone dotfiles. "
if git clone -b hyprland https://github.com/nhattruongNeoVim/dotfiles.git --depth 1; then
    printf "\n${OK} Clone dotfiles succesfully.\n"
fi

if [ "$aur_helper" == "paru" ]; then
    exScriptHypr "paru.sh"
elif [ "$aur_helper" == "yay" ]; then
    exScriptHypr "yay.sh"
fi

exScriptHypr "pkgs_aur.sh"
sleep 0.5
exScriptHypr "pipewire.sh"

if [ "$nvidia" == "Y" ]; then
    exScriptHypr "nvidia.sh"
elif [ "$nvidia" == "N" ]; then
    exScriptHypr "hypr.sh"
fi

if [ "$gtk_themes" == "Y" ]; then
    exScriptHypr "gtk_themes.sh"
fi

if [ "$bluetooth" == "Y" ]; then
    exScriptHypr "bluetooth.sh"
fi

if [ "$thunar" == "Y" ]; then
    exScriptHypr "thunar.sh"
fi

if [ "$snapd" == "Y" ]; then
    exScriptHypr "snapd.sh"
fi

if [ "$homebrew" == "Y" ]; then
    exScriptHypr "homebrew.sh"
fi

#if [ "$firefox" == "Y" ]; then
#	exScriptHypr "firefox.sh"
#fi

if [ "$sddm" == "Y" ]; then
    exScriptHypr "sddm.sh"
fi

if [ "$xdph" == "Y" ]; then
    exScriptHypr "xdph.sh"
fi

if [ "$zsh" == "Y" ]; then
    exScriptHypr "zsh.sh"
fi

if [ "$dual_boot" == "Y" ]; then
    exScriptHypr "grub_themes.sh"
fi

exScriptHypr "input_group.sh"

if [ "$dots" == "Y" ]; then
    exScriptHypr "dotfiles.sh"
fi

# remove dotfiles
cd $HOME
if [ -d dotfiles ]; then
    rm -rf dotfiles
    echo -e "${NOTE} Remove dotfile successfully "
fi

printf "\n%.0s" {1..2}

if [ -f $HOME/install.log ]; then
    if gum confirm "${CAT} Do you want to check log?"; then
        if pacman -Q bat &>/dev/null; then
            cat_command="bat"
        else
            cat_command="cat"
        fi
        $cat_command $HOME/install.log
    fi
fi

# clear packages
printf "\n${NOTE} Clear packages.\n"
if sudo pacman -Sc --noconfirm && yay -Sc --noconfirm && yay -Yc --noconfirm; then
    printf "\n${OK} Clear packages succesfully.\n"
fi

printf "\n${OK} Yey! Installation Completed.\n"
printf "\n${NOTE} You can start Hyprland by typing Hyprland (IF SDDM is not installed) (note the capital H!).\n"
printf "\n${NOTE} It is highly recommended to reboot your system.\n\n"

if gum confirm "${CAT} Would you like to reboot now?"; then
    if [[ "$nvidia" == "Y" ]]; then
        echo "${NOTE} NVIDIA GPU detected. Rebooting the system..."
        systemctl reboot
    else
        systemctl reboot
    fi
fi
