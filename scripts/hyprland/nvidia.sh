#!/bin/bash

# source library
source <(curl -sSL https://is.gd/nhattVim_lib)

# start
nvidia_pkg=(
    nvidia-dkms
    nvidia-settings
    nvidia-utils
    libva
    libva-nvidia-driver
)

# Install additional Nvidia packages
note "Installing additional Nvidia packages..."
for krnl in $(cat /usr/lib/modules/*/pkgbase); do
    for NVIDIA in "${krnl}-headers" "${nvidia_pkg[@]}"; do
        iAur "$NVIDIA"
        if [ $? -ne 0 ]; then
            err "$PKG1 install had failed"
        fi
    done
done

note "Installing Nvidia Packages and Linux headers..."
for krnl in $(cat /usr/lib/modules/*/pkgbase); do
    for NVIDIA in "${krnl}-headers" "${nvidia_pkg[@]}"; do
        iAur "$NVIDIA"
        if [ $? -ne 0 ]; then
            err "$PKG1 install had failed"
        fi
    done
done

# Check if the Nvidia modules are already added in mkinitcpio.conf and add if not
if grep -qE '^MODULES=.*nvidia. *nvidia_modeset.*nvidia_uvm.*nvidia_drm' /etc/mkinitcpio.conf; then
    echo "Nvidia modules already included in /etc/mkinitcpio.conf"
else
    sudo sed -Ei 's/^(MODULES=\([^\)]*)\)/\1 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
    echo "Nvidia modules added in /etc/mkinitcpio.conf"
fi

sudo mkinitcpio -P

printf "\n%.0s" {1..3}

# Additional Nvidia steps
NVEA="/etc/modprobe.d/nvidia.conf"
if [ -f "$NVEA" ]; then
    ok "Seems like nvidia-drm modeset=1 is already added in your system. Moving on."
else
    note "Adding options to $NVEA..."
    sudo echo -e "options nvidia-drm modeset=1 fbdev=1" | sudo tee -a /etc/modprobe.d/nvidia.conf
fi

# additional for GRUB users
# Check if /etc/default/grub exists
if [ -f /etc/default/grub ]; then
    # Check if nvidia_drm.modeset=1 is already present
    if ! sudo grep -q "nvidia-drm.modeset=1" /etc/default/grub; then
        sudo sed -i -e 's/\(GRUB_CMDLINE_LINUX_DEFAULT=".*\)"/\1 nvidia-drm.modeset=1"/' /etc/default/grub
        echo "nvidia-drm.modeset=1 added to /etc/default/grub"
    fi

    # Check if nvidia_drm.fbdev=1 is present
    if ! sudo grep -q "nvidia_drm.fbdev=1" /etc/default/grub; then
        sudo sed -i -e 's/\(GRUB_CMDLINE_LINUX_DEFAULT=".*\)"/\1 nvidia_drm.fbdev=1"/' /etc/default/grub
        echo "nvidia_drm.fbdev=1 added to /etc/default/grub"
    fi

    # Regenerate GRUB configuration
    if sudo grep -q "nvidia-drm.modeset=1" /etc/default/grub || sudo grep -q "nvidia_drm.fbdev=1" /etc/default/grub; then
        sudo grub-mkconfig -o /boot/grub/grub.cfg
    fi
else
    note "/etc/default/grub does not exist."
fi

# Blacklist nouveau
if gum confirm "${CYAN} Would you like to blacklist nouveau? ${RESET}"; then
    NOUVEAU="/etc/modprobe.d/nouveau.conf"
    if [ -f "$NOUVEAU" ]; then
        ok "Seems like nouveau is already blacklisted..moving on."
    else
        echo "blacklist nouveau" | sudo tee -a "$NOUVEAU"
        note "has been added to $NOUVEAU."

        # To completely blacklist nouveau (See wiki.archlinux.org/title/Kernel_module#Blacklisting 6.1)
        if [ -f "/etc/modprobe.d/blacklist.conf" ]; then
            echo "install nouveau /bin/true" | sudo tee -a "/etc/modprobe.d/blacklist.conf"
        else
            echo "install nouveau /bin/true" | sudo tee "/etc/modprobe.d/blacklist.conf"
        fi
    fi
else
    note "Skipping nouveau blacklisting."
fi
