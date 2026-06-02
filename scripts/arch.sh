#!/bin/bash
# config arch

# source library
. <(curl -sSL https://raw.githubusercontent.com/nhattVim/dotfiles/refs/heads/master/scripts/lib.sh)

# init
run_hypr_script "boot.sh" && clear

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
    ask_choice "Choose your AUR helper" "yay" "paru" aur_helper
    ask_confirm "Do you dual boot with Windows?" dual_boot
    ask_confirm "Do you want to install the Grub theme?" grub_themes
    ask_confirm "Do you want to configure Bluetooth?" bluetooth
    ask_confirm "Do you have any NVIDIA GPU in your system?" nvidia
    ask_confirm "Do you want to install Thunar (File Manager)?" thunar
    ask_confirm "Do you want to install Homebrew (CLI Package Manager)?" homebrew
    ask_confirm "Do you want to install and configure SDDM (Login Manager) with an optional SDDM theme?" sddm
    ask_confirm "Do you want to install and configure Firefox with Firefox CSS customization?" firefox
    ask_confirm "Do you want to install XDG-DESKTOP-PORTAL-HYPRLAND? (Required for proper screen sharing, e.g., in OBS)" xdph
    ask_confirm "Are you installing on an Asus ROG/TUF laptop?" rog
    ask_confirm "Are you Vietnamese and want to set up the Vietnamese keyboard (Unikey)?" unikey

    gum style \
        --border-foreground 6 --border rounded \
        --align left --width 50 --margin "1 2" --padding "2 4" \
        "${CYAN}Your selected options:" \
        "${GREEN}/-/-/-/-/-/-/-/-/-/-/-/-/-/-${RESET}" \
        "AUR Helper:${YELLOW} $aur_helper ${RESET}" \
        "Dual Boot:${YELLOW} $dual_boot ${RESET}" \
        "Grub Themes:${YELLOW} $grub_themes ${RESET}" \
        "Bluetooth:${YELLOW} $bluetooth ${RESET}" \
        "Nvidia GPU:${YELLOW} $nvidia ${RESET}" \
        "Thunar File Manager:${YELLOW} $thunar ${RESET}" \
        "Homebrew (CLI Packages Manager):${YELLOW} $homebrew ${RESET}" \
        "Asus ROG Laptops:${YELLOW} $rog ${RESET}" \
        "SDDM Log-in Manager:${YELLOW} $sddm ${RESET}" \
        "FirefoxCSS:${YELLOW} $firefox ${RESET}" \
        "XDG-DESKTOP-PORTAL-HYPRLAND:${YELLOW} $xdph ${RESET}" \
        "Unikey:${YELLOW} $unikey ${RESET}" \
        "${GREEN}\-\-\-\-\-\-\-\-\-\-\-\-\-\-${RESET}"

    if gum confirm "${YELLOW} Are these options correct? ${RESET}"; then
        break
    fi
done

if [ "$dual_boot" == "Y" ]; then
    act "I will set the local time on Arch to display the correct time on Windows"
    sudo timedatectl set-local-rtc 1 --adjust-system-clock
fi

run_hypr_script "swapfile.sh"

run_hypr_script "$aur_helper.sh"

run_hypr_script "pkgs.sh"

if [ "$nvidia" == "Y" ]; then
    run_hypr_script "nvidia.sh"
fi

if [ "$bluetooth" == "Y" ]; then
    run_hypr_script "bluetooth.sh"
fi

if [ "$thunar" == "Y" ]; then
    run_hypr_script "thunar.sh"
fi

if [ "$rog" == "Y" ]; then
    run_hypr_script "rog.sh"
fi

if [ "$homebrew" == "Y" ]; then
    run_hypr_script "homebrew.sh"
fi

if [ "$sddm" == "Y" ]; then
    run_hypr_script "sddm.sh"
fi

if [ "$firefox" == "Y" ]; then
    run_hypr_script "firefox.sh"
fi

if [ "$xdph" == "Y" ]; then
    run_hypr_script "xdph.sh"
fi

if [ "$grub_themes" == "Y" ]; then
    run_hypr_script "grub_themes.sh"
fi

if [ "$unikey" == "Y" ]; then
    run_hypr_script "unikey.sh"
fi

run_hypr_script "input_group.sh"

run_hypr_script "dotfiles.sh"

# Check log
if [ -f $HOME/install.log ]; then
    gum confirm "${CYAN} Do you want to check log?" && gum pager <$HOME/install.log
    gum confirm "${CYAN} Do you want to reinstall failed packages?" && retry_failed_installs
fi

gum style \
    --border-foreground 212 --border rounded \
    --align left --width 80 --margin "1 2" --padding "2 4" \
    "${CYAN}GREAT Copy Completed." "" \
    "${CYAN}YOU NEED to logout and re-login or reboot to avoid issues"

if gum confirm "${CYAN} Would you like to reboot now? ${RESET}"; then
    if [[ "$nvidia" == "Y" ]]; then
        act "NVIDIA GPU detected. Rebooting the system..."
        systemctl reboot
    else
        systemctl reboot
    fi
fi
