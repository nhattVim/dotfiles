#!/bin/bash
# Homebrew

# source library
. <(curl -sSL https://raw.githubusercontent.com/nhattVim/dotfiles/refs/heads/master/scripts/lib.sh)

# start script
if command -v brew &>/dev/null 2>&1; then
    ok "Homebrew already installed, moving on."
else
    note "Install Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
        err "Failed to install Homebrew"
        exit 1
    }
fi

# Setup Homebrew before proceeding
note "Setup Homebrew"
(
    echo
    echo '# Auto generated by Homebrew'
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
) >>$HOME/.bashrc >>$HOME/.zshrc || {
    err "Failed to setup Homebrew"
    exit 1
}

# Activate Homebrew environment and update, upgrade, and install packages
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" &&
    brew update && brew upgrade && brew install gcc || {
    err "Failed to setup Homebrew"
    exit 1
}
