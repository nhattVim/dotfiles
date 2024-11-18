#!/bin/bash

# Source library
source <(curl -sSL https://is.gd/nhattruongNeoVim_lib) && clear

# Check if the system is running under WSL
if grep -qi 'microsoft' /proc/sys/kernel/osrelease; then
    # Determine the distribution
    . /etc/os-release
    case $ID in
    ubuntu)
        exScriptWsl "ubuntu.sh"
        ;;
    arch)
        exScriptWsl "arch.sh"
        ;;
    *)
        echo "${ERROR} This script is only available on Ubuntu or Arch distributions."
        ;;
    esac
else
    echo "${NOTE} This script is only available under Windows Subsystem for Linux (WSL)."
fi
