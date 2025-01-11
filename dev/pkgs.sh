#!/bin/bash
# Scientific and modular script for installing packages

# Load library
source <(curl -sSL https://is.gd/nhattVim_lib)

# Variables
REPOS=(
    "PIPES|https://github.com/pipeseroni/pipes.sh"
    "COLORSCRIPT|https://gitlab.com/dwt1/shell-color-scripts.git"
    "NODEJS|https://deb.nodesource.com/setup_23.x"
    "ARTTIME|https://github.com/poetaman/arttime/releases/download/v2.3.4/arttime_2.3.4-1_all.deb"
    "NEOVIM|https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz"
    "LAZYGIT|https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep -Po '"tag_name": "v\K[^"]*')_Linux_x86_64.tar.gz"
)

# Determine package list based on environment
if grep -qi microsoft /proc/version; then
    ENV="WSL"
    PACKAGES=(build-essential python3 python3-pip neofetch xclip zsh bat default-jdk htop fzf make ripgrep cmake tmux cava net-tools lolcat sl ca-certificates gnupg ranger unzip python3-venv python3-pynvim wslu dotnet-sdk-8.0)
else
    ENV="Ubuntu"
    PACKAGES=(build-essential neofetch xclip zsh kitty bat rofi ibus-unikey python3 python3-pip python3-venv python3-pynvim default-jdk htop stow fzf make ripgrep cmake aria2 pip tmux libsecret-tools cava net-tools lolcat cpufetch bpytop figlet sl cmatrix trash-cli ranger hollywood grub-customizer ca-certificates gnupg)
fi

# Functions
log() {
    echo -e "$1 $2"
}

install_package() {
    local pkg=$1
    log "${NOTE}" "Installing $pkg..."
    if iDeb "$pkg"; then
        log "${OK}" "$pkg installed successfully."
    else
        log "${ERROR}" "Failed to install $pkg."
    fi
}

install_from_url() {
    local url=$1 dest=$2
    log "${NOTE}" "Downloading $url..."
    if wget -O "$dest" "$url"; then
        log "${OK}" "Downloaded successfully to $dest."
    else
        log "${ERROR}" "Failed to download $url."
        return 1
    fi
}

install_nodejs() {
    if command -v node &>/dev/null; then
        log "${OK}" "Node.js is already installed, removing old version..."
        sudo $PKGMN remove -y nodejs
    fi
    install_from_url "$NODEJS" nodesource_setup.sh && sudo -E bash nodesource_setup.sh && sudo $PKGMN install -y nodejs && rm nodesource_setup.sh
}

install_rust() {
    if command -v rustc &>/dev/null; then
        log "${OK}" "Rust is already installed."
    else
        log "${NOTE}" "Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh && source "$HOME/.cargo/env"
    fi
}

install_cargo_package() {
    local pkg=$1
    if command -v "$pkg" &>/dev/null; then
        log "${OK}" "$pkg is already installed."
    else
        log "${NOTE}" "Installing $pkg..."
        cargo install "$pkg" --locked
    fi
}

install_tpm() {
    if [ -d "$HOME/.tmux/plugins/tpm" ]; then
        log "${OK}" "TPM is already installed."
    else
        log "${NOTE}" "Cloning TPM..."
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    fi
}

install_repo() {
    local name url
    IFS="|" read -r name url <<<"$1"
    log "${NOTE}" "Installing $name from $url..."
    case $name in
    PIPES)
        git clone "$url" /tmp/pipes.sh && cd /tmp/pipes.sh && make PREFIX=$HOME/.local install
        ;;
    COLORSCRIPT)
        git clone "$url" /tmp/colorscript && cd /tmp/colorscript && sudo make install
        ;;
    ARTTIME)
        install_from_url "$url" /tmp/arttime.deb && sudo $PKGMN install -y /tmp/arttime.deb
        ;;
    NEOVIM)
        install_from_url "$url" /tmp/nvim-linux64.tar.gz && mkdir -p $HOME/.local/bin && tar -xzf /tmp/nvim-linux64.tar.gz -C $HOME/.local/bin
        ;;
    LAZYGIT)
        install_from_url "$url" /tmp/lazygit.tar.gz && tar -xzf /tmp/lazygit.tar.gz -C /tmp && sudo install /tmp/lazygit /usr/local/bin
        ;;
    esac
}

# Main script execution
log "${NOTE}" "Updating system..."
sudo $PKGMN update && sudo $PKGMN upgrade -y

log "${NOTE}" "Installing packages..."
for pkg in "${PACKAGES[@]}"; do
    install_package "$pkg"
done

log "${NOTE}" "Installing additional tools..."
install_nodejs
install_rust
install_cargo_package lsd
install_cargo_package starship
install_tpm

for repo in "${REPOS[@]}"; do
    install_repo "$repo"
done
