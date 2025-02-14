#!/bin/sh

# File to mark toggle state
TOGGLE=$HOME/.cache/.gammastep_toggle

# Location (Quy Nhon, Binh Dinh, Vietnam)
LAT=13.782
LON=109.219

# Night light color temperature
TEMP_NIGHT=3500

# Get flags
while getopts t flag; do
    case "${flag}" in
    t) toggle=1 ;; # If -t is set, enable toggle mode
    esac
done

# If -t is set, toggle on/off
if [ "$toggle" = "1" ]; then
    # If toggle file does not exist, turn on night light
    if [ ! -e $TOGGLE ]; then
        touch $TOGGLE
        gammastep -l $LAT:$LON -O $TEMP_NIGHT -m wayland &
    else
        # If toggle file exists, turn off night light
        rm $TOGGLE
        pkill gammastep
    fi
    exit 0
fi

# If -t is not set, check state and run in background
if [ ! -e $TOGGLE ]; then
    touch $TOGGLE
    gammastep -l $LAT:$LON -O $TEMP_NIGHT -m wayland &
fi
