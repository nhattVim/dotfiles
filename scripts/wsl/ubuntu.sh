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
    --border-foreground 6 --border rounded \
    --align left --width 90 --margin "1 2" --padding "2 4" \
    "${YELLOW}WARN:${PINK} Ensure that you have a stable internet connection ${YELLOW}(Highly Recommended)  ${RESET}" \
    "                                                                                                       ${RESET}" \
    "${YELLOW}WARN:${PINK} You will be required to answer some questions during the installation            ${RESET}" \
    "                                                                                                       ${RESET}" \
    "${YELLOW}WARN:${PINK} If you are installing on a VM, ensure to enable 3D acceleration else             ${RESET}"

# Install package
exGnome "pkgs.sh"

# Config MYnvim
note "Setting up MYnvim..."
if [ -d "$HOME/.config/nvim" ]; then
    mv $HOME/.config/nvim $HOME/.config/nvim.bak && ok "Backup of nvim folder successful"
fi

if [ -d "$HOME/.local/share/nvim" ]; then
    mv $HOME/.local/share/nvim $HOME/.local/share/nvim.bak && ok "Backup of nvim data folder successful"
fi

if git clone https://github.com/nhattVim/MYnvim.git $HOME/.config/nvim --depth 1; then
    sudo npm install neovim -g
    ok "MYnvim setup completed successfully"
else
    err "MYnvim setup failed"
fi

# Clone dotfiles
note "Clone dotfiles"
if [[ -d /tmp/dotfiles ]]; then
    rm -rf /tmp/dotfiles
fi
git clone -b gnome https://github.com/nhattVim/dotfiles.git /tmp/dotfiles --depth 1 || {
    err "Failed to clone dotfiles"
    exit 1
}

cd /tmp/dotfiles || {
    err "Failed to enter dotfiles directory"
    exit 1
}

note "Starting configuration..."

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
        note "Found config for $DIR, attempting to back up..."
        BACKUP_DIR=$(get_backup_dirname)
        mv "$DIRPATH" "$DIRPATH-backup-$BACKUP_DIR"
        note "Backed up $DIR to $DIRPATH-backup-$BACKUP_DIR"
    fi
done

# Copy configuration files
for ITEM in "${folder[@]}"; do
    if [[ -d "config/$ITEM" ]]; then
        cp -r "config/$ITEM" ~/.config
        ok "Copied $ITEM successfully"
    elif [[ -f "config/$ITEM" ]]; then
        cp "config/$ITEM" ~/.config
        ok "Copied $ITEM successfully"
    fi
done

# Copy other files
cp assets/.zshrc ~ && cp assets/.ideavimrc ~ && { ok "Copy completed"; } || {
    err "Failed to copy .zshrc and .ideavimrc"
}

# Copy fonts
mkdir -p ~/.fonts
cp -r assets/.fonts/* ~/.fonts/ && { ok "Fonts copied successfully"; } || {
    err "Failed to copy fonts"
}

# Reload fonts
note "Rebuilding font cache..."
fc-cache -fv
note "Font cache rebuilt."

# Check installation log
if [ -f $HOME/install.log ]; then
    gum confirm "${CYAN} Do you want to check log?" && gum pager <$HOME/install.log
fi

# Change shell to zsh
note "Changing shell to zsh..."
chsh -s $(which zsh) && cd $HOME

ok "Setup completed successfully!"
zsh
