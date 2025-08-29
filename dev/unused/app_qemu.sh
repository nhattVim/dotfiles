#!/bin/bash

# source library
. <(curl -sSL https://raw.githubusercontent.com/nhattVim/dotfiles/refs/heads/master/scripts/lib.sh)

pkgs=(
    qemu-system
    qemu-utils
    virt-manager
)

note "Installing qemu packages..."
for pkg in "${pkgs[@]}"; do
    iAur "$pkg"
done

note "Downloading archlinux iso..."
wget -O ~/archlinux-x86_64.iso https://mirror.rackspace.com/archlinux/iso/latest/archlinux-x86_64.iso

if [ -d /var/lib/libvirt/images/ ]; then
    note "Moving Arch ISO to /var/lib/libvirt/images/"
    sudo mv -f ~/archlinux-x86_64.iso /var/lib/libvirt/images/
else
    note "Libvirt not detected → keeping ISO in home directory"
fi

if [ -e /dev/kvm ]; then
    note "Adding user to kvm group..."
    sudo usermod -aG kvm "$(whoami)"
    newgrp kvm
    note "Run 'newgrp kvm' or log out/in to apply group changes"
else
    note "/dev/kvm not available → running in pure emulation mode (slow)"
fi
