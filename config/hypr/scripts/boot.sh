#!/bin/bash
# A bash script designed to run only once dotfiles installed

# THIS SCRIPT CAN BE DELETED ONCE SUCCESSFULLY BOOTED!! And also, edit ~/.config/hypr/configs/execs.conf
# not necessary to do since this script is only designed to run only once as long as the marker exists
# However, I do highly suggest not to touch it since again, as long as the marker exist, script wont run

# apearance
kvantum_theme="Tokyo-Night"
color_scheme="prefer-dark"
gtk_theme="Tokyonight-Dark"
icon_theme="Tokyonight-SE"
cursor_theme="Bibata-Modern-Ice"

# variables
scriptsDir=$HOME/.config/hypr/scripts
waybar_style="$HOME/.config/waybar/style/[Wallust] Simple.css"
wallpaper="$HOME/Pictures/wallpapers/art-3.png"
notif="$HOME/.config/swaync/images/bell.png"
swww="swww img"
effect="--transition-bezier .43,1.19,1,.4 --transition-fps 30 --transition-type grow --transition-pos 0.925,0.977 --transition-duration 2"

sleep 1

# initialize pywal and wallpaper
if [ -f "$wallpaper" ]; then
    wallust run -s $wallpaper >/dev/null
    swww query || swww-daemon && $swww $wallpaper $effect
    "$scriptsDir/wallust_swww.sh" >/dev/null 2>&1 &
fi

# initiate GTK dark mode and apply icon and cursor theme
gsettings set org.gnome.desktop.interface color-scheme "$color_scheme" >/dev/null 2>&1 &
gsettings set org.gnome.desktop.interface gtk-theme "$gtk_theme" >/dev/null 2>&1 &
gsettings set org.gnome.desktop.interface icon-theme "$icon_theme" >/dev/null 2>&1 &
gsettings set org.gnome.desktop.interface cursor-theme "$cursor_theme" >/dev/null 2>&1 &
gsettings set org.gnome.desktop.interface cursor-size 24 >/dev/null 2>&1 &

# initiate kvantum theme
kvantummanager --set "$kvantum_theme" >/dev/null 2>&1 &

# initiate the kb_layout (for some reason) waybar cant launch it
"$scriptsDir/switch_kb_layout.sh" >/dev/null 2>&1 &

# initial waybar style
if [ -f "$waybar_style" ]; then
    ln -sf "$waybar_style" "$HOME/.config/waybar/style.css"

    # refreshing waybar, swaync, rofi etc.
    "$scriptsDir/refresh.sh" >/dev/null 2>&1 &
fi

# install snap store
if command -v snap &>/dev/null; then
    if ! snap list | grep -q 'snap-store'; then
        notify-send -e -u low -i "$notif" "  Installing snap-store"
        sudo snap install snap-store && sudo snap install snapd-desktop-integration || {
            notify-send -u low -i "$notif" "Failed to install snap-store"
            exit 1
        }
        notify-send -u low -i "$notif" "Install successfully"
    fi
fi

# initial vmware
if command -v vmware &>/dev/null; then
    sudo modprobe -a vmw_vmci vmmon && { notify-send -u low -i "$notif" "Enable vmware module successfully"; } || {
        notify-send -u low -i "$notif" "Failed to enable vmware module"
    }
    sudo systemctl enable --now vmware-networks.service && { notify-send -u low -i "$notif" "Enable vmware network service successfully!"; } || {
        notify-send -u low -i "$notif" "Failed to enable vmware network service"
    }
    sudo systemctl enable --now vmware-usbarbitrator.service && { notify-send -u low -i "$notif" "Enable vmware usb service successfully!"; } || {
        notify-send -u low -i "$notif" "Failed to enable vmware usb service"
    }
fi

sed -i '/exec-once = \$HOME\/.config\/hypr\/scripts\/boot.sh/s/^/# /' $HOME/.config/hypr/configs/execs.conf
sleep 2

notify-send -e -u low -i "$notif" "Boot script finished"

exit
