#!/bin/bash

# Color setup
# RED="$(tput setaf 1)"
# GREEN="$(tput setaf 2)"
# YELLOW=$(tput setaf 3)
# CYAN="$(tput setaf 6)"
# PINK=$(tput setaf 5)
# RESET=$(tput sgr0)

RED="\e[91m"    # Đỏ sáng
GREEN="\e[92m"  # Xanh lá sáng
YELLOW="\e[93m" # Vàng sáng
BLUE="\e[94m"   # Xanh bắng
CYAN="\e[96m"   # Xanh lơ sáng
PINK="\e[95m"   # Magenta sáng (gần với hồng nhất)
RESET="\e[0m"   # Reset màu về mặc định

# Logging functions
ok() { echo -e "\n${GREEN}[OK]${RESET} - $1\n"; }
err() { echo -e "\n${RED}[ERROR]${RESET} - $1\n"; }
act() { echo -e "\n${CYAN}[ACTION]${RESET} - $1\n"; }
note() { echo -e "\n${YELLOW}[NOTE]${RESET} - $1\n"; }
