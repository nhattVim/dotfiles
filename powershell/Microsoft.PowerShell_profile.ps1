# Tere
function Invoke-Tere() {
    $result = . (Get-Command -CommandType Application tere) $args
    if ($result) {
        Set-Location $result
    }
}
Set-Alias tere Invoke-Tere

# Touch
function touch {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    if (Test-Path -LiteralPath $Path) {
        (Get-Item -Path $Path).LastWriteTime = Get-Date
    } else {
        New-Item -Type File -Path $Path
    }
}

# Neovim switcher
function nvims() {
    $items = "default", "nvim-astro", "nvim-nvchad", "nvim-lazy"
    $config = $items | fzf --prompt="  Neovim Config" --height=~50% --layout=reverse --border --exit-0

    if ([string]::IsNullOrEmpty($config)) {
        Write-Output "Nothing selected"
        break
    }

    if ($config -eq "default") {
        $config = ""
    }

    $env:NVIM_APPNAME=$config
    nvim $args
}

# Nvim AstroNvim
function nvim-astro {
    $env:NVIM_APPNAME="nvim-astro"
    nvim
}

# Nvim NvChad
function nvim-chad {
    $env:NVIM_APPNAME="nvim-nvchad"
    nvim
}

# Nvim LazyVim
function nvim-lazy {
    $env:NVIM_APPNAME="nvim-lazy"
    nvim
}

# Which
function which ($command) {
    Get-Command -Name $command -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

# Lsd ll
function ll {
    lsd -lh $args
}

# Lsd la
function la {
    lsd -alh $args
}

# Scoop list
function scl {
    scoop list
}

# Scoop help
function sch {
    scoop help
}

# Scoop cache rm *
function scc {
    scoop cache rm *
}

# Scoop cleanup *
function sccc {
    scoop cleanup *
}

# Scoop update *
function scuu {
    scoop update *
}

# Scoop update 
function scu {
    param (
        [string]$keyword
    )
    scoop update $keyword
}

# Scoop search
function scs {
    param (
        [string]$keyword
    )
    scoop search $keyword
}

# Scoop install
function sci {
    param (
        [string]$packageName
    )
    scoop install $packageName
}

# Scoop uninstall
function scr {
    param (
        [string]$packageName
    )
    scoop uninstall $packageName
}

# Init prompt
oh-my-posh init pwsh --config '~/scoop/apps/oh-my-posh/current/themes/amro.omp.json' | Invoke-Expression
winfetch
