#!/bin/bash
# Rofi menu for Quick Edit / View of Settings (SUPER E)

configs="$HOME/.config/hypr/configs"

menu() {
	printf "1. view env_variables\n"
	printf "2. view window_rules\n"
	printf "3. view execs\n"
	printf "4. view monitors\n"
	printf "5. view keybinds\n"
	printf "6. view laptops\n"
	printf "7. view settings\n"
}

main() {
	choice=$(menu | rofi -dmenu -config ~/.config/rofi/config-compact.rasi | cut -d. -f1)
	case $choice in
	1)
		kitty -e nvim "$configs/env_variables.conf"
		;;
	2)
		kitty -e nvim "$configs/window_rules.conf"
		;;
	3)
		kitty -e nvim "$configs/execs.conf"
		;;
	4)
		kitty -e nvim "$configs/monitors.conf"
		;;
	5)
		kitty -e nvim "$configs/keybinds.conf"
		;;
	6)
		kitty -e nvim "$configs/laptop.conf"
		;;
	7)
		kitty -e nvim "$configs/settings.conf"
		;;
	*) ;;
	esac
}

main
