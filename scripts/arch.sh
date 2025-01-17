#!/bin/bash
# config arch

# source library
source <(curl -sSL https://is.gd/nhattVim_lib)

# init
exHypr "base.sh"

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
    --align left --width 104 --margin "1 2" --padding "2 4" \
    "${YELLOW}WARN:${PINK} Ensure that you have a stable internet connection ${YELLOW}(Highly Recommended)          ${RESET}" \
    "                                                                                                               ${RESET}" \
    "${YELLOW}WARN:${PINK} You will be required to answer some questions during the installation                    ${RESET}" \
    "                                                                                                               ${RESET}" \
    "${YELLOW}WARN:${PINK} If you are installing on a VM, ensure to enable 3D acceleration else Hyprland wont start ${RESET}"

while true; do
    choose "Choose your AUR helper" "yay" "paru" aur_helper
    yes_no "Do you dual boot with window?" dual_boot
    yes_no "Do you want to install GTK themes?" gtk_themes
    yes_no "Do you want to configure bluetooth?" bluetooth
    yes_no "Do you have any nvidia gpu in your system?" nvidia
    yes_no "Do you want to install Thunar file manager?" thunar
    yes_no "Do you want to install Snap (GUI packages manager)?" snapd
    yes_no "Do you want to install Homebrew (CLI package manager)?" homebrew
    yes_no "Do you want to set battery charging limit (only for laptop)?" battery
    yes_no "Install & configure SDDM log-in Manager plus (OPTIONAL) SDDM Theme?" sddm
    yes_no "Install XDG-DESKTOP-PORTAL-HYPRLAND? (For proper Screen Share ie OBS)" xdph
    yes_no "Do you want to download pre-configured Hyprland dotfiles?" dots

    gum style \
        --border-foreground 6 --border rounded \
        --align left --width 50 --margin "1 2" --padding "2 4" \
        "${CYAN}Your selected options:" \
        "${GREEN}/-/-/-/-/-/-/-/-/-/-/-/-/-/-${RESET}" \
        "AUR Helper:${YELLOW} $aur_helper ${RESET}" \
        "Dual Boot:${YELLOW} $dual_boot ${RESET}" \
        "GTK Themes:${YELLOW} $gtk_themes ${RESET}" \
        "Bluetooth:${YELLOW} $bluetooth ${RESET}" \
        "Nvidia GPU:${YELLOW} $nvidia ${RESET}" \
        "Thunar File Manager:${YELLOW} $thunar ${RESET}" \
        "Snapd (GUI Packages Manager):${YELLOW} $snapd ${RESET}" \
        "Homebrew (CLI Packages Manager):${YELLOW} $homebrew ${RESET}" \
        "Battery Charging Limit (Laptop Only):${YELLOW} $battery ${RESET}" \
        "SDDM Log-in Manager:${YELLOW} $sddm ${RESET}" \
        "XDG-DESKTOP-PORTAL-HYPRLAND:${YELLOW} $xdph ${RESET}" \
        "Download Hyprland dotfiles:${YELLOW} $dots ${RESET}" \
        "${GREEN}\-\-\-\-\-\-\-\-\-\-\-\-\-\-${RESET}"

    if gum confirm "Are these options correct?"; then
        break
    fi
done

if [ "$dual_boot" == "Y" ]; then
    act "I will set the local time on Arch to display the correct time on Windows"
    timedatectl set-local-rtc 1 --adjust-system-clock
fi

if [ "$battery" == "Y" ]; then
    exHypr "battery.sh"
fi

exHypr "swapfile.sh"
sleep 0.5
exHypr "pkgs_pacman.sh"

# Remove old dotfiles if exist
cd $HOME
[ -d hyprland_nhattVim ] &&
    rm -rf hyprland_nhattVim &&
    ok "Remove old dotfiles successfully"

# Clone dotfiles
note "Clone dotfiles." &&
    git clone -b hyprland https://github.com/nhattVim/dotfiles.git --depth 1 hyprland_nhattVim &&
    ok "Clone dotfiles successfully" || {
    err "Failed to clone dotfiles"
    exit 1
}

if [ "$aur_helper" == "paru" ]; then
    exHypr "paru.sh"
elif [ "$aur_helper" == "yay" ]; then
    exHypr "yay.sh"
fi

exHypr "pkgs_aur.sh"

exHypr "pipewire.sh"

exHypr "hypr.sh"

# exHypr "ags.sh"

if [ "$nvidia" == "Y" ]; then
    exHypr "nvidia.sh"
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

if [ "$sddm" == "Y" ]; then
    exHypr "sddm.sh"
fi

if [ "$xdph" == "Y" ]; then
    exHypr "xdph.sh"
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
[ -d hyprland_nhattVim ] &&
    rm -rf hyprland_nhattVim &&
    ok "Remove old dotfiles successfully"

echo

if [ -f $HOME/install.log ]; then
    gum confirm "${CYAN} Do you want to check log?${RESET}" && gum pager <$HOME/install.log
fi

# clear packages
note "Clear packages."
if sudo pacman -Sc --noconfirm && yay -Sc --noconfirm && yay -Yc --noconfirm; then
    ok "Clear packages successfully."
fi

echo -e "\n${GREEN} Yey! Installation Completed."
echo -e "\n${YELLOW} You can start Hyprland by typing Hyprland (IF SDDM is not installed) (note the capital H!)."
echo -e "\n${YELLOW} It is highly recommended to reboot your system.\n"

if gum confirm "${CAT} Would you like to reboot now?${RESET}"; then
    if [[ "$nvidia" == "Y" ]]; then
        act "NVDIA GPU detected. Rebooting the system..."
        systemctl reboot
    else
        systemctl reboot
    fi
fi
