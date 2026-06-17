#!/bin/bash
# Unified Installation Script for Hyprland Environment

# Source library
. <(curl -sSL https://raw.githubusercontent.com/nhattVim/dotfiles/refs/heads/master/scripts/lib.sh)

# pkgs
pkgs=(

    # ----------------------------------------------------
    # Core System & Development
    # ----------------------------------------------------
    curl git wget make openssh net-tools jdk-openjdk npm
    nodejs rustup tree-sitter-cli

    # ----------------------------------------------------
    # Shells, Terminal & CLI
    # ----------------------------------------------------
    zsh tmux kitty vim neovim neovide ripgrep trash-cli
    translate-shell unzip zip aria2 bat btop fastfetch fd
    fzf jq lazygit lsd ranger

    # ----------------------------------------------------
    # Hyprland & Wayland Ecosystem
    # ----------------------------------------------------
    hyprland hyprcursor hyprpicker hyprpaper hyprlock
    hyprshutdown grim slurp wl-clipboard cliphist wlsunset
    qt6-declarative qt6-wayland quickshell-git

    # ----------------------------------------------------
    # Audio, Power & Hardware
    # ----------------------------------------------------
    pipewire wireplumber upower networkmanager
    power-profiles-daemon brightnessctl

    # ----------------------------------------------------
    # System Utilities
    # ----------------------------------------------------
    gnome-disk-utility gnome-system-monitor imagemagick
    libnotify nwg-look polkit-gnome qalculate-gtk

    # ----------------------------------------------------
    # Themes & Icons
    # ----------------------------------------------------
    adw-gtk-theme papirus-icon-theme

    # ----------------------------------------------------
    # Multimedia
    # ----------------------------------------------------
    cava eog ffmpeg gpu-screen-recorder mpv mpv-mpris
    yt-dlp

    # ----------------------------------------------------
    # GUI Applications
    # ----------------------------------------------------
    mousepad

    # ----------------------------------------------------
    # Fonts
    # ----------------------------------------------------
    hicolor-icon-theme
    papirus-icon-theme
    noto-fonts-emoji
)

# ==============================================================================
# Packages to Remove (Conflicts)
# ==============================================================================

uninstall_pkgs=(
    aylurs-gtk-shell
    cachyos-hyprland-settings
    dunst
    hyprland-git
    hyprland-nvidia
    hyprland-nvidia-git
    hyprland-nvidia-hidpi-git
    mako
    rofi
    wallust-git
)

# Cleanup conflicting packages
note "Removing conflicting packages..."
for pkg in "${uninstall_pkgs[@]}"; do
    uninstall_arch_pkg "$pkg"
done

# Install packages
note "Installing packages..."
for pkg in "${pkgs[@]}"; do
    install_arch_pkg "$pkg"
done

# ==============================================================================
# Post-Install Setup
# ==============================================================================

# Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    act "Installing Oh My Zsh..."
    sh -c "$(wget -O- https://install.ohmyz.sh)" "" --unattended && {
        git clone https://github.com/zsh-users/zsh-autosuggestions \
            "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
        ok "Oh My Zsh configured"
    } || err "Oh My Zsh installation failed"
else
    note "Oh My Zsh already installed"
fi

# TPM - Tmux Plugin Manager
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    act "Installing TPM..."
    git clone https://github.com/tmux-plugins/tpm \
        "$HOME/.tmux/plugins/tpm" --depth 1 && ok "TPM installed"
else
    note "TPM already installed"
fi

# Rustup
act "Configuring Rustup..."
rustup default stable && {
    ok "Configuring Rustup completed"
} || {
    err "Failed to configure Rustup"
}

ok "All packages installed successfully!"

# Cleaning packages
note "Cleaning package cache..."
sudo pacman -Sc --noconfirm

if [[ "$ISAUR" == "yay" ]]; then
    yay -Sc --noconfirm
    yay -Yc --noconfirm
elif [[ "$ISAUR" == "paru" ]]; then
    paru -Sc --noconfirm
    paru -c --noconfirm
fi
