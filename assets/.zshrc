# Set up the prompt

autoload -Uz promptinit
promptinit
# prompt adam1

setopt histignorealldups sharehistory

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit

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

# ---------------- Color script -----------------
# pokemon-colorscripts --no-title -s -r
# colorscript -e tiefighter2
# -----------------------------------------------
# ------------------ Starship -------------------
# eval "$(starship init zsh)"
# -----------------------------------------------
# --------------------------------- ZSH plugin ------------------------------------
# source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
# source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# ---------------------------------------------------------------------------------

# export path
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export VISUAL="nvim"

# NeoVim Switcher
alias nvim-chad="NVIM_APPNAME=NvChad nvim"
alias nvim-lazy="NVIM_APPNAME=LazyVim nvim"
alias nvim-kick="NVIM_APPNAME=Kickstart nvim"
alias nvim-astro="NVIM_APPNAME=AstroNvim nvim"

# mutil nvim
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

# chatgpt
function aa() {
    tgpt $1
}

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
alias dl='aria2c --optimize-concurrent-downloads -j 16 -s 16 -x 16 -k 4M'
alias time="arttime --nolearn -a kissingcats -b kissingcats2 -t 'nhattruongNeoVim' --ac 6"
