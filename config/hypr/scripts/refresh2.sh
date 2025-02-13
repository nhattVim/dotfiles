#!/bin/bash

# Modified version of refresh.sh but waybar wont refresh
# Used by automatic wallpaper change
# Modified inorder to refresh rofi background, Wallust, SwayNC only

SCRIPTSDIR=$HOME/.config/hypr/scripts

# Define file_exists function
file_exists() {
    if [ -e "$1" ]; then
        return 0 # File exists
    else
        return 1 # File does not exist
    fi
}

# Kill already running processes
_ps=(rofi)
for _prs in "${_ps[@]}"; do
    if pidof "${_prs}" >/dev/null; then
        pkill "${_prs}"
    fi
done

# quit ags & relaunch ags
ags -q && ags &

# Wallust refresh
${SCRIPTSDIR}/wallust_swww.sh &

# Relaunching rainbow borders if the script exists
sleep 1
if file_exists "${SCRIPTSDIR}/rainbow_borders.sh"; then
    ${SCRIPTSDIR}/rainbow_borders.sh &
fi

exit 0
