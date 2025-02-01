#!/bin/bash
# install package

# Source library
. <(curl -sSL https://is.gd/nhattVim_lib)

# ==============================================================================
# Package Definitions
# ==============================================================================

# --------------------------------------
# 1. Core System & Development
# --------------------------------------
core_system=(
    linux-lts linux-lts-headers base-devel git make cmatrix libxcrypt-compat
    jdk-openjdk python-pip python-virtualenv nodejs npm cargo rust python-requests
)

# --------------------------------------
# 2. Terminal & CLI Tools
# --------------------------------------
terminal_tools=(
    alacritty kitty foot tmux zsh nano vim neovim neovide ripgrep fzf lsd bat
    lazygit ranger btop fastfetch lolcat brightnessctl inxi
)

# --------------------------------------
# 3. GUI Applications
# --------------------------------------
gui_apps=(
    libreoffice-fresh discord telegram-desktop chromium
)

# --------------------------------------
# 4. Desktop Environment (Non-Hyprland)
# --------------------------------------
desktop_env=(
    gnome-system-monitor gnome-disk-utility file-roller eog mousepad polkit-gnome
)

# --------------------------------------
# 5. Multimedia & Download
# --------------------------------------
multimedia=(
    mpv mpv-mpris yt-dlp ffmpeg aria2
)

# --------------------------------------
# 6. Hyprland Ecosystem
# --------------------------------------
hyprland_stack=(
    hyprland waybar rofi-lbonn-wayland-git grim slurp swappy cliphist pamixer
    pavucontrol playerctl qt5ct qt6ct swayidle wl-clipboard xdg-user-dirs xdg-utils yad
)

# --------------------------------------
# 7. Network & Utilities
# --------------------------------------
network_tools=(
    net-tools network-manager-applet wget curl pacman-contrib
)

# --------------------------------------
# 8. AUR Packages
# --------------------------------------
aur_pkgs=(
    zen-browser-bin arttime-git pipes.sh tgpt-bin shell-color-scripts-git
    gvfs gvfs-mtp imagemagick kvantum swaync swww wlogout cava
)

# --------------------------------------
# 9. Fonts
# --------------------------------------
fonts=(
    adobe-source-code-pro-fonts noto-fonts noto-fonts-emoji otf-font-awesome
    ttf-droid ttf-fira-code ttf-jetbrains-mono ttf-jetbrains-mono-nerd
)

# --------------------------------------
# 10. Packages to Remove (Conflicts)
# --------------------------------------
uninstall_pkgs=(
    aylurs-gtk-shell dunst mako cachyos-hyprland-settings rofi wallust-git
)

# ==============================================================================
# Installation Logic
# ==============================================================================

# Clean conflicts first
note "Removing conflicting packages..."
for UNINSTALL in "${uninstall_pkgs[@]}"; do
    uPac "$UNINSTALL"
    if [ $? -ne 0 ]; then
        err "$UNINSTALL uninstallation had failed"
    fi
done

# Group all packages
all_pkgs=("${core_system[@]}" "${terminal_tools[@]}" "${gui_apps[@]}"
    "${desktop_env[@]}" "${multimedia[@]}" "${hyprland_stack[@]}"
    "${network_tools[@]}")

# Install official packages
note "Installing official repository packages..."
for PKG in "${all_pkgs[@]}"; do
    iPac "$PKG"
    if [ $? -ne 0 ]; then
        err "$PKG install had failed"
    fi
done

# Install AUR packages
note "Installing AUR packages..."
for AUR_PKG in "${aur_pkgs[@]}" "${fonts[@]}"; do
    iAur "$AUR_PKG"
    if [ $? -ne 0 ]; then
        err "$AUR_PKG install had failed"
    fi
done

# ==============================================================================
# Post-Install Setup
# ==============================================================================

# Oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    note "Installing Oh My Zsh..."
    sh -c "$(wget -O- https://install.ohmyz.sh)" "" --unattended && {
        git clone https://github.com/zsh-users/zsh-autosuggestions \
            ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
        ok "Oh My Zsh configured"
    } || err "Oh My Zsh install failed"
else
    note "Oh My Zsh already installed"
fi

# TPM
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    note "Installing TPM..."
    git clone https://github.com/tmux-plugins/tpm \
        $HOME/.tmux/plugins/tpm --depth 1 && ok "TPM installed"
else
    note "TPM already installed"
fi

# Wallust
if ! command -v wallust &>/dev/null; then
    act "Installing wallust..."
    cargo install wallust && ok "Wallust installed"
else
    note "Wallust already installed"
fi
