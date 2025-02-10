#!/bin/bash
# set battery charge limit

# source library
# . <(curl -sSL https://is.gd/nhattVim_lib)
. <(curl -sSL https://raw.githubusercontent.com/nhattVim/dotfiles/master/scripts/lib.sh)

# start script
note "Setting up battery charge limit."

if hostnamectl | grep -q 'Chassis: vm' ||
    hostnamectl | grep -q 'Virtualization: wsl' ||
    hostnamectl | grep -q 'Chassis: desktop'; then
    err "Setting up battery charge limit is not applicable on desktop, virtual machine and vm. Skipping..."
    exit 1
fi

while true; do

    number=$(gum input --prompt="-> " --width 80 --placeholder "Enter the battery charge limit (0 - 100):")

    if [[ "$number" =~ ^[0-9]+$ && "$number" -ge 0 && "$number" -le 100 ]]; then
        if [[ -d "/sys/class/power_supply/BAT0" ]]; then
            battery="BAT0"
        elif [[ -d "/sys/class/power_supply/BAT1" ]]; then
            battery="BAT1"
        else
            err "Battery not found."
            exit 1
        fi

        act "Configuring systemd unit for $battery..."
        {
            echo "[Unit]"
            echo "Description=Set battery charge limit for $battery"
            echo "After=multi-user.target"
            echo ""
            echo "[Service]"
            echo "Type=oneshot"
            echo "ExecStart=/bin/bash -c 'echo $number > /sys/class/power_supply/$battery/charge_control_end_threshold'"
            echo ""
            echo "[Install]"
            echo "WantedBy=multi-user.target"
        } | sudo tee "/etc/systemd/system/charge_limit_battery.service" >/dev/null

        sudo systemctl enable --now charge_limit_battery.service

        ok "Done."
        break
    else
        err "Invalid input. Please enter a valid number between 0 and 100."
    fi
done
