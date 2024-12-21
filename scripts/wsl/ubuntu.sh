#!/bin/bash
# config wsl

# Source library
source <(curl -sSL https://is.gd/nhattVim_lib) && clear

# Require boot script
exGnome "boot.sh"

# Start script
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

gum style \
    --foreground 6 --border-foreground 6 --border rounded \
    --align left --width 90 --margin "1 2" --padding "2 4" \
    "$(tput setaf 3)NOTE:$(tput setaf 6) Ensure that you have a stable internet connection $(tput setaf 3)(Highly Recommended!!!!)$(tput sgr0)" \
    "                                                                                                                             $(tput sgr0)" \
    "$(tput setaf 3)NOTE:$(tput setaf 6) You will be required to answer some questions during the installation!!                  $(tput sgr0)" \
    "                                                                                                                             $(tput sgr0)" \
    "$(tput setaf 3)NOTE:$(tput setaf 6) If you are installing on a VM, ensure to enable 3D acceleration!                         $(tput sgr0)"

# Install package
exGnome "pkgs.sh"

# Config MYnvim
echo -e "\n${NOTE} - Setting up MYnvim..."
if [ -d "$HOME/.config/nvim" ]; then
    mv $HOME/.config/nvim $HOME/.config/nvim.bak && echo -e "${OK} - Backup of nvim folder successful"
fi

if [ -d "$HOME/.local/share/nvim" ]; then
    mv $HOME/.local/share/nvim $HOME/.local/share/nvim.bak && echo -e "${OK} - Backup of nvim data folder successful"
fi

if git clone https://github.com/nhattVim/MYnvim.git $HOME/.config/nvim --depth 1; then
    sudo npm install neovim -g
    echo -e "${OK} - MYnvim setup completed successfully"
else
    echo -e "${ERROR} - MYnvim setup failed"
fi

# Clone dotfiles
echo -e "\n${NOTE} - Cloning dotfiles..."
if [[ -d /tmp/dotfiles ]]; then
    rm -rf /tmp/dotfiles
fi
git clone -b gnome https://github.com/nhattVim/dotfiles.git /tmp/dotfiles --depth 1 || {
    echo -e "${ERROR} - Failed to clone dotfiles"
    exit 1
}

cd /tmp/dotfiles || {
    echo -e "${ERROR} - Failed to enter dotfiles directory"
    exit 1
}

echo -e "\n${NOTE} - Starting configuration..."

folder=(
    neofetch
    ranger
    tmux
    starship.toml
)

# Back up configuration files
for DIR in "${folder[@]}"; do
    DIRPATH=~/.config/"$DIR"
    if [ -d "$DIRPATH" ]; then
        echo -e "${NOTE} - Found config for $DIR, attempting to back up..."
        BACKUP_DIR=$(get_backup_dirname)
        mv "$DIRPATH" "$DIRPATH-backup-$BACKUP_DIR"
        echo -e "${NOTE} - Backed up $DIR to $DIRPATH-backup-$BACKUP_DIR"
    fi
done

# Copy configuration files
for ITEM in "${folder[@]}"; do
    if [[ -d "config/$ITEM" ]]; then
        cp -r "config/$ITEM" ~/.config
        echo "${OK} - Copy completed"
    elif [[ -f "config/$ITEM" ]]; then
        cp "config/$ITEM" ~/.config
        echo "${OK} - Copy completed"
    fi
done

# Copy other files
cp assets/.zshrc ~ && cp assets/.ideavimrc ~ && { echo "${OK} - Copy completed"; } || {
    echo "${ERROR} - Failed to copy .zshrc and .ideavimrc"
}

# Copy fonts
mkdir -p ~/.fonts
cp -r assets/.fonts/* ~/.fonts/ && { echo "${OK} - Fonts copied successfully"; } || {
    echo "${ERROR} - Failed to copy fonts"
}

# Reload fonts
echo -e "\nRebuilding font cache..."
fc-cache -fv
echo -e "\nFont cache rebuilt."

# Check installation log
if [ -f $HOME/install.log ]; then
    if gum confirm "${CAT} - Do you want to check the installation log?"; then
        if dpkg-query -W -f='${Status}' bat 2>/dev/null | grep -q " installed"; then
            cat_command="bat"
        else
            cat_command="cat"
        fi
        $cat_command $HOME/install.log
    fi
fi

# Change shell to zsh
echo -e "\n${NOTE} - Changing shell to zsh..."
chsh -s $(which zsh) && cd $HOME

echo -e "\n${OK} - Setup completed successfully!"
zsh
