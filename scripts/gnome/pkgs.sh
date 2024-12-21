#!/bin/bash
# Install packages

# Source library
source <(curl -sSL https://is.gd/nhattVim_lib)

# Variable
PIPES="https://github.com/pipeseroni/pipes.sh"
COLORSCRIPT="https://gitlab.com/dwt1/shell-color-scripts.git"
NODEJS="https://deb.nodesource.com/setup_23.x"
ARTTIME="https://github.com/poetaman/arttime/releases/download/v2.3.4/arttime_2.3.4-1_all.deb"
NEOVIM="https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz"
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
LAZYGIT="https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"

# Re-update system
echo -e "\n${NOTE} - Update system ...."
if sudo $PKGMN update && sudo $PKGMN upgrade -y; then
    echo -e "\n${OK} - Update system successfully"
else
    echo -e "\n${ERROR} - Failed to update your system"
fi

# Check system
if grep -qi microsoft /proc/version; then
    echo -e "\n${NOTE} - Running on WSL, installing CLI tools only..."
    pkgs=(
        build-essential python3 python3-pip neofetch xclip zsh bat default-jdk
        htop fzf make ripgrep cmake tmux cava net-tools lolcat sl ca-certificates
        gnupg ranger unzip python3-venv python3-pynvim wslu dotnet-sdk-8.0
    )
else
    echo -e "\n${NOTE} - Running on Ubuntu, installing full packages..."
    pkgs=(
        build-essential neofetch xclip zsh kitty bat rofi ibus-unikey python3
        python3-pip python3-venv python3-pynvim default-jdk htop stow fzf make
        ripgrep cmake aria2 pip tmux libsecret-tools cava net-tools lolcat
        cpufetch bpytop figlet sl cmatrix trash-cli ranger hollywood grub-customizer
        ca-certificates gnupg
    )
fi

# Install packages
echo -e "\n${NOTE} - Install packages ...."
for PKG in "${pkgs[@]}"; do
    iDeb "$PKG"
    if [ $? -ne 0 ]; then
        echo -e "\n${ERROR} - $PKG install had failed, please check the script."
    fi
done

# Install Nodejs
if command -v node &>/dev/null; then
    echo -e "\n${OK} - Removing old version of NodeJS"
    sudo $PKGMN remove -y nodejs
else
    echo -e "\n${NOTE} - Download Node.js setup script ...."
    if curl -fsSL "$NODEJS" -o nodesource_setup.sh; then
        echo -e "\n${OK} - Download the Node.js setup script successfully"
        echo -e "\n${NOTE} - Install Node.js ...."
        if sudo -E bash nodesource_setup.sh; then
            sudo $PKGMN install -y nodejs && rm nodesource_setup.sh
            echo -e "\n${OK} - Install Node.js successfully"
        else
            echo -e "\n${ERROR} - Install Node.js had failed"
        fi
    else
        echo -e "\n${ERROR} - Download the Node.js setup script had failed"
    fi
fi

# Install Rust
if command -v rustc &>/dev/null; then
    echo -e "\n${OK} - Rust already installed, moving on"
else
    echo -e "\n${NOTE} - Install Rust ..."
    if curl --proto '=https' --tlsv1.2 -sSf "https://sh.rustup.rs" | sh; then
        echo -e "\n${OK} - Rust was installed"
        source $HOME/.cargo/env
    else
        echo -e "\n${ERROR} - Rust install had failed"
    fi
fi

# Install Lsd
if command -v lsd &>/dev/null; then
    echo -e "\n${OK} - Lsd already installed, moving on"
else
    echo -e "\n${NOTE} - Install lsd ..."
    if cargo install lsd --locked; then
        echo -e "\n${OK} - Lsd was installed"
    else
        echo -e "\n${ERROR} - Lsd install had failed"
    fi
fi

# Install Starship
if command -v starship &>/dev/null; then
    echo -e "\n${OK} - Starship already installed, moving on"
else
    echo -e "\n${NOTE} - Install starship ..."
    if cargo install starship --locked; then
        echo -e "\n${OK} - Starship was installed"
    else
        echo -e "\n${ERROR} - Starship install had failed"
    fi
fi

# Install Arttime
if command -v arttime &>/dev/null; then
    echo -e "\n${OK} - Arttime already installed, moving on"
else
    echo -e "\n${NOTE} - Download arttime.deb ...."
    if wget -O /tmp/arttime.deb "$ARTTIME"; then
        echo -e "\n${OK} - Download arttime.deb successfully...."
        echo -e "\n${NOTE} - Installing arttime ...."
        if sudo $PKGMN install -y /tmp/arttime.deb; then
            echo -e "\n${OK} - Install arttime successfully"
        else
            echo -e "\n${ERROR} - Arttime install had failed"
        fi
    else
        echo -e "\n${ERROR} - Failed to download arttime.deb"
    fi
fi

# Install Colorscript
if command -v colorscript &>/dev/null; then
    echo -e "\n${OK} - Colorscript already installed, moving on"
else
    echo -e "\n${NOTE} - Clone colorscript ...."
    if git clone "$COLORSCRIPT" /tmp/colorscript; then
        echo -e "\n${OK} - Clone shell-color-scripts successfully"
        echo -e "\n${NOTE} - Installing colorscript ...."
        if cd /tmp/colorscript && sudo make install && sudo cp completions/_colorscript /usr/share/zsh/site-functions && cd - &>/dev/null; then
            echo -e "\n${OK} - Install shell-color-scripts successfully"
        else
            echo -e "\n${ERROR} - Failed to install shell-color-scripts"
        fi
    else
        echo -e "\n${ERROR} - Failed to clone shell-color-scripts repository"
    fi
fi

# Install Pipes
if command -v pipes.sh &>/dev/null; then
    echo -e "\n${OK} - Pipes.sh already installed, moving on."
else
    echo -e "\n${NOTE} - Clone pipes.sh ..."
    if git clone "$PIPES" /tmp/pipes.sh; then
        echo -e "\n${OK} - Clone pipe.sh successfully"
        echo -e "\n${NOTE} - Install pipes.sh ..."
        if cd /tmp/pipes.sh && make PREFIX=$HOME/.local install && cd - &>/dev/null; then
            echo -e "\n${OK} - Install pipes.sh successfully"
        else
            echo -e "\n${ERROR} - Failed to install pipes.sh"
        fi
    else
        echo -e "\n${ERROR} - Failed to clone pipe.sh repository"
    fi
fi

# Install Lazygit
if command -v lazygit &>/dev/null; then
    echo -e "\n${OK} - Lazygit already installed, moving on."
else
    echo -e "\n${NOTE} - Download lazygit ..."
    if wget -O /tmp/lazygit.tar.gz "$LAZYGIT" && tar -xf /tmp/lazygit.tar.gz -C /tmp; then
        echo -e "\n${OK} - Download lazygit.tar successfully"
        echo -e "\n${NOTE} - Install lazygit ..."
        if sudo install /tmp/lazygit /usr/local/bin; then
            echo -e "\n${OK} - Install lazygit successfully"
        else
            echo -e "\n${ERROR} - Failed to install lazygit"
        fi
    else
        echo -e "\n${ERROR} - Failed to download lazygit"
    fi
fi

# Install Neovim
if command -v nvim &>/dev/null; then
    echo -e "\n${NOTE} - Removing old version of neovim ..."
    sudo $PKGMN remove neovim -y
fi
echo -e "\n${NOTE} - Download lastest version of neovim ..."
if wget -O /tmp/nvim-linux64.tar.gz "$NEOVIM"; then
    echo -e "\n${OK} - Download lastest version of neovim successfully"
    echo -e "\n${NOTE} - Install neovim ..."
    mkdir -p $HOME/.local/bin &&
        mv /tmp/nvim-linux64.tar.gz $HOME/.local/bin &&
        tar -xf $HOME/.local/bin/nvim-linux64.tar.gz -C $HOME/.local/bin &&
        rm -fr $HOME/.local/bin/nvim-linux64.tar.gz &&
        ln -s $HOME/.local/bin/nvim-linux64/bin/nvim $HOME/.local/bin/nvim &&
        echo -e "\n${OK} - Install neovim successfully" || {
        echo -e "\n${ERROR} - Failed to install neovim"
    }
else
    echo -e "\n${ERROR} - Failed to download neovim"
fi

# Clone tpm
if [ -d "$HOME/.tmux/plugins/tpm" ]; then
    echo -e "\n${NOTE} - TPM (Tmux Plugin Manager) is already installed."
else
    echo -e "\n${NOTE} - Cloning TPM (Tmux Plugin Manager)..."
    if git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm --depth 1; then
        echo -e "\n${OK} - TPM (Tmux Plugin Manager) cloned successfully"
    else
        echo -e "\n${ERROR} - Failed to clone TPM (Tmux Plugin Manager)."
    fi
fi

# Install Oh My Zsh
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo -e "\n${NOTE} - Oh My Zsh is already installed."
else
    echo -e "\n${NOTE} - Download oh-my-zsh ..."
    if sh -c "$(wget -O- https://install.ohmyz.sh)" "" --unattended; then
        echo -e "\n${OK} - Download oh-my-zsh successfully"
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    else
        echo -e "\n${ERROR} - Failed to download oh-my-zsh"
    fi
fi
