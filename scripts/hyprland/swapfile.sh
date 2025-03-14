#!/bin/bash
# set swapfile

# source library
. <(curl -sSL https://raw.githubusercontent.com/nhattVim/dotfiles/refs/heads/master/scripts/lib.sh)

# start script
if ! gum confirm "${YELLOW} Do you want to set up swapfile? ${RESET}"; then
    exit 1
fi

note "Setting up swapfile."

total_ram=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
recommended_size=$((((total_ram / 1024 / 1024) + 1) / 2))

if [[ -f "/swapfile" ]]; then
    if gum confirm "${PINK} Swap file already exists. Do you want to delete old swapfile? ${RESET}"; then
        sudo swapoff /swapfile
        sudo rm -f /swapfile
        ok "Old swapfile deleted."

        if grep -q "/swapfile" /etc/fstab; then
            sudo sed -i '/swapfile/d' /etc/fstab
            ok "Old swapfile deleted and removed from /etc/fstab."
        fi
    else
        exit 1
    fi
fi

while true; do
    read -rep "${PINK} Enter the size of swapfile(GB), recommend ${recommended_size}(GB): ${RESET}" number
    if [[ "$number" =~ ^[1-9][0-9]*$ && "$number" -le 100 ]]; then

        act "Creating swapfile of ${number}GB..."
        if sudo dd if=/dev/zero of=/swapfile bs=1G count="$number" status=progress >/dev/null && sudo chmod 600 /swapfile >/dev/null; then
            ok "Created and permissioned swapfile successfully."
        else
            err "Failed to create swapfile or set permissions."
            exit 1
        fi

        act "Formatting and activating swapfile..."
        if sudo mkswap -U clear /swapfile >/dev/null && sudo swapon /swapfile >/dev/null; then
            ok "Formatted and activated swapfile successfully."
        else
            err "Failed to format and activate swapfile."
            exit 1
        fi

        if [[ ! -f "/etc/fstab" ]]; then
            printf "\n%.0s" {1..2}
            err "/etc/fstab not found."
            exit 1
        fi

        act "Configuring /etc/fstab..."
        if echo "/swapfile none swap defaults 0 0" | sudo tee -a /etc/fstab >/dev/null; then
            ok "Done"
        else
            err "Failed to configure /etc/fstab."
            exit 1
        fi

        break
    else
        err "Invalid input. Please enter a valid number between 0 and 100."
    fi
done
