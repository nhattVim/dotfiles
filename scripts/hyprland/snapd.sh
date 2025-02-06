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
        err "$pkg install had failed"
    fi
fi

# Setup snapd before proceeding
# note "Setting up snap ..."
# sudo systemctl enable --now snapd.socket || {
#     err "Failed to enable snapd"
# }

# Create /snap symlink
# if [ ! -e /snap ]; then
#     sudo ln -s /var/lib/snapd/snap /snap || {
#         err "Failed to create /snap symlink"
#     }
# fi

# Check for AppArmor
# if systemctl list-units --all --type=service | grep -q "snapd.apparmor"; then
#     sudo systemctl enable --now snapd.apparmor || {
#         err "Failed to enable snapd.apparmor"
#     }
# else
#     note "snapd.apparmor not available on this system."
# fi

ok "Snap setup completed successfully!"
