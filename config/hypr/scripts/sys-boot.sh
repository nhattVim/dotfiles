#!/bin/bash
# Boot initialization script - runs only once after dotfiles are installed
# Safe to delete after first successful boot (marker in execs.conf will be commented)

# === Appearance settings ===
kvantum_theme="Tokyo-Night"
color_scheme="prefer-dark"
gtk_theme="adw-gtk3-dark"
icon_theme="Tokyonight-SE"
cursor_theme="Bibata-Modern-Ice"
cursor_size=24

# === Paths ===
scripts_dir="$HOME/.config/hypr/scripts"
waybar_style="$HOME/.config/waybar/style/[Catppuccin] Mocha.css"
wall_dir="$HOME/Pictures/Wallpapers"
wallpaper="$wall_dir/car-2.png"
notif_icon="$HOME/.config/swaync/images/bell.png"
swww_cmd="swww img"
swww_effect="--transition-bezier .43,1.19,1,.4 --transition-fps 30 --transition-type grow \
--transition-pos 0.925,0.977 --transition-duration 2"

# === Functions ===
apply_gsettings() {
    gsettings set org.gnome.desktop.interface color-scheme "$color_scheme"
    gsettings set org.gnome.desktop.interface gtk-theme "$gtk_theme"
    gsettings set org.gnome.desktop.interface icon-theme "$icon_theme"
    gsettings set org.gnome.desktop.interface cursor-theme "$cursor_theme"
    gsettings set org.gnome.desktop.interface cursor-size "$cursor_size"
}

init_wallpaper() {
    if [[ -f "$wallpaper" ]]; then
        wallust run -s "$wallpaper" >/dev/null
        swww query || swww-daemon
        $swww_cmd "$wallpaper" $swww_effect
        "$scripts_dir/apps-wall-swww.sh" >/dev/null 2>&1 &
    fi
}

init_waybar() {
    if [[ -f "$waybar_style" ]]; then
        ln -sf "$waybar_style" "$HOME/.config/waybar/style.css"
        "$scripts_dir/hypr-refresh.sh" >/dev/null 2>&1 &
    fi
}

# === Main ===
sleep 1
init_wallpaper &
apply_gsettings &
kvantummanager --set "$kvantum_theme" >/dev/null 2>&1 &
"$scripts_dir/hypr-kb-switch.sh" >/dev/null 2>&1 &
sleep 2
init_waybar &

# Disable this script in execs.conf
sed -i '/exec-once = \$scriptsDir\/sys-boot/s/^/# /' "$HOME/.config/hypr/configs/execs.conf"

sleep 2
notify-send -e -u low -i "$notif_icon" "Boot script finished"
