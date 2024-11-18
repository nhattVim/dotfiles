#!/bin/bash
# config wsl

# source library
source <(curl -sSL https://is.gd/nhattruongNeoVim_lib) && clear

# require
exScriptGnome "boot.sh"

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
    " ------------------- Script developed by nhattruongNeoVim ------------------- " \
    "                                                                              " \
    "  -------------- Github: https://github.com/nhattruongNeoVim ---------------  " \
    "                                                                              "

gum style \
    --foreground 6 --border-foreground 6 --border rounded \
    --align left --width 90 --margin "1 2" --padding "2 4" \
    "$(tput setaf 3)NOTE:$(tput setaf 6) Ensure that you have a stable internet connection $(tput setaf 3)(Highly Recommended!!!!)$(tput sgr0)" \
    "                                                                                                                             $(tput sgr0)" \
    "$(tput setaf 3)NOTE:$(tput setaf 6) You will be required to answer some questions during the installation!!                  $(tput sgr0)" \
    "                                                                                                                             $(tput sgr0)" \
    "$(tput setaf 3)NOTE:$(tput setaf 6) If you are installing on a VM, ensure to enable 3D acceleration!                         $(tput sgr0)"

# install package
exScriptGnome "pkgs.sh"

# config MYnvim
printf "\n%s - Setup MYnvim ... \n" "${NOTE}"
[ -d "$HOME/.config/nvim" ] && mv $HOME/.config/nvim $HOME/.config/nvim.bak &&
    printf "\n%s - Backup nvim folder successfully \n" "${OK}"
[ -d "$HOME/.local/share/nvim" ] && mv $HOME/.local/share/nvim $HOME/.local/share/nvim.bak &&
    printf "\n%s - Failed to backup nvim-data folder \n" "${OK}"
if git clone https://github.com/nhattruongNeoVim/MYnvim.git $HOME/.config/nvim --depth 1; then
    sudo npm install neovim -g
    printf "\n%s - Setup MYnvim successfully \n" "${OK}"
else
    printf "\n%s - Failed to setup MYnvim \n" "${ERROR}"
fi

# clone dotfiles
printf "\n%s - Clone dotfiles ... \n" "${NOTE}"
[[ -d /tmp/dotfiles ]] && rm -rf /tmp/dotfiles
git clone -b gnome https://github.com/nhattruongNeoVim/dotfiles.git /tmp/dotfiles --depth 1 || {
    printf "\n%s - Failed to clone dotfiles \n" "${ERROR}"
    exit 1
}
cd /tmp/dotfiles || {
    printf "\n%s - Failed to enter dotfiles directory \n" "${ERROR}"
    exit 1
}

printf "\n%s - Start config .... \n" "${NOTE}"

folder=(
    neofetch
    ranger
    tmux
    starship.toml
)

# back up configuration file
for DIR in "${folder[@]}"; do
    DIRPATH=~/.config/"$DIR"
    if [ -d "$DIRPATH" ]; then
        printf "\n%s - Config for $DIR found, attempting to back up. \n" "${NOTE}"
        BACKUP_DIR=$(get_backup_dirname)
        mv "$DIRPATH" "$DIRPATH-backup-$BACKUP_DIR"
        printf "\n%s - Backed up $DIR to $DIRPATH-backup-$BACKUP_DIR. \n" "${NOTE}"
    fi
done

# copying configuration file
for ITEM in "${folder[@]}"; do
    if [[ -d "config/$ITEM" ]]; then
        cp -r "config/$ITEM" ~/.config
        echo "${OK} Copy completed" || echo "${ERROR} Failed to copy config files."
    elif [[ -f "config/$ITEM" ]]; then
        cp "config/$ITEM" ~/.config
        echo "${OK} Copy completed" || echo "${ERROR} Failed to copy config files."
    fi
done

# copying other
cp assets/.zshrc ~ && cp assets/.ideavimrc ~ && { echo "${OK} Copy completed"; } || {
    echo "${ERROR} Failed to copy .zshrc && .ideavimrc"
}

# copying font
mkdir -p ~/.fonts
cp -r assets/.fonts/* ~/.fonts/ && { echo "${OK} Copy fonts completed"; } || {
    echo "${ERROR} Failed to copy fonts files."
}

# reload fonts
printf "\n%.0s" {1..2}
fc-cache -fv
printf "\n%.0s" {1..2}

# check log
if [ -f $HOME/install.log ]; then
    if gum confirm "${CAT} - Do you want to check log?"; then
        if pacman -Q bat &>/dev/null; then
            cat_command="bat"
        else
            cat_command="cat"
        fi
        $cat_command $HOME/install.log
    fi
fi

# Chang shell to zsh
printf "\n%s - Change shell to zsh \n" "${NOTE}"
chsh -s $(which zsh) && cd $HOME

printf "\n%.0s" {1..2}
printf "\n%s - Yey! Setup Completed \n" "${OK}"
printf "\n%.0s" {1..2}

zsh
