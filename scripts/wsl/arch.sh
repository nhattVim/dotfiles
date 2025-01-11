#!/bin/bash
# config wsl

# source library
source <(curl -sSL https://is.gd/nhattVim_lib)

# require
exHypr "boot.sh"

# init
clear

# start script
gum style \
    --foreground 213 --border-foreground 213 --border rounded \
    --align center --width 90 --margin "1 2" --padding "2 4" \
    "  ____   __ __   ____  ______      ______  ____   __ __   ___   ____    ____  " \
    " |    \ |  |  | /    ||      |    |      ||    \ |  |  | /   \ |    \  /    | " \
    " |  _  ||  |  ||  o  ||      |    |      ||  D  )|  |  ||     ||  _  ||   __| " \
    " |  |  ||  _  ||     ||_|  |_|    |_|  |_||    / |  |  ||  O  ||  |  ||  |  | " \
    " |  |  ||  |  ||  _  |  |  |        |  |  |    \ |  :  ||     ||  |  ||  |_ | " \
    " |  |  ||  |  ||  |  |  |  |        |  |  |  .  \|     ||     ||  |  ||     | " \
    " |__|__||__|__||__|__|  |__|        |__|  |__|\_| \__,_| \___/ |__|__||___,_| " \
    "                                                                              " \
    " ---------------------- Script developed by nhattVim ------------------------ " \
    "                                                                              " \
    "  ----------------- Github: https://github.com/nhattVim --------------------  " \
    "                                                                              "
echo -e "\n"
choose "Choose your AUR helper" "yay" "paru" aur_helper
yes_no "Install zsh, color scripts (Optional) & zsh plugin (Optional)?" zsh

if [ "$aur_helper" == "paru" ]; then
    exHypr "paru.sh"
elif [ "$aur_helper" == "yay" ]; then
    exHypr "yay.sh"
fi

pacman_packages=(
    git
    unzip
    tmux
    starship
    zsh
    make
    python-pip
    nodejs
    npm
    ripgrep
    fzf
    neofetch
    lsd
    lazygit
    net-tools
    neovim
    bat
    ranger
    aria2
    btop
    curl
    wget
    nvtop
    cargo
    openssh
    lolcat
    python-virtualenv
)

aur_packages=(
    arttime-git
    pipes.sh
    cava
)

# reload AUR
ISAUR=$(command -v yay || command -v paru)

# Installation of main components
echo -e "\n${NOTE} - Installing components"

for PKG1 in "${pacman_packages[@]}"; do
    iPac "$PKG1"
    if [ $? -ne 0 ]; then
        echo -e "\e[1A\e[K${ERROR} - $PKG1 install had failed"
    fi
done

for PKG2 in "${aur_packages[@]}"; do
    iAur "$PKG2"
    if [ $? -ne 0 ]; then
        echo -e "\e[1A\e[K${ERROR} - $PKG2 install had failed"
    fi
done

# Set up neovim
echo -e "\n%.0s" {1..2}
echo -e "${NOTE} Setup neovim"
if [ -d $HOME/.config/nvim ]; then
    mv $HOME/.config/nvim $HOME/.config/nvim_bak && { echo "${OK} Backup neovim folder completed"; } || {
        echo "${OK} Failed to backup neovim folder "
    }
fi
if [ -d $HOME/.local/share/nvim ]; then
    mv $HOME/.local/share/nvim $HOME/.local/share/nvim_bak && { echo "${OK} Backup neovim data folder completed"; } || {
        echo "${OK} Failed to backup neovim folder"
    }
fi
if git clone https://github.com/nhattVim/MYnvim.git ~/.config/nvim --depth 1; then
    echo -e "\n${OK} Setup neovim successfully"
else
    echo -e "\n${ERROR} Failed to setup neovim"
fi

# Check if dotfiles exist
cd $HOME || exit 1
if [ -d dotfiles ]; then
    rm -rf dotfiles
    echo -e "${OK} Remove dotfile successfully "
fi

# Clone dotfiles
echo -e "\n${NOTE} Clone dotfiles. "
if git clone -b hyprland https://github.com/nhattVim/dotfiles.git --depth 1 && cd dotfiles; then
    echo -e "\n${OK} Clone dotfiles succesfully.\n"
fi

echo -e "\n%.0s" {1..2}
echo -e "\n${NOTE} Start config"

folder=(
    neofetch
    ranger
    tmux
    starship.toml
)

# Back up configuration file
for DIR in "${folder[@]}"; do
    DIRPATH=~/.config/"$DIR"
    if [ -d "$DIRPATH" ]; then
        echo -e "${NOTE} - Config for $DIR found, attempting to back up."
        BACKUP_DIR=$(get_backup_dirname)
        mv "$DIRPATH" "$DIRPATH-backup-$BACKUP_DIR"
        echo -e "${NOTE} - Backed up $DIR to $DIRPATH-backup-$BACKUP_DIR."
    fi
done

# Copying configuration file
for ITEM in "${folder[@]}"; do
    if [[ -d "config/$ITEM" ]]; then
        cp -r "config/$ITEM" ~/.config/ && echo "${OK} Copy completed" || echo "${ERROR} Failed to copy config files."
    elif [[ -f "config/$ITEM" ]]; then
        cp "config/$ITEM" ~/.config/ && echo "${OK} Copy completed" || echo "${ERROR} Failed to copy config files."
    fi
done

# Copying other
cp assets/.zshrc ~ && { echo "${OK} Copy completed"; } || {
    echo "${ERROR} Failed to copy .zshrc"
}

# Copying font
mkdir -p ~/.fonts
cp -r assets/.fonts/* ~/.fonts/ && { echo "${OK} Copy fonts completed"; } || {
    echo "${ERROR} Failed to copy fonts files."
}

# Clone tpm
if [ -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "${NOTE} TPM (Tmux Plugin Manager) is already installed."
else
    # Clone TPM repository
    echo "${NOTE} Cloning TPM (Tmux Plugin Manager)..."
    if git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm --depth 1; then
        echo "${OK} TPM (Tmux Plugin Manager) cloned successfully"
    else
        echo "${ERROR} Failed to clone TPM (Tmux Plugin Manager)."
    fi
fi

# zsh
if [ "$zsh" == "Y" ]; then
    exHypr "zsh.sh"
fi

# remove dotfiles
cd $HOME
if [ -d dotfiles ]; then
    rm -rf dotfiles
    echo -e "${NOTE} Remove dotfile successfully "
fi

echo -e "\n%.0s" {1..2}

if [ -f $HOME/install.log ]; then
    gum confirm "${CAT} Do you want to check log?" && gum pager <$HOME/install.log
fi

# clear packages
echo -e "\n${NOTE} Clear packages.\n"
if sudo pacman -Sc --noconfirm && yay -Sc --noconfirm && yay -Yc --noconfirm; then
    echo -e "\n${OK} Clear packages succesfully.\n"
fi

echo -e "\n%.0s" {1..2}
echo -e "\n${OK} Yey! Setup Completed.\n"
echo -e "\n%.0s" {1..2}

zsh
