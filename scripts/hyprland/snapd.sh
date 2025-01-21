#!/bin/bash
# Snapd

# source library
. <(curl -sSL https://is.gd/nhattVim_lib)

# start script
cd $HOME
if [ -d snapd ]; then
    rm -rf snapd
fi

if command -v snap &>/dev/null; then
    ok "Snap already installed, moving on."
    exit 1
else
    note "Snap was NOT located. Installing snap ..."
    git clone https://aur.archlinux.org/snapd.git || {
        err "Failed to clone snap"
        exit 1
    }
    cd snapd || {
        err "Failed to enter snapd directory"
        exit 1
    }
    makepkg -si --noconfirm || {
        err "Failed to install snap"
        exit 1
    }
    cd ~ && rm -rf snapd || {
        err "Failed to remove snapd directory"
        exit 1
    }
fi

# install snapd
note "Installing snapd"
iAur snapd

# setup snapd before proceeding
note "Set up snap ..."
sudo systemctl enable --now snapd.socket && sudo ln -s /var/lib/snapd/snap /snap && systemctl enable --now snapd.apparmor || {
    err "Failed to setup snap"
    exit 1
}
