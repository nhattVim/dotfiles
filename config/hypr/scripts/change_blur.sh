#!/bin/bash
## Script for changing blurs on the fly

notif="$HOME/.config/swaync/images/bell.png"

STATE=$(hyprctl -j getoption decoration:blur:passes | jq ".int")

if [ "${STATE}" == "0" ]; then
	hyprctl keyword decoration:blur:size 2
	hyprctl keyword decoration:blur:passes 1
	notify-send -e -u low -i "$notif" "Less blur"
elif [ "${STATE}" == "1" ]; then
	hyprctl keyword decoration:blur:size 5
	hyprctl keyword decoration:blur:passes 2
	notify-send -e -u low -i "$notif" "Normal blur"
else
	hyprctl keyword decoration:blur:size 0
	hyprctl keyword decoration:blur:passes 0
	notify-send -e -u low -i "$notif" "No blur"
fi
