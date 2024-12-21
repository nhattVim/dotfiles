#!/bin/bash
# config arch

# source library
source <(curl -sSL https://is.gd/nhattVim_lib)

# start script
exHypr "boot.sh"

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
    " ---------------------- Script developed by nhattVim ------------------------ " \
    "                                                                              " \
    "  ----------------- Github: https://github.com/nhattVim --------------------  " \
    "                                                                              "

gum style \
    --foreground 6 --border-foreground 6 --border rounded \
    --align left --width 104 --margin "1 2" --padding "2 4" \
    "$(tput setaf 3)NOTE:$(tput setaf 6) Ensure that you have a stable internet connection $(tput setaf 3)(Highly Recommended!!!!)$(tput sgr0)" \
    "                                                                                                                             $(tput sgr0)" \
    "$(tput setaf 3)NOTE:$(tput setaf 6) You will be required to answer some questions during the installation!!                  $(tput sgr0)" \
    "                                                                                                                             $(tput sgr0)" \
    "$(tput setaf 3)NOTE:$(tput setaf 6) If you are installing on a VM, ensure to enable 3D acceleration else Hyprland wont start!$(tput sgr0)"

echo -e "\n"
ask_custom_option "Choose your AUR helper" "yay" "paru" aur_helper
echo -e "\n"
ask_yes_no "Do you dual boot with window?" dual_boot
echo -e "\n"
ask_yes_no "Do you want to install GTK themes?" gtk_themes
echo -e "\n"
ask_yes_no "Do you want to configure Bluetooth?" bluetooth
echo -e "\n"
ask_yes_no "Do you have any nvidia gpu in your system?" nvidia
echo -e "\n"
ask_yes_no "Do you want to install Thunar file manager?" thunar
echo -e "\n"
ask_yes_no "Do you want to install Snap (GUI packages manager)?" snapd
echo -e "\n"
#ask_yes_no "Do you want to install & configure Firefox browser?" firefox
#echo -e "\n"
ask_yes_no "Do you want to install Homebrew (CLI package manager)?" homebrew
echo -e "\n"
ask_yes_no "Do you want to set battery charging limit (only for laptop)?" battery
echo -e "\n"
ask_yes_no "Install zsh, color scripts (Optional) & zsh plugin (Optional)?" zsh
echo -e "\n"
ask_yes_no "Install & configure SDDM log-in Manager plus (OPTIONAL) SDDM Theme?" sddm
echo -e "\n"
ask_yes_no "Install XDG-DESKTOP-PORTAL-HYPRLAND? (For proper Screen Share ie OBS)" xdph
echo -e "\n"
ask_yes_no "Do you want to download pre-configured Hyprland dotfiles?" dots
echo -e "\n"

if [ "$dual_boot" == "Y" ]; then
    echo -e "\n${CAT} I will set the local time on Arch to display the correct time on Windows."
    timedatectl set-local-rtc 1 --adjust-system-clock
fi

echo -e "\n%.0s" {1..2}
if [ "$battery" == "Y" ]; then
    exHypr "battery.sh"
fi

exHypr "swapfile.sh"
sleep 0.5
exHypr "pkgs_pacman.sh"

# Check if dotfiles exist
cd $HOME
if [ -d dotfiles ]; then
    rm -rf dotfiles
    echo -e "${OK} Remove dotfile successfully "
fi

# Clone dotfiles
echo -e "${NOTE} Clone dotfiles. "
if git clone -b hyprland https://github.com/nhattVim/dotfiles.git --depth 1; then
    echo -e "${OK} Clone dotfiles successfully."
fi

if [ "$aur_helper" == "paru" ]; then
    exHypr "paru.sh"
elif [ "$aur_helper" == "yay" ]; then
    exHypr "yay.sh"
fi

exHypr "pkgs_aur.sh"
sleep 0.5
exHypr "pipewire.sh"

if [ "$nvidia" == "Y" ]; then
    exHypr "nvidia.sh"
elif [ "$nvidia" == "N" ]; then
    exHypr "hypr.sh"
fi

if [ "$gtk_themes" == "Y" ]; then
    exHypr "gtk_themes.sh"
fi

if [ "$bluetooth" == "Y" ]; then
    exHypr "bluetooth.sh"
fi

if [ "$thunar" == "Y" ]; then
    exHypr "thunar.sh"
fi

if [ "$snapd" == "Y" ]; then
    exHypr "snapd.sh"
fi

if [ "$homebrew" == "Y" ]; then
    exHypr "homebrew.sh"
fi

#if [ "$firefox" == "Y" ]; then
#	exHypr "firefox.sh"
#fi

if [ "$sddm" == "Y" ]; then
    exHypr "sddm.sh"
fi

if [ "$xdph" == "Y" ]; then
    exHypr "xdph.sh"
fi

if [ "$zsh" == "Y" ]; then
    exHypr "zsh.sh"
fi

if [ "$dual_boot" == "Y" ]; then
    exHypr "grub_themes.sh"
fi

exHypr "input_group.sh"

if [ "$dots" == "Y" ]; then
    exHypr "dotfiles.sh"
fi

# remove dotfiles
cd $HOME
if [ -d dotfiles ]; then
    rm -rf dotfiles
    echo -e "${NOTE} Remove dotfile successfully "
fi

echo -e "\n\n"

if [ -f $HOME/install.log ]; then
    if gum confirm "${CAT} Do you want to check log?"; then
        if pacman -Q bat &>/dev/null; then
            cat_command="bat"
        else
            cat_command="cat"
        fi
        $cat_command $HOME/install.log
        gum confirm "${CAT} Continue?"
    fi
fi

# clear packages
echo -e "\n${NOTE} Clear packages."
if sudo pacman -Sc --noconfirm && yay -Sc --noconfirm && yay -Yc --noconfirm; then
    echo -e "${OK} Clear packages successfully."
fi

echo -e "\n${OK} Yey! Installation Completed."
echo -e "\n${NOTE} You can start Hyprland by typing Hyprland (IF SDDM is not installed) (note the capital H!)."
echo -e "\n${NOTE} It is highly recommended to reboot your system.\n"

if gum confirm "${CAT} Would you like to reboot now?"; then
    if [[ "$nvidia" == "Y" ]]; then
        echo -e "${NOTE} NVIDIA GPU detected. Rebooting the system..."
        systemctl reboot
    else
        systemctl reboot
    fi
fi
