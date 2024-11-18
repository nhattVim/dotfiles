#!/bin/bash
# source https://wiki.archlinux.org/title/Hyprland#Using_a_script_to_change_wallpaper_every_X_minutes

# This script will randomly go through the files of a directory, setting it
# up as the wallpaper at regular intervals
#
# NOTE: this script uses bash (not POSIX shell) for the RANDOM variable

pywal_script=$HOME/.config/hypr/scripts/pywal_swww.sh
pywal_refresh=$HOME/.config/hypr/scripts/refresh.sh

if [[ $# -lt 1 ]] || [[ ! -d $1 ]]; then
	echo "Usage:
	$0 <dir containing images>"
	exit 1
fi

# Edit below to control the images transition
export SWWW_TRANSITION_FPS=60
export SWWW_TRANSITION_STEP=2
export SWWW_TRANSITION_TYPE=random

# This controls (in seconds) when to switch to the next image
INTERVAL=900

while true; do
	find "$1" |
		while read -r img; do
			echo "$((RANDOM % 1000)):$img"
		done |
		sort -n | cut -d':' -f2- |
		while read -r img; do
			swww img "$img"
			$pywal_script
			$pywal_refresh
			sleep $INTERVAL
		done
done
