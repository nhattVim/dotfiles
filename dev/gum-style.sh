#!/bin/bash

source <(curl -sSL https://is.gd/nhattVim_lib)

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
