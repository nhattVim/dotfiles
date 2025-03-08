#!/bin/bash
# config wsl

# Source library
. <(curl -sSL https://nhattVim.github.io/lib.sh) && clear

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
if [ -d $HOME/.config/nvim ]; then
    rm -rf $HOME/.config/nvim &&
        ok "Del old neovim folder completed" || err "Failed to del neovim folder"
fi

if [ -d $HOME/.local/share/nvim ]; then
    rm -rf $HOME/.local/share/nvim &&
        ok "Del old neovim data folder completed" || err "Failed to del neovim data folder"
fi

git clone https://github.com/nhattVim/MYnvim.git ~/.config/nvim --depth 1 &&
    ok "Setup MYnvim successfully" || err "Failed to setup MYnvim"

# Clone dotfiles
cd $HOME
if ! cd gnome_nhattVim 2>/dev/null; then
    note "Cloning dotfiles..."
    if git clone -b gnome https://github.com/nhattVim/dotfiles.git --depth 1 gnome_nhattVim; then
        cd gnome_nhattVim
        ok "Cloned dotfiles successfully"
    else
        err "Failed to clone dotfiles"
        exit 1
    fi
fi

note "Starting configuration..."

folder=(
    fastfetch
    ranger
    tmux
)

# Back up configuration files
for DIR in "${folder[@]}"; do
    DIRPATH=~/.config/"$DIR"
    if [ -d "$DIRPATH" ]; then
        note "Config for $DIR found, attempting to back up."
        BACKUP_DIR="$DIRPATH-backup-$(date +%m%d_%H%M)"
        mv "$DIRPATH" "$BACKUP_DIR"
        note "Backup $DIRPATH to $BACKUP_DIR"
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
cp assets/.zshrc ~ && { ok "Copy completed"; } || {
    err "Failed to copy .zshrc and .ideavimrc"
}

# remove dotfiles
cd $HOME
[ -d gnome_nhattVim ] &&
    rm -rf gnome_nhattVim &&
    ok "Remove old dotfiles successfully"

# Check installation log
if [ -f $HOME/install.log ]; then
    gum confirm "${CYAN} Do you want to check log?" && gum pager <$HOME/install.log
fi

# Change shell to zsh
note "Changing shell to zsh..."
chsh -s /bin/zsh
cd $HOME

ok "Setup completed successfully!"
zsh
