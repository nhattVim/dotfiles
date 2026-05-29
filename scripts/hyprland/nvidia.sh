#!/bin/bash
# NVIDIA Setup for Arch Linux / Hyprland

# Source library
. <(curl -sSL https://raw.githubusercontent.com/nhattVim/dotfiles/refs/heads/master/scripts/lib.sh)

# Variables
nvidia_pkgs=(
    nvidia-dkms
    nvidia-settings
    nvidia-utils
    lib32-nvidia-utils
    egl-wayland
    libva
    libva-nvidia-driver
)

# Install kernel headers
note "Installing kernel headers..."
while read -r kernel; do
    iPac "${kernel}-headers"
done < <(cat /usr/lib/modules/*/pkgbase)

# Install NVIDIA packages
note "Installing NVIDIA packages..."
for pkg in "${nvidia_pkgs[@]}"; do
    iPac "$pkg"
done

# Configure mkinitcpio
note "Configuring mkinitcpio..."

modules=$(sed -n 's/^MODULES=(\(.*\))/\1/p' \
    /etc/mkinitcpio.conf | head -n 1)

missing=()

for mod in nvidia nvidia_modeset nvidia_uvm nvidia_drm; do
    [[ " $modules " =~ [[:space:]]$mod[[:space:]] ]] ||
        missing+=("$mod")
done

if ((${#missing[@]})); then
    sudo sed -Ei \
        "0,/^MODULES=\((.*)\)/s//MODULES=(\1 ${missing[*]})/" \
        /etc/mkinitcpio.conf

    sudo sed -Ei \
        '0,/^MODULES=\( /s//MODULES=\(/' \
        /etc/mkinitcpio.conf

    ok "Added NVIDIA modules: ${missing[*]}"
else
    ok "NVIDIA modules already configured"
fi

# Enable DRM modesetting
NVIDIA_CONF="/etc/modprobe.d/nvidia.conf"

if grep -q "^options nvidia_drm modeset=1" \
    "$NVIDIA_CONF" 2>/dev/null; then

    ok "nvidia_drm modeset already enabled"
else
    note "Enabling nvidia_drm modeset..."

    echo "options nvidia_drm modeset=1" |
        sudo tee "$NVIDIA_CONF" >/dev/null

    ok "Created $NVIDIA_CONF"
fi

# Configure systemd-boot
if [ -d /boot/loader/entries ]; then
    note "systemd-boot detected"

    while IFS= read -r entry; do

        # Backup once
        [ -f "${entry}.bak" ] ||
            sudo cp "$entry" "${entry}.bak"
        if ! grep -q "nvidia_drm.modeset=1" "$entry"; then

            # Remove old/broken values
            sudo sed -Ei \
                's/\bnvidia_drm\.modeset=[^ ]*//g' \
                "$entry"

            # Append correct parameter
            sudo sed -Ei \
                's/^options.*/& nvidia_drm.modeset=1/' \
                "$entry"

            # Normalize spaces
            sudo sed -Ei \
                '/^options/s/ +/ /g' \
                "$entry"

            ok "Updated: $(basename "$entry")"
        fi

    done < <(find /boot/loader/entries \
        -type f -name "*.conf")
fi

# Configure GRUB
if [ -f /etc/default/grub ]; then

    note "GRUB detected"

    if ! grep -q "nvidia_drm.modeset=1" \
        /etc/default/grub; then

        sudo sed -Ei \
            's/^(GRUB_CMDLINE_LINUX_DEFAULT=".*)"/\1 nvidia_drm.modeset=1"/' \
            /etc/default/grub

        sudo grub-mkconfig -o /boot/grub/grub.cfg

        ok "Added nvidia_drm.modeset=1 to GRUB"
    else
        ok "GRUB already configured"
    fi
fi

# Blacklist nouveau
if gum confirm "${CYAN}Would you like to blacklist nouveau?${RESET}"; then

    NOUVEAU_CONF="/etc/modprobe.d/nouveau.conf"

    if grep -q "^blacklist nouveau" \
        "$NOUVEAU_CONF" 2>/dev/null; then
        ok "nouveau already blacklisted"
    else
        note "Blacklisting nouveau..."

        {
            echo "blacklist nouveau"
            echo "options nouveau modeset=0"
        } | sudo tee "$NOUVEAU_CONF" >/dev/null

        ok "Created $NOUVEAU_CONF"
    fi

    BLACKLIST_CONF="/etc/modprobe.d/blacklist.conf"

    if ! grep -q "^install nouveau /bin/true" \
        "$BLACKLIST_CONF" 2>/dev/null; then

        echo "install nouveau /bin/true" |
            sudo tee -a "$BLACKLIST_CONF" >/dev/null

        ok "Added install nouveau /bin/true"
    fi

else
    note "Skipping nouveau blacklist."
fi

# Rebuild initramfs
note "Rebuilding initramfs..."
sudo mkinitcpio -P
ok "Initramfs rebuilt"

# Done
ok "NVIDIA setup completed successfully!"
