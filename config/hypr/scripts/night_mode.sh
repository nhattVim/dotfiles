#!/bin/sh

# Mark toggle
TOGGLE=$HOME/.cache/.gammastep_toggle

# Location
LAT=13.782
LON=109.219

# Get flags
while getopts t flag; do
    case "${flag}" in
    t) toggle=1 ;;
    esac
done

# flag -t : toggle on/off
if [ "$toggle" = "1" ]; then
    if [ ! -e $TOGGLE ]; then
        touch $TOGGLE
        gammastep -l $LAT:$LON -m wayland &
    else
        rm $TOGGLE
        pkill gammastep
    fi
    exit 0
fi

# flag -t not set
if [ ! -e $TOGGLE ]; then
    touch $TOGGLE
    gammastep -l $LAT:$LON -m wayland &
fi
