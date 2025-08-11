# ------------------------
# History
set -U fish_history (math 1000)

# ------------------------
# PATH & Env
set -Ux PATH $HOME/.local/bin $HOME/.cargo/bin $HOME/.dotnet/tools $PATH
set -Ux VISUAL nvim

# ------------------------
# Aliases
alias cvim="NVIM_APPNAME=NvChad nvim"
alias lvim="NVIM_APPNAME=LazyVim nvim"
alias kvim="NVIM_APPNAME=Kickstart nvim"
alias avim="NVIM_APPNAME=AstroNvim nvim"

# Pacman
alias spcc='sudo pacman -Rns (pacman -Qdtq) --noconfirm'
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
alias lta='lsd --tree -a'
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
alias dnminit="dotnet ef migrations add Init; and dotnet ef database update"
# Database Management
alias dndu="dotnet ef database update"
alias dndd="dotnet ef database drop"

# Tools
alias cd..='cd ..'
alias sd='sudo'
alias cd-='cd -'
alias lc='lolcat'
alias se='sudoedit'
alias cf='cpufetch'
alias nf='neofetch'
alias pipes='pipes.sh'
alias matrix='cmatrix'
alias cl='colorscript'
alias pk='pokemon-colorscripts'
alias xamppui='sudo /opt/lampp/manager-linux-x64.run'
alias win='sudo efibootmgr --bootnext 0006 && reboot'
alias myip='ifconfig | grep broadcast | awk "{print \$2}"'
alias dl='aria2c --enable-http-pipelining=true --max-concurrent-downloads=32 -s 32 -x 16 -k 8M --file-allocation=none --auto-file-renaming=false --summary-interval=0 --console-log-level=warn'
alias mytime='arttime --nolearn -a kissingcats -b kissingcats2 -t "nhattruongNeoVim" --ac 6'

# ------------------------
# Neovim Switcher (fzf)
function nvims
    set items "Default" "Kickstart" "NvChad" "LazyVim" "AstroNvim"
    set config (printf "%s\n" $items | fzf --no-sort --preview-window=wrap --preview='echo Config: {}' --prompt=" Neovim Config  " --height=10% --layout=reverse --border --exit-0)

    if test -z "$config"
        echo "Nothing selected"
        return 0
    else if test "$config" = "Default"
        set config ""
    end
    NVIM_APPNAME=$config nvim $argv
end

# ------------------------
# Prompt init
if status is-interactive
    # Starship custom prompt
    starship init fish | source

    # Custom colours
    cat ~/.local/state/caelestia/sequences.txt 2> /dev/null

    # For jumping between prompts in foot terminal
    function mark_prompt_start --on-event fish_prompt
        echo -en "\e]133;A\e\\"
    end
end
