#!/bin/bash
# install pacman package

# source library
. <(curl -sSL https://is.gd/nhattVim_lib)

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
    fastfetch
    lolcat
)

hypr_pkgs=(
    brightnessctl
    inxi
    grim
    waybar
    hyprpolkitagent
    gnome-system-monitor
    jq
    slurp
    swappy
    cliphist
    network-manager-applet
    pamixer
    pavucontrol
    playerctl
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

# List of packages to uninstall as it conflicts some packages
uninstall=(
    aylurs-gtk-shell
    dunst
    mako
    cachyos-hyprland-settings
    rofi
    wallust-git
)

# Checking if mako or dunst is installed
note "Removing Mako, Dunst, and rofi as they conflict with swaync and rofi-wayland"
for PKG in "${uninstall[@]}"; do
    uPac "$PKG"
    if [ $? -ne 0 ]; then
        err "$PKG uninstallation had failed"
    fi
done

# Installation of main components
note "Installing packages..."
for PKG1 in "${pkgs[@]}" "${hypr_pkgs[@]}"; do
    iPac "$PKG1"
    if [ $? -ne 0 ]; then
        err "$PKG1 install had failed"
    fi
done

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
