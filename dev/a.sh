#!/bin/bash

# Hàm hiển thị ASCII art với hộp thoại
show_ascii_art() {
    whiptail --title "Arch Linux Configuration" --textbox /dev/stdin 27 90 <<<"
  ____   __ __   ____  ______      ______  ____   __ __   ___   ____    ____  
 |    \ |  |  | /    ||      |    |      ||    \ |  |  | /   \ |    \  /    | 
 |  _  ||  |  ||  o  ||      |    |      ||  D  )|  |  ||     ||  _  ||   __| 
 |  |  ||  _  ||     ||_|  |_|    |_|  |_||    / |  |  ||  O  ||  |  ||  |  | 
 |  |  ||  |  ||  _  |  |  |        |  |  |    \ |  :  ||     ||  |  ||  |_ | 
 |  |  ||  |  ||  |  |  |  |        |  |  |  .  \|     ||     ||  |  ||     | 
 |__|__||__|__||__|__|  |__|        |__|  |__|\_| \__,_| \___/ |__|__||___,_| 
                                                                              
 ---------------------- Script developed by nhattVim -------------------------
 
  ----------------- Github: https://github.com/nhattVim ---------------------
"
}

# Hàm hiển thị cảnh báo
show_warnings() {
    whiptail --title "Important Warnings" --msgbox "\
WARN: Ensure that you have a stable internet connection (Highly Recommended)

WARN: You will be required to answer some questions during the installation

WARN: If you are installing on a VM, ensure to enable 3D acceleration else Hyprland wont start" 16 78
}

# Hàm lựa chọn yes/no
yes_no() {
    local question="$1"
    local varname="$2"

    if whiptail --title "Configuration Option" --yesno "$question" 8 78; then
        eval "$varname=Y"
    else
        eval "$varname=N"
    fi
}

# Hàm chọn AUR helper
choose_aur_helper() {
    local options=("yay" "paru")
    aur_helper=$(whiptail --title "AUR Helper Selection" --menu "Choose your AUR helper:" 10 50 2 \
        "yay" "YAY AUR Helper" \
        "paru" "Paru AUR Helper" 3>&1 1>&2 2>&3)
    [[ -z "$aur_helper" ]] && aur_helper="yay"
}

# Hàm hiển thị tổng hợp lựa chọn
show_summary() {
    local summary="
Selected Options:
-----------------
AUR Helper: $aur_helper
Dual Boot: $dual_boot
Grub Themes: $grub_themes
GTK Themes: $gtk_themes
Bluetooth: $bluetooth
Nvidia GPU: $nvidia
Thunar File Manager: $thunar
Homebrew: $homebrew
SDDM Log-in Manager: $sddm
Firefox CSS: $firefox
XDG Portal: $xdph
Asus ROG: $rog
Unikey: $unikey
"

    whiptail --title "Confirmation" --scrolltext --yesno "$summary\nAre these options correct?" 25 78
}

# Main script logic
main() {
    # Load library
    . <(curl -sSL https://raw.githubusercontent.com/nhattVim/dotfiles/refs/heads/master/scripts/lib.sh)

    # Init
    # exHypr "boot.sh" && clear

    # Show interfaces
    show_ascii_art
    show_warnings

    # Main configuration
    while true; do
        choose_aur_helper
        yes_no "Do you dual boot with Windows?" dual_boot
        yes_no "Do you want to install the Grub theme?" grub_themes
        yes_no "Do you want to install GTK themes?" gtk_themes
        yes_no "Do you want to configure Bluetooth?" bluetooth
        yes_no "Do you have any NVIDIA GPU in your system?" nvidia
        yes_no "Do you want to install Thunar (File Manager)?" thunar
        yes_no "Do you want to install Homebrew (CLI Package Manager)?" homebrew
        yes_no "Do you want to install and configure SDDM (Login Manager)?" sddm
        yes_no "Do you want to configure Firefox with CSS customization?" firefox
        yes_no "Install XDG-DESKTOP-PORTAL-HYPRLAND?" xdph
        yes_no "Are you installing on an Asus ROG/TUF laptop?" rog
        yes_no "Set up Vietnamese keyboard (Unikey)?" unikey

        if show_summary; then
            break
        fi
    done

    # Rest of your script logic remains the same...
    # [Keep all your existing processing code here]
}

# Execute main function
main "$@"
