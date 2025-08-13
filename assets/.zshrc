# Settings -----------------------------------------------------

bindkey -e
autoload -Uz compinit
compinit -C

HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# --------------------------------------------------------------

# Import path -------------------------------------------------

export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export ZSH="$HOME/.oh-my-zsh"
export VISUAL="$HOME/.local/bin/nvim"

# --------------------------------------------------------------

# NVM settings ------------------------------------------------
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
# --------------------------------------------------------------

# Oh My Zsh settings -------------------------------------------

ZSH_THEME="af-magic"

plugins=(
    git
    git-auto-fetch
    aliases
    history
    gradle
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
alias lta='lsd --tree -a'
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
alias myip="echo $(ifconfig | grep broadcast | awk '{print $2}')"
alias dl='aria2c --enable-http-pipelining=true --max-concurrent-downloads=32 -s 32 -x 16 -k 8M --file-allocation=none --auto-file-renaming=false --summary-interval=0 --console-log-level=warn'
alias time1="arttime --nolearn -a kissingcats -b kissingcats2 -t 'nhattruongNeoVim' --ac 6"
alias time2="tty-clock -c -s"

# --------------------------------------------------------------

fastfetch
