#!/bin/bash
# install packages

# source library
source <(curl -sSL https://is.gd/nhattruongNeoVim_lib)

# variable
PIPES="https://github.com/pipeseroni/pipes.sh"
COLORSCRIPT="https://gitlab.com/dwt1/shell-color-scripts.git"
NODEJS="https://deb.nodesource.com/setup_22.x"
ARTTIME="https://github.com/poetaman/arttime/releases/download/v2.3.4/arttime_2.3.4-1_all.deb"
NEOVIM="https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz"
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
LAZYGIT="https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"

# reupdate system
printf "\n%s - Update system .... \n" "${NOTE}"
if sudo $PKGMN update && sudo $PKGMN upgrade -y; then
    printf "\n%s - Update system successfully \n" "${OK}"
else
    printf "\n%s - Failed to update your system \n" "${ERROR}"
fi

# check system
if grep -qi microsoft /proc/version; then
    printf "\n%s - Running on WSL, installing CLI tools only... \n" "${NOTE}"
    pkgs=(
        build-essential
        python3
        python3-pip
        neofetch
        xclip
        zsh
        bat
        default-jdk
        htop
        fzf
        make
        ripgrep
        cmake
        tmux
        cava
        net-tools
        lolcat
        sl
        ca-certificates
        gnupg
        ranger
        unzip
        python3-venv
        python3-neovim
        wslu
    )
else
    printf "\n%s - Running on Ubuntu, installing full packages... \n" "${NOTE}"
    pkgs=(
        build-essential
        neofetch
        xclip
        zsh
        kitty
        bat
        rofi
        ibus-unikey
        python3
        python3-pip
        python3-venv
        python3-neovim
        default-jdk
        htop
        stow
        fzf
        make
        ripgrep
        cmake
        aria2
        pip
        tmux
        libsecret-tools
        cava
        net-tools
        lolcat
        cpufetch
        bpytop
        figlet
        sl
        cmatrix
        trash-cli
        ranger
        hollywood
        grub-customizer
        ca-certificates
        gnupg
    )
fi

# install packages
printf "\n%s - Install packages .... \n" "${NOTE}"
for PKG in "${pkgs[@]}"; do
    install_ubuntu_packages "$PKG"
    if [ $? -ne 0 ]; then
        printf "\n%s - $PKG install had failed, please check the script. \n" "${ERROR}"
    fi
done

# install Nodejs
if command -v node &>/dev/null; then
    printf "\n%s - Removing old version of NodeJS \n" "${OK}"
    sudo $PKGMN remove -y nodejs
else
    printf "\n%s - Download Node.js setup script .... \n" "${NOTE}"
    if curl -fsSL "$NODEJS" -o nodesource_setup.sh; then
        printf "\n%s - Download the Node.js setup script successfully \n" "${OK}"
        printf "\n%s - Install Node.js .... \n" "${NOTE}"
        if sudo -E bash nodesource_setup.sh; then
            sudo $PKGMN install -y nodejs && rm nodesource_setup.sh
            printf "\n%s - Install Node.js successfully \n" "${OK}"
        else
            printf "\n%s - Install Node.js had failed \n" "${ERROR}"
        fi
    else
        printf "\n%s - Download the Node.js setup script had failed \n" "${ERROR}"
    fi
fi

# install Rust
if command -v rustc &>/dev/null; then
    printf "\n%s - Rust already installed, moving on \n" "${OK}"
else
    printf "\n%s - Install Rust ... \n" "${NOTE}"
    if curl --proto '=https' --tlsv1.2 -sSf "https://sh.rustup.rs" | sh; then
        printf "\n%s - Rust was installed \n" "${OK}"
        source $HOME/.cargo/env
    else
        printf "\n%s - Rust install had failed \n" "${ERROR}"
    fi
fi

# install Lsd
if command -v lsd &>/dev/null; then
    printf "\n%s - Lsd already installed, moving on \n" "${OK}"
else
    printf "\n%s - Install lsd ... \n" "${NOTE}"
    if cargo install lsd --locked; then
        printf "\n%s - Lsd was installed \n" "${OK}"
    else
        printf "\n%s - Lsd install had failed \n" "${ERROR}"
    fi
fi

# install Starship
if command -v starship &>/dev/null; then
    printf "\n%s - Starship already installed, moving on \n" "${OK}"
else
    printf "\n%s - Install starship ... \n" "${NOTE}"
    if cargo install starship --locked; then
        printf "\n%s - Starship was installed \n" "${OK}"
    else
        printf "\n%s - Starship install had failed \n" "${ERROR}"
    fi
fi

# install Arttime
if command -v arttime &>/dev/null; then
    printf "\n%s - Arttime already installed, moving on \n" "${OK}"
else
    printf "\n%s - Download arttime.deb .... \n" "${NOTE}"
    if wget -O /tmp/arttime.deb "$ARTTIME"; then
        printf "\n%s - Download arttime.deb successfully.... \n" "${OK}"
        printf "\n%s - Installing arttime .... \n" "${NOTE}"
        if sudo $PKGMN install -y /tmp/arttime.deb; then
            printf "\n%s - Install arttime successfully \n" "${OK}"
        else
            printf "\n%s - Arttime install had failed \n" "${ERROR}"
        fi
    else
        printf "\n%s - Failed to download arttime.deb \n" "${ERROR}"
    fi
fi

# install Colorscript
if command -v colorscript &>/dev/null; then
    printf "\n%s - Colorscript already installed, moving on \n" "${OK}"
else
    printf "\n%s - Clone colorscript .... \n" "${NOTE}"
    if git clone "$COLORSCRIPT" /tmp/colorscript; then
        printf "\n%s - Clone shell-color-scripts successfully \n" "${OK}"
        printf "\n%s - Installing colorscript .... \n" "${NOTE}"
        if
            cd /tmp/colorscript &&
                sudo make install &&
                sudo cp completions/_colorscript /usr/share/zsh/site-functions &&
                cd - &>/dev/null
        then
            printf "\n%s - Install shell-color-scripts successfully \n" "${OK}"
        else
            printf "\n%s - Failed to install shell-color-scripts \n" "${ERROR}"
        fi
    else
        printf "\n%s - Failed to clone shell-color-scripts repository \n" "${ERROR}"
    fi
fi

# install Pipes
if command -v pipes.sh &>/dev/null; then
    printf "\n%s - Pipes.sh already installed, moving on.\n" "${OK}"
else
    printf "\n%s - Clone pipes.sh ... \n" "${NOTE}"
    if git clone "$PIPES" /tmp/pipes.sh; then
        printf "\n%s - Clone pipe.sh successfully \n" "${OK}"
        printf "\n%s - Install pipes.sh ... \n" "${NOTE}"
        if
            cd /tmp/pipes.sh &&
                make PREFIX=$HOME/.local install &&
                cd - &>/dev/null
        then
            printf "\n%s - Install pipes.sh successfully \n" "${OK}"
        else
            printf "\n%s - Failed to install pipes.sh \n" "${ERROR}"
        fi
    else
        printf "\n%s - Failed to clone pipe.sh repository \n" "${ERROR}"
    fi
fi

# install Lazygit
if command -v lazygit &>/dev/null; then
    printf "\n%s - Lazygit already installed, moving on.\n" "${OK}"
else
    printf "\n%s - Download lazygit ... \n" "${NOTE}"
    if wget -O /tmp/lazygit.tar.gz "$LAZYGIT" && tar -xf /tmp/lazygit.tar.gz -C /tmp; then
        printf "\n%s - Download lazygit.tar successfully \n" "${OK}"
        printf "\n%s - Install lazygit ... \n" "${NOTE}"
        if sudo install /tmp/lazygit /usr/local/bin; then
            printf "\n%s - Install lazygit successfully \n" "${OK}"
        else
            printf "\n%s - Failed to install lazygit \n" "${ERROR}"
        fi
    else
        printf "\n%s - Failed to download lazygit \n" "${ERROR}"
    fi
fi

# install Neovim
if command -v nvim &>/dev/null; then
    printf "\n%s - Removing old version of neovim ... \n" "${NOTE}"
    sudo $PKGMN remove neovim -y
fi
printf "\n%s - Download lastest version of neovim ... \n" "${NOTE}"
if wget -O /tmp/nvim-linux64.tar.gz "$NEOVIM"; then
    printf "\n%s - Download lastest version of neovim successfully \n" "${OK}"
    printf "\n%s - Install neovim ... \n" "${NOTE}"
    mkdir -p $HOME/.local/bin &&
        mv /tmp/nvim-linux64.tar.gz $HOME/.local/bin &&
        tar -xf $HOME/.local/bin/nvim-linux64.tar.gz -C $HOME/.local/bin &&
        rm -fr $HOME/.local/bin/nvim-linux64.tar.gz &&
        ln -s $HOME/.local/bin/nvim-linux64/bin/nvim $HOME/.local/bin/nvim &&
        printf "\n%s - Install neovim successfully \n" "${OK}" || {
        printf "\n%s - Failed to install neovim \n" "${ERROR}"
    }
else
    printf "\n%s - Failed to download neovim \n" "${ERROR}"
fi

# clone tpm
if [ -d "$HOME/.tmux/plugins/tpm" ]; then
    printf "\n%s - TPM (Tmux Plugin Manager) is already installed. \n" "${NOTE}"
else
    # Clone TPM repository
    printf "\n%s - Cloning TPM (Tmux Plugin Manager)... \n" "${NOTE}"
    if git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm --depth 1; then
        printf "\n%s - TPM (Tmux Plugin Manager) cloned successfully \n" "${OK}"
    else
        printf "\n%s - Failed to clone TPM (Tmux Plugin Manager). \n" "${ERROR}"
    fi
fi
