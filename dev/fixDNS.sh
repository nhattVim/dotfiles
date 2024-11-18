#!/bin/bash

# source library
source <(curl -sSL https://is.gd/nhattruongNeoVim_lib)

# fix DNS on wsl
if [ -f "/etc/resolv.conf" ]; then
    printf "\n%s - Fix DNS to 8.8.8.8 \n" "${NOTE}"
    if grep -q "nameserver" "/etc/resolv.conf"; then
        if sudo sed -i 's/nameserver.*/nameserver 8.8.8.8/' "/etc/resolv.conf"; then
            printf "\n%s - Fix DNS successfully \n" "${OK}"
        else
            printf "\n%s - Failed to fix DNS \n" "${ERROR}"
        fi
    fi
fi

# configure wsl.conf on wsl
if [ -f "/etc/wsl.conf" ]; then
    printf "\n%s - Configuring /etc/wsl.conf \n" "${NOTE}"
    if ! grep -q "\[network\]" "/etc/wsl.conf"; then
        if echo -e "\n[network]\ngenerateResolvConf = false" | sudo tee -a "/etc/wsl.conf" >/dev/null; then
            printf "\n%s - Added network configuration to /etc/wsl.conf \n" "${OK}"
        else
            printf "\n%s - Failed to add network configuration to /etc/wsl.conf \n" "${ERROR}"
        fi
    fi
fi
