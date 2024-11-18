#!/bin/sh

ARTTIME="https://github.com/poetaman/arttime/releases/download/v2.3.4/arttime_2.3.4-1_all.deb"
printf "\n%s - Installing starship.... \n" "${NOTE}"
if wget -qO /tmp/arttime.deb "$ARTTIME"; then
    printf "$(tput setaf 2)[OK]$(tput sgr0) Download gum.deb successfully"
    if sudo $PKGMN install -y /tmp/gum.deb; then
        printf "$(tput setaf 2)[OK]$(tput sgr0) Install gum successfully"
    else
        printf "$(tput setaf 1)[ERROR]$(tput sgr0) - gum install had failed"
    fi
else
    printf "$(tput setaf 1)[ERROR]$(tput sgr0) Failed to install gum"
fi
