#!/bin/bash
# Snapd Installer with Retry Mechanism

# Source library
. <(curl -sSL https://is.gd/nhattVim_lib)

if command -v snap &>/dev/null; then
    ok "Snap already installed, moving on."
else
    note "Snap was NOT located. Installing snap ..."
    iAur snapd
    if [ $? -ne 0 ]; then
        exit 1
    fi
fi

# Setup snapd before proceeding
act "Enabling snap..."
if sudo systemctl enable --now snapd; then
    ok "Snap setup completed successfully!"
else
    err "Failed to enable snapd"
fi

# act "Installing snap-store..."
# if export PATH="$PATH:/var/lib/snapd/snap/bin" && sudo snap install snap-store &&
#     sudo snap install snapd-desktop-integration; then
#     ok "Install snap-store successfully"
# else
#     err "Failed to install snap-store"
# fi
