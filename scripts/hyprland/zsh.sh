#!/bin/bash
# zsh

# source library
source <(curl -sSL https://is.gd/nhattVim_lib)

# star scripts
clear
gum style \
    --foreground 213 --border-foreground 213 --border rounded \
    --align center --width 50 --margin "1 2" --padding "2 4" \
    "███████╗███████╗██╗  ██╗" \
    "╚══███╔╝██╔════╝██║  ██║" \
    "  ███╔╝ ███████╗███████║" \
    " ███╔╝  ╚════██║██╔══██║" \
    "███████╗███████║██║  ██║" \
    "╚══════╝╚══════╝╚═╝  ╚═╝"

# check dotfiles
cd "$HOME" || exit 1
if [ -d dotfiles ]; then
    cd dotfiles || {
        err "Failed to enter dotfiles config directory"
        exit 1
    }
else
    note "Clone dotfiles." && git clone -b hyprland https://github.com/nhattVim/dotfiles.git --depth 1 || {
        err "Failed to clone dotfiles"
        exit 1
    }
    cd dotfiles || {
        err "Failed to enter dotfiles directory"
        exit 1
    }
fi

# start
aur=()
pacman=(
    zsh
    starship
)

# optional color scripts
printf "\n"
if gum confirm "${CYAN} - Do you want to add color scripts (OPTIONAL)?${RESET}"; then
    echo "${CYAN} - Do you want to add color scripts (OPTIONAL)?" ${YELLOW} Yes ${RESET}
    if gum confirm "${YELLOW} Choose your colors cripts" --affirmative "pokemon-colorscripts" --negative "shell-color-scripts ${RESET}"; then
        aur+=('pokemon-colorscripts-git')
        sed -i '/^# pokemon-colorscripts --no-title -s -r/s/^# *//' assets/.zshrc
    else
        aur+=('shell-color-scripts-git')
        sed -i '/^# colorscript -e tiefighter2/ s/^# //' assets/.zshrc
    fi
else
    echo "${CYAN} - Do you want to add command prompt (OPTIONAL)?" ${YELLOW} No ${RESET}
    echo "${YELLOW} - Skipping color scripts installation."
fi

# optional zsh plugin
printf "\n"
if gum confirm "${CYAN} - Do you want to add zsh plugin (OPTIONAL)?${RESET}"; then
    echo "${CYAN} - Do you want to add zsh plugin (OPTIONAL)? ${YELLOW} Yes ${RESET}"
    echo -e "\n${PINK} SPACE = select/unselect | j/k = down/up | ENTER = confirm. No selection = CANCEL${YELLOW}"
    plugin=$(gum choose --no-limit --cursor-prefix "( ) " --selected-prefix "(x) " --unselected-prefix "( ) " "zsh-autosuggestions" "zsh-syntax-highlighting")

    if [ -z "${plugin}" ]; then
        echo -e "\n\t ${YELLOW} No plugin selected. Installation canceled.${RESET}"
        exit
    else
        echo -e "\n\t ${YELLOW} Plugin selected: " $plugin ${RESET}
    fi

    if [[ $plugin == *"zsh-autosuggestions"* ]]; then
        pacman+=('zsh-autosuggestions')
        sed -i '/^# source \/usr\/share\/zsh\/plugins\/zsh-autosuggestions\/zsh-autosuggestions.zsh/s/^# *//' assets/.zshrc
    fi

    if [[ $plugin == *"zsh-syntax-highlighting"* ]]; then
        pacman+=('zsh-syntax-highlighting')
        sed -i '/^# source \/usr\/share\/zsh\/plugins\/zsh-syntax-highlighting\/zsh-syntax-highlighting.zsh/s/^# *//' assets/.zshrc
    fi
else
    echo -e "${CYAN} - Do you want to add zsh plugin (OPTIONAL)? ${YELLOW} No ${RESET}"
    note "Skipping zsh plugin installation."
fi

# init starship
sed -i '/^# eval "$(starship init zsh)"/ s/^# //' assets/.zshrc

# installing zsh packages
note "Installing core zsh packages..."
for pkg1 in "${pacman[@]}"; do
    iPac "$pkg1"
    if [ $? -ne 0 ]; then
        err "$pkg1 install had failed."
    fi
done

for pkg2 in "${aur[@]}"; do
    iAur "$pkg2"
    if [ $? -ne 0 ]; then
        err "$pkg2 install had failed."
    fi
done

# copying the preconfigured zsh themes and profile
cp assets/.zshrc $HOME && cp assets/.zprofile $HOME && { ok "Copy completed"; } || {
    err "Failed to copy .zshrc"
}

note "Changing default shell to zsh..."

while ! chsh -s /bin/zsh; do
    err "Authentication failed. Please enter the correct password."
    sleep 1
done

note "Shell changed successfully to zsh."
