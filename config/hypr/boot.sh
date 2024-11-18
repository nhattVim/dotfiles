#!/bin/bash
# A bash script designed to run only once dotfiles installed

# THIS SCRIPT CAN BE DELETED ONCE SUCCESSFULLY BOOTED!! And also, edit ~/.config/hypr/configs/execs.conf
# not necessary to do since this script is only designed to run only once as long as the marker exists
# However, I do highly suggest not to touch it since again, as long as the marker exist, script wont run

# variables
scriptsDir=$HOME/.config/hypr/scripts
waybar_style="$HOME/.config/waybar/style/simple [pywal].css"
wallpaper=$HOME/Pictures/wallpapers/anime-kanji.jpg
notif="$HOME/.config/swaync/images/bell.png"
kvantum_theme="Tokyo-Night"

swww="swww img"
effect="--transition-bezier .43,1.19,1,.4 --transition-fps 30 --transition-type grow --transition-pos 0.925,0.977 --transition-duration 2"

# check if a marker file exists.
if [ ! -f ~/.config/hypr/.boot_done ]; then

	# initialize pywal and wallpaper
	if [ -f "$wallpaper" ]; then
		wal -i $wallpaper -s -t >/dev/null
		swww init && $swww $wallpaper $effect
		"$scriptsDir/pywal_swww.sh" >/dev/null 2>&1 &
	fi

	# initial symlink for Pywal Dark and Light for Rofi Themes
	ln -sf "$HOME/.cache/wal/colors-rofi-dark.rasi" "$HOME/.config/rofi/pywal-color/pywal-theme.rasi" >/dev/null 2>&1 &

	# initiate GTK dark mode and apply icon and cursor theme
	gsettings set org.gnome.desktop.interface color-scheme prefer-dark >/dev/null 2>&1 &
	gsettings set org.gnome.desktop.interface gtk-theme Tokyonight-Dark >/dev/null 2>&1 &
	gsettings set org.gnome.desktop.interface icon-theme Tokyonight-SE >/dev/null 2>&1 &
	gsettings set org.gnome.desktop.interface cursor-theme Bibata-Modern-Ice >/dev/null 2>&1 &
	gsettings set org.gnome.desktop.interface cursor-size 24 >/dev/null 2>&1 &

	# initiate kvantum theme
	kvantummanager --set "$kvantum_theme" >/dev/null 2>&1 &

	# initiate the kb_layout (for some reason) waybar cant launch it
	"$scriptsDir/switch_kb_layout.sh" >/dev/null 2>&1 &

	# initial waybar style
	if [ -f "$waybar_style" ]; then
		ln -sf "$waybar_style" "$HOME/.config/waybar/style.css"

		sleep 1
		# refreshing waybar, swaync, rofi etc.
		"$scriptsDir/refresh.sh" >/dev/null 2>&1 &
	fi

	# install snap store
	if command -v snap &>/dev/null; then
		if ! snap list | grep -q 'snap-store'; then
			notify-send -e -u low -i "$notif" "  Installing snap-store"
			snap install snap-store && snap install snapd-desktop-integration || {
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

	# Create a marker file to indicate that the script has been executed.
	touch ~/.config/hypr/.boot_done

	exit
fi
