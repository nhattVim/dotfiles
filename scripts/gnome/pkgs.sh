#!/bin/bash
# Install packages

# Source library
. <(curl -sSL https://raw.githubusercontent.com/nhattVim/dotfiles/refs/heads/master/scripts/lib.sh)

# Variable
PIPES="https://github.com/pipeseroni/pipes.sh"
COLORSCRIPT="https://gitlab.com/dwt1/shell-color-scripts.git"
ARTTIME="https://github.com/poetaman/arttime/releases/download/v2.3.4/arttime_2.3.4-1_all.deb"
NEOVIM="https://github.com/neovim/neovim/releases/download/v0.11.3/nvim-linux-x86_64.tar.gz"
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
LAZYGIT="https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"

# ppa=(
#     ppa:zhangsongcui3371/fastfetch
# )

pkgs=(
    build-essential python3 python3-pip python3-venv python3-pynvim
    neofetch xclip zsh bat default-jdk htop fzf make ripgrep cmake
    tmux cava net-tools lolcat sl ca-certificates gnupg ranger unzip
    gdb nano vim bpytop libmagickwand-dev libmysqlclient-dev libpq-dev
    bison pkg-config autoconf clang libssl-dev libreadline-dev zlib1g-dev
    libyaml-dev libncurses5-dev libffi-dev libgdbm-dev libjemalloc2 libvips
    # fastfetch
)

# Add ppa
# note "Adding ppa..."
# for PPA in "${ppa[@]}"; do
#     sudo add-apt-repository -y "$PPA"
#     if [ $? -ne 0 ]; then
#         err "Failed to add $PPA"
#     fi
# done

# Re-update system
note "Updating system..."
if sudo $PKGMN update && sudo $PKGMN upgrade -y; then
    ok "Update system successfully"
else
    err "Failed to update system"
fi

# Check system
if grep -qi microsoft /proc/version; then
    ENV="WSL"
    pkgs+=(wslu)
else
    ENV="Ubuntu"
    pkgs+=(
        kitty rofi ibus-unikey stow aria2 libsecret-tools
        figlet cmatrix trash-cli hollywood cpufetch
        imagemagick mupdf mupdf-tools gnome-tweaks
    )
fi

# Install packages
note "Installing packages..."
for PKG in "${pkgs[@]}"; do
    iDeb "$PKG"
done

# Remove old version of Node.js
command -v node &>/dev/null && sudo $PKGMN remove node -y

# Install NVM (Node Version Manager)
if ! command -v nvm &>/dev/null; then
    note "Installing NVM (Node Version Manager)..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash

    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

    note "Installing latest version of Node.js..."
    if nvm install node && nvm use node; then
        ok "Node.js has been successfully installed."
    else
        err "Failed to install Node.js."
    fi
fi

# Install Rust
if ! command -v rustc &>/dev/null; then
    note "Install Rust ..."
    if curl --proto '=https' --tlsv1.2 -sSf "https://sh.rustup.rs" | sh; then
        ok "Rust was installed"
        . $HOME/.cargo/env
    else
        err "Rust install had failed"
    fi
else
    ok "Rust already installed, moving on"
fi

# Install Lsd
if ! command -v lsd &>/dev/null; then
    note "Install lsd ..."
    if cargo install lsd --locked; then
        ok "Lsd was installed"
    else
        err "Lsd install had failed"
    fi
else
    ok "Lsd already installed, moving on"
fi

# Install Arttime
if command -v arttime &>/dev/null; then
    ok "Arttime already installed, moving on"
else
    note "Download arttime.deb ..."
    if wget -O /tmp/arttime.deb "$ARTTIME"; then
        ok "Download arttime.deb successfully"
        note "Installing arttime ..."
        if sudo $PKGMN install -y /tmp/arttime.deb; then
            ok "Arttime was installed"
        else
            err "Arttime install had failed"
        fi
    else
        err "Failed to download arttime.deb"
    fi
fi

# Install Colorscript
if command -v colorscript &>/dev/null; then
    ok "Colorscript already installed, moving on"
else
    note "Clone shell-color-scripts repository ..."
    if git clone "$COLORSCRIPT" /tmp/colorscript; then
        ok "Clone shell-color-scripts successfully"
        note "Installing shell-color-scripts ..."
        if cd /tmp/colorscript &&
            sudo make install &&
            sudo cp completions/_colorscript /usr/share/zsh/site-functions &&
            cd - &>/dev/null; then
            ok "Shell-color-scripts was installed"
        else
            err "Failed to install shell-color-scripts"
        fi
    else
        err "Failed to download shell-color-scripts"
    fi
fi

# Install Pipes
if command -v pipes.sh &>/dev/null; then
    ok "Pipes.sh already installed, moving on."
else
    note "Clone pipe.sh repository ..."
    if git clone "$PIPES" /tmp/pipes.sh; then
        ok "Clone pipe.sh successfully"
        note "Installing pipes.sh ..."
        if cd /tmp/pipes.sh && make PREFIX=$HOME/.local install && cd - &>/dev/null; then
            ok "Install pipes.sh successfully"
        else
            err "Failed to install pipes.sh"
        fi
    else
        err "Failed to clone pipe.sh repository"
    fi
fi

# Install Lazygit
if command -v lazygit &>/dev/null; then
    ok "Lazygit already installed, moving on"
else
    note "Download lazygit.tar.gz ..."
    if wget -O /tmp/lazygit.tar.gz "$LAZYGIT" && tar -xf /tmp/lazygit.tar.gz -C /tmp; then
        ok "Download lazygit.tar.gz successfully"
        note "Installing lazygit ..."
        if sudo install /tmp/lazygit /usr/local/bin; then
            ok "Install lazygit successfully"
        else
            err "Failed to install lazygit"
        fi
    else
        err "Failed to download lazygit"
    fi
fi

# Install Neovim
if command -v nvim &>/dev/null; then
    note "Remove old version of NeoVim"
    sudo $PKGMN remove neovim -y
fi

note "Downloading latest version of Neovim..."
if wget -O /tmp/nvim.tar.gz "$NEOVIM"; then
    ok "Download successful"

    note "Installing Neovim..."
    INSTALL_DIR="$HOME/.local/bin"
    NVIM_DIR="$INSTALL_DIR/nvim-linux"

    mkdir -p "$INSTALL_DIR"
    rm -rf "$NVIM_DIR"

    tar -xf /tmp/nvim.tar.gz -C "$INSTALL_DIR"
    rm -f /tmp/nvim.tar.gz

    EXTRACTED_DIR=$(find "$INSTALL_DIR" -mindepth 1 -maxdepth 1 -type d -name 'nvim-*' | head -n 1)

    if [ -n "$EXTRACTED_DIR" ] && [ -d "$EXTRACTED_DIR" ]; then
        mv "$EXTRACTED_DIR" "$NVIM_DIR"
    else
        err "Neovim extraction failed: Folder not found"
    fi

    ln -sf "$NVIM_DIR/bin/nvim" "$INSTALL_DIR/nvim"
    ok "Neovim installed successfully"
else
    err "Failed to download Neovim"
fi

# Clone tpm
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

# Install Oh My Zsh
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
