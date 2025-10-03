#!/bin/bash

cache_dir="$HOME/.cache/swww/"

monitor_outputs=($(ls "$cache_dir"))

ln_success=false

current_monitor=$(hyprctl monitors | awk '/^Monitor/{name=$2} /focused: yes/{print name}')
echo $current_monitor

cache_file="$cache_dir$current_monitor"
echo $cache_file

if [ -f "$cache_file" ]; then
    wallpaper_path=$(strings "$cache_file" | grep '^/' | head -n 1)
    echo $wallpaper_path
    if ln -sf "$wallpaper_path" "$HOME/.cache/swww/.current_wallpaper"; then
        ln_success=true
    fi
fi

if [ "$ln_success" = true ]; then
    echo 'about to execute wallust'
    wallust run "$wallpaper_path" -s &
fi
