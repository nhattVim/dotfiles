#!/bin/bash
# config wsl

# source library
. <(curl -sSL https://raw.githubusercontent.com/nhattVim/dotfiles/refs/heads/master/scripts/lib.sh)

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

gum style \
    --border-foreground 6 --border rounded \
    --align left --width 104 --margin "1 2" --padding "2 4" \
    "${YELLOW}WARN:${PINK} Ensure that you have a stable internet connection ${YELLOW}(Highly Recommended)          ${RESET}" \
    "                                                                                                               ${RESET}" \
    "${YELLOW}WARN:${PINK} You will be required to answer some questions during the installation                    ${RESET}" \
    "                                                                                                               ${RESET}" \
    "${YELLOW}WARN:${PINK} If you are installing on a VM, ensure to enable 3D acceleration else Hyprland wont start ${RESET}"

echo
choose "Choose your AUR helper" "yay" "paru" aur_helper

exHypr "$aur_helper.sh"

pacman_packages=(
    git unzip tmux starship zsh make python-pip nodejs npm
    ripgrep fzf fastfetch lsd lazygit net-tools neovim bat
    ranger openssh btop wget nvtop cargo python-virtualenv
    lolcat openssh curl aria2
)

aur_packages=(
    shell-color-scripts-git
    arttime-git
    pipes.sh
    cava
)

# reload AUR
ISAUR=$(command -v yay || command -v paru)

# Installation of main components
note "Installing packages"

for PKG1 in "${pacman_packages[@]}"; do
    iPac "$PKG1"
done

for PKG2 in "${aur_packages[@]}"; do
    iAur "$PKG2"
done

# Clone tpm
if [ -d "$HOME/.tmux/plugins/tpm" ]; then
    note "Tmux Plugin Manager is already installed."
else
    act "Cloning TPM (Tmux Plugin Manager)..."
    if git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm --depth 1; then
        ok "TPM (Tmux Plugin Manager) cloned successfully"
    else
        err "Failed to clone TPM (Tmux Plugin Manager)."
    fi
fi

# Install win32yank clipboard
if ! command -v win32yank.exe &>/dev/null; then
    act "Installing win32yank..."
    tmp_win32yank=$(mktemp -d)
    curl -LO https://github.com/equalsraf/win32yank/releases/download/v0.1.1/win32yank-x64.zip &&
        unzip win32yank-x64.zip -d "$tmp_win32yank" &&
        chmod +x "$tmp_win32yank/win32yank.exe" &&
        sudo mv "$tmp_win32yank/win32yank.exe" /usr/local/bin/ &&
        rm -rf "$tmp_win32yank" win32yank-x64.zip
fi

# Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    act "Installing Oh My Zsh..."
    sh -c "$(wget -O- https://install.ohmyz.sh)" "" --unattended && {
        git clone https://github.com/zsh-users/zsh-autosuggestions \
            ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
        ok "Oh My Zsh configured"
    } || err "Oh My Zsh installation failed"
else
    note "Oh My Zsh already installed"
fi

# Set up neovim
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
    ok "Setup neovim successfully" || err "Failed to setup neovim"

# Remove old dotfiles if exist
DOTFILES_DIR=$(mktemp -d)
note "Cloning dotfiles..."
if git clone -b hyprland https://github.com/nhattVim/dotfiles.git --depth 1 "$DOTFILES_DIR"; then
    ok "Cloned dotfiles successfully"
else
    err "Failed to clone dotfiles" && exit 1
fi

folder=(
    neofetch
    fastfetch
    ranger
    tmux
)

note "Copying config files"

# Back up configuration file
for DIR in "${folder[@]}"; do
    DIRPATH=$HOME/.config/"$DIR"
    if [ -d "$DIRPATH" ]; then
        note "Config for $DIR found, attempting to back up."
        BACKUP_DIR="$DIRPATH-backup-$(date +%m%d_%H%M)"
        mv "$DIRPATH" "$BACKUP_DIR"
        note "Backup $DIRPATH to $BACKUP_DIR"
    fi
done

# Copying configuration file
mkdir -p $HOME/.config
for ITEM in "${folder[@]}"; do
    if [[ -d "$DOTFILES_DIR/config/$ITEM" ]]; then
        cp -r "$DOTFILES_DIR/config/$ITEM" ~/.config/ && ok "Copy completed" || err "Failed to copy config files."
    elif [[ -f "$DOTFILES_DIR/config/$ITEM" ]]; then
        cp "$DOTFILES_DIR/config/$ITEM" ~/.config/ && ok "Copy completed" || err "Failed to copy config files."
    fi
done

# Copying other
cp $DOTFILES_DIR/assets/.zshrc $HOME && { ok "Copy completed"; } || {
    err "Failed to copy .zshrc"
}

if [ -f $HOME/install.log ]; then
    gum confirm "${CYAN} Do you want to check log?" && gum pager <$HOME/install.log
fi

# Change shell to zsh
note "Changing default shell to zsh..."

while ! chsh -s /bin/zsh; do
    err "Authentication failed. Please enter the correct password."
    sleep 1
done

note "Shell changed successfully to zsh."

cleanup_backups

# clear packages
note "Clear packages" &&
    sudo pacman -Sc --noconfirm && yay -Sc --noconfirm && yay -Yc --noconfirm &&
    ok "Clearing packages succesfully" || err "Failed to clear packages"

# Successfully
gum style \
    --border-foreground 212 --border rounded \
    --align left --width 80 --margin "1 2" --padding "2 4" \
    "${CYAN}GREAT Copy Completed." "" \
    "${CYAN}YOU NEED to logout and re-login or reboot to avoid issues"

zsh
