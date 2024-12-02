# Settings -----------------------------------------------------
 
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# --------------------------------------------------------------

# Import path -------------------------------------------------
 
export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export ZSH="$HOME/.oh-my-zsh"
export VISUAL="$HOME/.local/bin/nvim"

# --------------------------------------------------------------
 

# Oh My Zsh settings -------------------------------------------
 
ZSH_THEME="af-magic"

plugins=(
    git 
    git-auto-fetch
    aliases
    history
    gradle
    starship
    zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# --------------------------------------------------------------


# User configuration -------------------------------------------

function nvims() {
    items=("Default" "Kickstart" "NvChad" "LazyVim" "AstroNvim")
    config=$(printf "%s\n" "${items[@]}" | fzf --no-sort --preview-window=wrap --preview='echo "nhattruongNeoVim"' --prompt=" Neovim Config  " --height=10% --layout=reverse --border --exit-0)
    if [[ -z $config ]]; then
        echo "Nothing selected"
        return 0
    elif [[ $config == "Default" ]]; then
        config=""
    fi
    NVIM_APPNAME=$config nvim $@
}

# NeoVim Switcher
alias cvim="NVIM_APPNAME=NvChad nvim"
alias lvim="NVIM_APPNAME=LazyVim nvim"
alias kvim="NVIM_APPNAME=Kickstart nvim"
alias avim="NVIM_APPNAME=AstroNvim nvim"

# Nala
alias snuu='sudo nala update && sudo nala upgrade -y'
alias sncc='sudo nala autoremove'
alias snu='sudo nala update'
alias sni='sudo nala install -y'
alias snr='sudo nala remove'
alias snl='sudo nala list --installed | grep'
alias snc='sudo nala clean'

# Apt
alias sauu='sudo apt update && sudo apt upgrade -y'
alias sai='sudo apt install -y'
alias sau='sudo apt update'
alias sar='sudo apt remove'
alias saa='sudo add-apt-repository'
alias sac='sudo apt autoremove'

# Homebrew
alias bruu='brew update && brew upgrade'
alias brr='brew uninstall'
alias bri='brew install'
alias brs='brew search'
alias bru='brew update' 
alias brl='brew list' 
alias brf='brew info' 

# Git
alias ga='git add .'
alias gs='git status'
alias go='git checkout'
alias gc='git commit -m'
alias gp='git push origin'
alias gg="git add . && git commit -m 'update' && git push origin"
alias gcl='git clone'

# Lsd
alias ls='lsd'
alias la='lsd -la'
alias ll='lsd -ll'
alias lt='lsd --tree'
alias lt='lsd --tree -a'
alias ltl='lsd --tree --long'

# Tools
alias cd..='cd ..'
alias sd='sudo'
alias cd-='cd -'
alias lc='lolcat'
alias bat='batcat'
alias se='sudoedit'
alias nf='neofetch'
alias cf='cpufetch'
alias nf='neofetch'
alias btop='bpytop'
alias pipes='pipes.sh'
alias matrix='cmatrix'
alias hack='hollywood'
alias cl='colorscript'
alias xampp='sudo /opt/lampp/lampp'
alias xamppui='sudo /opt/lampp/manager-linux-x64.run'
alias win='sudo efibootmgr --bootnext 0006 && reboot'
alias ip="echo $(ifconfig | grep broadcast | awk '{print $2}')"
alias dl='aria2c --optimize-concurrent-downloads -j 16 -s 16 -x 16 -k 4M'
alias time="arttime --nolearn -a kissingcats -b kissingcats2 -t 'nhattruongNeoVim' --ac 6"

colorscript -e tiefighter2 | lolcat

# --------------------------------------------------------------
