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
    linux-lts linux-lts-headers base-devel libxcrypt-compat
    python-pip python-virtualenv python-requests cargo gdb
    jdk-openjdk python-pyquery python-beautifulsoup4 rust
    python-pynvim

    # ----------------------------------------------------
    # Terminal & CLI Tools
    # ----------------------------------------------------
    alacritty tmux zsh nano vim neovim make ripgrep fzf jq
    lazygit bat btop aria2 foot fastfetch lolcat yazi inxi
    lsd curl wget axel fish

    # ----------------------------------------------------
    # System utilities
    # ----------------------------------------------------
    net-tools gnome-disk-utility file-roller gvfs gvfs-mtp
    network-manager-applet gnome-system-monitor os-prober
    pacman-contrib nwg-look gammastep polkit-gnome ccache
    rebuild-detector

    # ----------------------------------------------------
    # Multimedia
    # ----------------------------------------------------
    mpv mpv-mpris yt-dlp ffmpeg

    # ----------------------------------------------------
    # GUI Applications
    # ----------------------------------------------------
    discord neovide ranger cmatrix qalculate-gtk mousepad
    telegram-desktop eog libreoffice-fresh
    # chromium

    # ----------------------------------------------------
    # Hyprland Ecosystem
    # ----------------------------------------------------
    brightnessctl grim hyprpolkitagent slurp cliphist
    pamixer pavucontrol playerctl qt5ct qt6ct wl-clipboard
    xdg-user-dirs xdg-utils yad hyprcursor hyprutils nvtop
    aquamarine hypridle hyprlock hyprland hyprland-qtutils
    libspng imagemagick kitty kvantum rofi-wayland swaync
    swww waybar swappy swayidle

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
    wlogout pyprland cava caelestia-meta
    # wallust bauh

    # ----------------------------------------------------
    # Extras Packages
    # ----------------------------------------------------
    arttime-git pipes.sh shell-color-scripts-git
    ferdium-bin visual-studio-code-bin
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

# Install Node.js provider for neovim
note "Installing Node.js provider for neovim..."
sudo npm install -g neovim

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

# Generate scheme stuff if needed
note "Generating caelestia scheme..."
caelestia scheme set -n shadotheme
sleep .5
hyprctl reload

# Wallust
if ! command -v wallust &>/dev/null; then
    act "Installing Wallust..."
    cargo install wallust && ok "Wallust installed" &&
        echo 'export PATH="$HOME/.cargo/bin:$PATH"' >>$HOME/.bashrc
else
    note "Wallust already installed"
fi

ok "All packages installed successfully!"

# Clear packages
note "Clear packages."
sudo pacman -Sc --noconfirm &&
    yay -Sc --noconfirm &&
    yay -Yc --noconfirm
