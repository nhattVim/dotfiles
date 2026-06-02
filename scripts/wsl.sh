#!/bin/bash

# Source library
. <(curl -sSL https://raw.githubusercontent.com/nhattVim/dotfiles/refs/heads/master/scripts/lib.sh) && clear

# Check if the system is running under WSL
if grep -qi 'microsoft' /proc/sys/kernel/osrelease; then
    # Determine the distribution
    . /etc/os-release
    case $ID in
    ubuntu)
        run_wsl_script "ubuntu.sh"
        ;;
    arch)
        run_wsl_script "arch.sh"
        ;;
    *)
        err "This script is only available on Ubuntu or Arch distributions."
        ;;
    esac
else
    note "This script is only available under Windows Subsystem for Linux (WSL)."
fi
