#!/bin/bash

source <(curl -sSL https://is.gd/nhattVim_lib)

gum style \
    --border-foreground 6 --border rounded \
    --align left --width 50 --margin "2 2" --padding "2 4" \
    "${CYAN}Your selected options:" \
    "${GREEN}/-/-/-/-/-/-/-/-/-/-/-/-/-/-" \
    "${PINK}AUR Helper:${YELLOW} $aur_helper" \
    "${PINK}Dual Boot:${YELLOW} $dual_boot" \
    "${PINK}GTK Themes:${YELLOW} $gtk_themes" \
    "${PINK}Bluetooth:${YELLOW} $bluetooth" \
    "${PINK}Nvidia GPU:${YELLOW} $nvidia" \
    "${PINK}Thunar File Manager:${YELLOW} $thunar" \
    "${PINK}Snapd (GUI Packages Manager):${YELLOW} $snapd" \
    "${PINK}Homebrew (CLI Packages Manager):${YELLOW} $homebrew" \
    "${PINK}Battery Charging Limit (Laptop Only):${YELLOW} $battery" \
    "${PINK}SDDM Log-in Manager:${YELLOW} $sddm" \
    "${PINK}XDG-DESKTOP-PORTAL-HYPRLAND:${YELLOW} $xdph" \
    "${PINK}Download Hyprland dotfiles:${YELLOW} $dots" \
    "${GREEN}\-\-\-\-\-\-\-\-\-\-\-\-\-\-"
