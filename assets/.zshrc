# Zsh Settings -----------------------------------------------------

bindkey -e
autoload -Uz compinit
compinit

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

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export ZSH="$HOME/.oh-my-zsh"
export VISUAL="nvim"

# --------------------------------------------------------------


# Oh My Zsh settings -------------------------------------------

ZSH_THEME="af-magic"

plugins=(
    git
    git-auto-fetch
    aliases
    history
    gradle
    kitty
    themes
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

# Pacman
alias spcc='sudo pacman -Rns $(pacman -Qdtq) --noconfirm'
alias spuu='sudo pacman -Syu --noconfirm'
alias spu='sudo pacman -Syy --noconfirm'
alias spc='sudo pacman -Sc --noconfirm'
alias sps='sudo pacman -Sy --noconfirm'
alias spr='sudo pacman -R'

# Yay
alias syuu='yay -Syu --noconfirm'
alias sycc='yay -Yc --noconfirm'
alias syu='yay -Syy --noconfirm'
alias syc='yay -Sc --noconfirm'
alias sys='yay -Sy --noconfirm'
alias syr='yay -Rns'

# Homebrew
alias bruu='brew update && brew upgrade'
alias brr='brew uninstall'
alias bri='brew install'
alias brs='brew search'
alias bru='brew update'
alias brl='brew list'
alias brf='brew info'

# Git
alias gg="git add . && git commit -m 'update' && git push origin"
alias gp='git push origin'
alias gc='git commit -m'
alias go='git checkout'
alias gs='git status'
alias ga='git add .'
alias gcl='git clone'

# Lsd
alias ls='lsd'
alias la='lsd -la'
alias ll='lsd -ll'
alias lt='lsd --tree'
alias lt='lsd --tree -a'
alias ltl='lsd --tree --long'

# Dotnet
alias dnb="dotnet build"
alias dnr="dotnet run"
alias dnt="dotnet test"
alias dnc="dotnet clean"
alias dnp="dotnet publish"
alias dni="dotnet install"
# Entity Framework Core Migrations
alias dnm="dotnet ef migrations"
alias dnma="dotnet ef migrations add"
alias dnml="dotnet ef migrations list"
alias dnmrm="dotnet ef migrations remove"
alias dnmu="dotnet ef database update"
alias dnminit="dotnet ef migrations add Init && dotnet ef database update"
# Database Management
alias dndu="dotnet ef database update"
alias dndd="dotnet ef database drop"

# Tools
alias cd..='cd ..'
alias sd='sudo'
alias cd-='cd -'
alias lc='lolcat'
alias se='sudoedit'
alias nf='neofetch'
alias cf='cpufetch'
alias nf='neofetch'
alias pipes='pipes.sh'
alias matrix='cmatrix'
alias cl='colorscript'
alias pk='pokemon-colorscripts'
alias xamppui='sudo /opt/lampp/manager-linux-x64.run'
alias win='sudo efibootmgr --bootnext 0006 && reboot'
alias ip="echo $(ifconfig | grep broadcast | awk '{print $2}')"
alias dl='aria2c --enable-http-pipelining=true --max-concurrent-downloads=32 -s 32 -x 16 -k 8M --file-allocation=none --auto-file-renaming=false --summary-interval=0 --console-log-level=warn'
alias time="arttime --nolearn -a kissingcats -b kissingcats2 -t 'nhattruongNeoVim' --ac 6"

# --------------------------------------------------------------

# Prompt init --------------------------------------------------

colorscript -e tiefighter2 | lolcat
source $ZSH/oh-my-zsh.sh

# --------------------------------------------------------------
