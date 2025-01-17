#!/bin/bash
# install pacman package

# source library
source <(curl -sSL https://is.gd/nhattVim_lib)

# start script
pkgs=(
    linux-lts
    linux-lts-headers
    base-devel
    git
    libxcrypt-compat
    alacritty
    tmux
    zsh
    nano
    vim
    make
    python-pip
    nodejs
    npm
    python-virtualenv
    ripgrep
    fzf
    neofetch
    lsd
    lazygit
    net-tools
    neovim
    bat
    libreoffice-fresh
    jdk-openjdk
    file-roller
    gnome-disk-utility
    discord
    neovide
    ranger
    aria2
    btop
    curl
    mpv
    mpv-mpris
    yt-dlp
    ffmpeg
    cmatrix
    telegram-desktop
    foot
    cargo
)

hypr_pkgs=(
    brightnessctl
    grim
    waybar
    gnome-system-monitor
    jq
    slurp
    swappy
    cliphist
    network-manager-applet
    pamixer
    pavucontrol
    pipewire-alsa
    playerctl
    polkit-gnome
    python-pywal
    qt5ct
    qt6ct
    swappy
    swayidle
    wget
    wl-clipboard
    xdg-user-dirs
    xdg-utils
    yad
    nvtop
    chromium
)

# Installation of main components
note "Installing packages..."
for PKG1 in "${pkgs[@]}" "${hypr_pkgs[@]}"; do
    iPac "$PKG1"
    if [ $? -ne 0 ]; then
        err "$PKG1 install had failed"
    fi
done

# Oh-my-zsh
if [ -d "$HOME/.oh-my-zsh" ]; then
    note "Oh My Zsh is already installed."
else
    note "Download oh-my-zsh ..."
    if sh -c "$(wget -O- https://install.ohmyz.sh)" "" --unattended; then
        ok "Download oh-my-zsh successfully"
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    else
        err "Failed to download oh-my-zsh"
    fi
fi

# TPM
if [ -d "$HOME/.tmux/plugins/tpm" ]; then
    note "TPM (Tmux Plugin Manager) is already installed."
else
    note "Cloning TPM (Tmux Plugin Manager)..."
    if git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm --depth 1; then
        ok "TPM (Tmux Plugin Manager) cloned successfully"
    else
        err "Failed to clone TPM (Tmux Plugin Manager)."
    fi
fi
