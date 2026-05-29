#!/bin/bash
# Unified Installation Script for Hyprland Environment

# Source library
. <(curl -sSL https://raw.githubusercontent.com/nhattVim/dotfiles/refs/heads/master/scripts/lib.sh)

# ==============================================================================
# Pacman Package
# ==============================================================================

pacman_pkgs=(

    # ----------------------------------------------------
    # Core System & Development
    # ----------------------------------------------------
    jdk-openjdk nodejs npm hyprland rustup

    # ----------------------------------------------------
    # Terminal & CLI Tools
    # ----------------------------------------------------
    tmux zsh fish kitty vim neovim make ripgrep fzf fd jq
    lazygit bat btop aria2 foot fastfetch ranger net-tools
    lsd translate-shell trash-cli zip unzip wl-clipboard
    tree-sitter-cli openssh cliphist

    # ----------------------------------------------------
    # System utilities
    # ----------------------------------------------------
    papirus-icon-theme adw-gtk-theme gnome-system-monitor
    nwg-look polkit-gnome

    # ----------------------------------------------------
    # Multimedia
    # ----------------------------------------------------
    mpv mpv-mpris yt-dlp ffmpeg

    # ----------------------------------------------------
    # GUI Applications
    # ----------------------------------------------------
    # discord telegram-desktop libreoffice-fresh
    neovide qalculate-gtk mousepad eog gnome-disk-utility

    # ----------------------------------------------------
    # Hyprland Ecosystem
    # ----------------------------------------------------
    hyprcursor hyprpolkitagent hyprpicker

    # ----------------------------------------------------
    # Fonts
    # ----------------------------------------------------
    otf-font-awesome
    adobe-source-code-pro-fonts
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    ttf-droid
    ttf-dejavu
    ttf-fira-code
    ttf-liberation
    ttf-jetbrains-mono
    ttf-jetbrains-mono-nerd
    ttf-nerd-fonts-symbols
)

# ==============================================================================
# AUR Package
# ==============================================================================

aur_pkgs=(

    # ----------------------------------------------------
    # Hyprland Ecosystem
    # ----------------------------------------------------
    # wlogout pyprland cava wallust papirus-icon-theme
    caelestia-shell

    # ----------------------------------------------------
    # Extras Packages
    # ----------------------------------------------------
    # arttime-git pipes.sh shell-color-scripts-git tty-clock
    # spotify
    # ferdium-bin
    # visual-studio-code-bin
    # onlyoffice-bin
    # vmware-workstation
    # xampp
    # mssql
    # mssql-tools
)

# ==============================================================================
# Packages to Remove (Conflicts)
# ==============================================================================

uninstall_pkgs=(
    dunst
    mako
    rofi
    wallust-git
    cachyos-hyprland-settings
    aylurs-gtk-shell
    hyprland-git
    hyprland-nvidia
    hyprland-nvidia-git
    hyprland-nvidia-hidpi-git
)

# Cleanup conflicting packages
note "Removing conflicting packages..."
for pkg in "${uninstall_pkgs[@]}"; do
    uPac "$pkg"
done

# Install pacman packages
note "Installing pacman packages..."
for pkg in "${pacman_pkgs[@]}"; do
    iPac "$pkg"
done

# Install AUR packages
note "Installing AUR packages..."
for pkg in "${aur_pkgs[@]}"; do
    iAur "$pkg"
done

# ==============================================================================
# Post-Install Setup
# ==============================================================================

# Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    act "Installing Oh My Zsh..."
    sh -c "$(wget -O- https://install.ohmyz.sh)" "" --unattended && {
        git clone https://github.com/zsh-users/zsh-autosuggestions \
            ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
        ok "Oh My Zsh configured"
    } || err "Oh My Zsh installation failed"
else
    note "Oh My Zsh already installed"
fi

# TPM (Tmux Plugin Manager)
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        act "Installing TPM..."
    git clone https://github.com/tmux-plugins/tpm \
        $HOME/.tmux/plugins/tpm --depth 1 && ok "TPM installed"
else
    note "TPM already installed"
fi

# Set up Rustup
act "Configuring Rustup..."
rustup default stable && { ok "Configuring Rustup completed"; } || {
    err "Failed to Configuring Rustup"
}

ok "All packages installed successfully!"

# Clear packages
note "Clear packages."
sudo pacman -Sc --noconfirm
if [[ "$ISAUR" == "yay" ]]; then
    yay -Sc --noconfirm && yay -Yc --noconfirm
elif [[ "$ISAUR" == "paru" ]]; then
    paru -Sc --noconfirm && paru -c --noconfirm
fi
