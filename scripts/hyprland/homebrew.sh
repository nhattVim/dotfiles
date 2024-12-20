#!/bin/bash
# Homebrew

# source library
source <(curl -sSL https://is.gd/nhattVim_lib)

# start script
if command -v brew &>/dev/null; then
    printf "\n%s - Homebrew already installed, moving on.\n" "${OK}"
else
    printf "\n%s - Installing Homebrew\n" "${NOTE}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
        printf "%s - Failed to install Homebrew\n" "${ERROR}"
        exit 1
    }
fi

# Setup Homebrew before proceeding
printf "\n%s - Set up Homebrew.... \n" "${NOTE}"
(
    echo
    echo '# Auto generated by Homebrew'
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
) >>$HOME/.bashrc >>$HOME/.zshrc || {
    printf "%s - Failed to setup Homebrew\n" "${ERROR}"
    exit 1
}

# Activate Homebrew environment and update, upgrade, and install packages
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && brew update && brew upgrade && brew install gcc || {
    printf "%s - Failed to setup Homebrew\n" "${ERROR}"
    exit 1
}
