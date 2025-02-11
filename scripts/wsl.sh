#!/bin/bash

# Source library
. <(curl -sSL https://is.gd/nhattVim_lib) && clear

# Check if the system is running under WSL
if grep -qi 'microsoft' /proc/sys/kernel/osrelease; then
    # Determine the distribution
    . /etc/os-release
    case $ID in
    ubuntu)
        exWsl "ubuntu.sh"
        ;;
    arch)
        exWsl "arch.sh"
        ;;
    *)
        err "This script is only available on Ubuntu or Arch distributions."
        ;;
    esac
else
    note "This script is only available under Windows Subsystem for Linux (WSL)."
fi
