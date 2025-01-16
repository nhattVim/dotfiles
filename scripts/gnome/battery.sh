#!/bin/bash
# set battery charge limit

# source library
source <(curl -sSL https://is.gd/nhattVim_lib)

# start script
note "Setting up battery charge limit"

if hostnamectl | grep -q 'Chassis: vm' ||
    hostnamectl | grep -q 'Chassis: container' ||
    hostnamectl | grep -q 'Chassis: desktop'; then
    err "Setting up battery charge limit is not applicable on desktop, container and vm. Skipping..."
    exit 1
fi

while true; do

    number=$(gum input --prompt="-> " --width 80 --placeholder "Enter the battery charge limit (0 - 100):")

    if [[ "$number" =~ ^[0-9]+$ && "$number" -ge 0 && "$number" -le 100 ]]; then
        if [ -d "/sys/class/power_supply/BAT1" ]; then
            act "Configuring crontab for BAT1..."
            echo "@reboot root echo $number > /sys/class/power_supply/BAT1/charge_control_end_threshold" | sudo tee -a /etc/crontab
        elif [ -d "/sys/class/power_supply/BAT0" ]; then
            act "Configuring crontab for BAT0..."
            echo "@reboot root echo $number > /sys/class/power_supply/BAT0/charge_control_end_threshold" | sudo tee -a /etc/crontab
        else
            err "Battery not found"
            exit 1
        fi
        ok "Done."
        break
    else
        err "Invalid input. Please enter a valid number between 0 and 100."
    fi
done
