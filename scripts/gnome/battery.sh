#!/bin/bash
# set battery charge limit

# source library
source <(curl -sSL https://is.gd/nhattruongNeoVim_lib)

# start script
printf "\n%s - Setting up battery charge limit. \n" "${NOTE}"

if hostnamectl | grep -q 'Chassis: vm' ||
    hostnamectl | grep -q 'Chassis: container' ||
    hostnamectl | grep -q 'Chassis: desktop'; then
    printf "\n%s - Setting up battery charge limit is not applicable on desktop, container and vm. Skipping... \n" "${NOTE}"
    exit 1
fi

while true; do

    number=$(gum input --prompt="-> " --width 80 --placeholder "Enter the battery charge limit (0 - 100):")

    if [[ "$number" =~ ^[0-9]+$ && "$number" -ge 0 && "$number" -le 100 ]]; then
        if [ -d "/sys/class/power_supply/BAT1" ]; then
            printf "\n%s - Configuring crontab for BAT1... \n" "${CAT}"
            echo "@reboot root echo $number > /sys/class/power_supply/BAT1/charge_control_end_threshold" | sudo tee -a /etc/crontab
        elif [ -d "/sys/class/power_supply/BAT0" ]; then
            printf "\n%s - Configuring crontab for BAT0... \n" "${CAT}"
            echo "@reboot root echo $number > /sys/class/power_supply/BAT0/charge_control_end_threshold" | sudo tee -a /etc/crontab
        else
            printf "\n%s - Battery not found. \n" "${ERROR}"
            exit 1
        fi
        printf "\n%s - Done \n" "${OK}"
        break
    else
        printf "\n%s - Invalid input. Please enter a valid number between 0 and 100. \n" "${ERROR}"
    fi
done
