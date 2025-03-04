#!/bin/bash
# config arch

# source library
. <(curl -sSL https://is.gd/nhattVim_lib)

# init
exHypr "boot.sh" && clear

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
    yes_no "Do you dual boot with Windows?" dual_boot
    yes_no "Do you want to install the Grub theme?" grub_themes
    yes_no "Do you want to install GTK themes?" gtk_themes
    yes_no "Do you want to configure Bluetooth?" bluetooth
    yes_no "Do you have any NVIDIA GPU in your system?" nvidia
    yes_no "Do you want to install Thunar (File Manager)?" thunar
    # yes_no "Do you want to install Snap (GUI Package Manager)?" snapd
    yes_no "Do you want to install Homebrew (CLI Package Manager)?" homebrew
    yes_no "Do you want to install and configure SDDM (Login Manager) with an optional SDDM theme?" sddm
    yes_no "Do you want to install and configure Firefox with Firefox CSS customization?" firefox
    yes_no "Do you want to install XDG-DESKTOP-PORTAL-HYPRLAND? (Required for proper screen sharing, e.g., in OBS)" xdph
    yes_no "Are you installing on an Asus ROG/TUF laptop?" rog
    yes_no "Are you Vietnamese and want to set up the Vietnamese keyboard (Unikey)?" unikey

    gum style \
        --border-foreground 6 --border rounded \
        --align left --width 50 --margin "1 2" --padding "2 4" \
        "${CYAN}Your selected options:" \
        "${GREEN}/-/-/-/-/-/-/-/-/-/-/-/-/-/-${RESET}" \
        "AUR Helper:${YELLOW} $aur_helper ${RESET}" \
        "Dual Boot:${YELLOW} $dual_boot ${RESET}" \
        "Grub Themes:${YELLOW} $grub_themes ${RESET}" \
        "GTK Themes:${YELLOW} $gtk_themes ${RESET}" \
        "Bluetooth:${YELLOW} $bluetooth ${RESET}" \
        "Nvidia GPU:${YELLOW} $nvidia ${RESET}" \
        "Thunar File Manager:${YELLOW} $thunar ${RESET}" \
        # "Snapd (GUI Packages Manager):${YELLOW} $snapd ${RESET}" \
        "Homebrew (CLI Packages Manager):${YELLOW} $homebrew ${RESET}" \
        "Asus ROG Laptops:${YELLOW} $rog ${RESET}" \
        "SDDM Log-in Manager:${YELLOW} $sddm ${RESET}" \
        "Firefoxcss:${YELLOW} $firefox ${RESET}" \
        "XDG-DESKTOP-PORTAL-HYPRLAND:${YELLOW} $xdph ${RESET}" \
        "Unikey:${YELLOW} $unikey ${RESET}" \
        "${GREEN}\-\-\-\-\-\-\-\-\-\-\-\-\-\-${RESET}"

    if gum confirm "Are these options correct?"; then
        break
    fi
done

if [ "$dual_boot" == "Y" ]; then
    act "I will set the local time on Arch to display the correct time on Windows"
    sudo timedatectl set-local-rtc 1 --adjust-system-clock
fi

exHypr "swapfile.sh"

exHypr "$aur_helper.sh"

exHypr "pkgs.sh"

exHypr "ags.sh"

exHypr "pipewire.sh"

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

if [ "$rog" == "Y" ]; then
    exHypr "rog.sh"
fi

# if [ "$snapd" == "Y" ]; then
#     exHypr "snapd.sh"
# fi

if [ "$homebrew" == "Y" ]; then
    exHypr "homebrew.sh"
fi

if [ "$sddm" == "Y" ]; then
    exHypr "sddm.sh"
fi

if [ "$firefox" == "Y" ]; then
    exHypr "firefox.sh"
fi

if [ "$xdph" == "Y" ]; then
    exHypr "xdph.sh"
fi

if [ "$grub_themes" == "Y" ]; then
    exHypr "grub_themes.sh"
fi

if [ "$unikey" == "Y" ]; then
    exHypr "unikey.sh"
fi

exHypr "input_group.sh"

exHypr "dotfiles.sh"

# Check log
if [ -f $HOME/install.log ]; then
    gum confirm "${CYAN} Do you want to check log?" && gum pager <$HOME/install.log
    gum confirm "${CYAN} Do you want to reinstall failed packages?" && reinstall_failed_pkgs
fi

gum style \
    --border-foreground 212 --border rounded \
    --align left --width 80 --margin "1 2" --padding "2 4" \
    "${CYAN}GREAT Copy Completed." "" \
    "${CYAN}YOU NEED to logout and re-login or reboot to avoid issues"

if gum confirm "${CAT} Would you like to reboot now?${RESET}"; then
    if [[ "$nvidia" == "Y" ]]; then
        act "NVDIA GPU detected. Rebooting the system..."
        systemctl reboot
    else
        systemctl reboot
    fi
fi
