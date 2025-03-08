#!/bin/bash

# source library
. <(curl -sSL https://raw.githubusercontent.com/nhattVim/dotfiles/refs/heads/master/scripts/lib.sh)

# start
nvidia_pkg=(
    nvidia-dkms
    nvidia-settings
    nvidia-utils
    libva
    libva-nvidia-driver
)

# Install additional Nvidia packages
note "Installing Nvidia Packages and Linux headers..."
for krnl in $(cat /usr/lib/modules/*/pkgbase); do
    for NVIDIA in "${krnl}-headers" "${nvidia_pkg[@]}"; do
        iAur "$NVIDIA"
    done
done

# Check if the Nvidia modules are already added in mkinitcpio.conf and add if not
if grep -qE '^MODULES=.*nvidia. *nvidia_modeset.*nvidia_uvm.*nvidia_drm' /etc/mkinitcpio.conf; then
    echo "Nvidia modules already included in /etc/mkinitcpio.conf"
else
    sudo sed -Ei 's/^(MODULES=\([^\)]*)\)/\1 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
    echo "Nvidia modules added in /etc/mkinitcpio.conf"
fi

# Rebuild Initramfs
note "Rebuilding Initramfs ..."
sudo mkinitcpio -P

# Additional Nvidia steps
NVEA="/etc/modprobe.d/nvidia.conf"
if [ -f "$NVEA" ]; then
    ok "Seems like nvidia-drm modeset=1 is already added in your system. Moving on."
else
    note "Adding options to $NVEA..."
    sudo echo -e "options nvidia-drm modeset=1 fbdev=1" | sudo tee -a /etc/modprobe.d/nvidia.conf
fi

# Additional for GRUB users
if [ -f /etc/default/grub ]; then
    # Check if nvidia_drm.modeset=1 is already present
    if ! sudo grep -q "nvidia-drm.modeset=1" /etc/default/grub; then
        sudo sed -i -e 's/\(GRUB_CMDLINE_LINUX_DEFAULT=".*\)"/\1 nvidia-drm.modeset=1"/' /etc/default/grub
        ok "nvidia-drm.modeset=1 added to /etc/default/grub"
    fi

    # Check if nvidia_drm.fbdev=1 is present
    if ! sudo grep -q "nvidia_drm.fbdev=1" /etc/default/grub; then
        sudo sed -i -e 's/\(GRUB_CMDLINE_LINUX_DEFAULT=".*\)"/\1 nvidia_drm.fbdev=1"/' /etc/default/grub
        ok "nvidia_drm.fbdev=1 added to /etc/default/grub"
    fi

    # Regenerate GRUB configuration
    if sudo grep -q "nvidia-drm.modeset=1" /etc/default/grub || sudo grep -q "nvidia_drm.fbdev=1" /etc/default/grub; then
        sudo grub-mkconfig -o /boot/grub/grub.cfg
        ok "Grub configuration regenerated"
    fi

    ok "Additional steps for GRUB completed"
else
    note "/etc/default/grub does not exist."
fi

# Additional for systemd-boot users
if [ -f /boot/loader/loader.conf ]; then
    note "systemd-boot bootloader detected"

    backup_count=$(find /boot/loader/entries/ -type f -name "*.conf.bak" | wc -l)
    conf_count=$(find /boot/loader/entries/ -type f -name "*.conf" | wc -l)

    if [ "$backup_count" -ne "$conf_count" ]; then
        find /boot/loader/entries/ -type f -name "*.conf" | while read imgconf; do

            # Backup conf
            act "Backup created for systemd-boot loader: $imgconf"
            sudo cp "$imgconf" "$imgconf.bak"

            # Clean up options and update with NVIDIA settings
            sdopt=$(grep -w "^options" "$imgconf" | sed 's/\b nvidia-drm.modeset=[^ ]*\b//g' | sed 's/\b nvidia_drm.fbdev=[^ ]*\b//g')
            sudo sed -i "/^options/c${sdopt} nvidia-drm.modeset=1 nvidia_drm.fbdev=1" "$imgconf"
        done

        ok "Additional steps for systemd-boot completed"
    else
        ok "systemd-boot is already configured"
    fi
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
