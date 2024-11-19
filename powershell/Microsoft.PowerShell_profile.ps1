# Remove files or directories
function rm
{
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string[]]$Path,

        [switch]$Force,

        [switch]$Recurse
    )
    foreach ($item in $Path)
    {
        if (-not (Test-Path -LiteralPath $item))
        {
            Write-Error "Path '$item' does not exist."
            continue
        }
        Remove-Item -Path $item -Force:$Force.IsPresent -Recurse:$Recurse.IsPresent
    }
}

# Copy files or directories
function cp
{
    param (
        [Parameter(Mandatory=$true)]
        [string]$Source,

        [Parameter(Mandatory=$true)]
        [string]$Destination,

        [switch]$Recurse
    )
    Copy-Item -Path $Source -Destination $Destination -Recurse:$Recurse.IsPresent
}

# Move or rename files/directories
function mv
{
    param (
        [Parameter(Mandatory=$true)]
        [string]$Source,

        [Parameter(Mandatory=$true)]
        [string]$Destination
    )
    Move-Item -Path $Source -Destination $Destination
}

# Create directories
function mkdir
{
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    New-Item -ItemType Directory -Path $Path
}

# Create file
function touch
{
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    if (Test-Path -LiteralPath $Path)
    {
        (Get-Item -Path $Path).LastWriteTime = Get-Date
    } else
    {
        New-Item -Type File -Path $Path
    }
}

# Display file contents
function cat
{
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    Get-Content -Path $Path
}


# Where is command
function which ($command)
{
    Get-Command -Name $command -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

# Get directory
function pwd
{
    Get-Location
}

# Tere
function tere
{
    $result = . (Get-Command -CommandType Application tere) $args
    if ($result)
    {
        Set-Location $result
    }
}

# Neovim switcher
function nvims()
{
    $items = "default", "nvim-astro", "nvim-nvchad", "nvim-lazy"
    $config = $items | fzf --prompt="  Neovim Config" --height=~50% --layout=reverse --border --exit-0

    if ([string]::IsNullOrEmpty($config))
    {
        Write-Output "Nothing selected"
        break
    }

    if ($config -eq "default")
    {
        $config = ""
    }

    $env:NVIM_APPNAME=$config
    nvim $args
}

# Nvim AstroNvim
function AstroVim
{
    $env:NVIM_APPNAME="nvim-astro"
    nvim
}

# Nvim NvChad
function NvChad
{
    $env:NVIM_APPNAME="nvim-nvchad"
    nvim
}

# Nvim LazyVim
function LazyVim 
{
    $env:NVIM_APPNAME="nvim-lazy"
    nvim
}

# Lsd ll
function ll
{
    lsd -lh $args
}

# Lsd la
function la
{
    lsd -alh $args
}

# Scoop list
function scl
{
    scoop list
}

# Scoop help
function sch
{
    scoop help
}

# Scoop cache rm *
function scc
{
    scoop cache rm *
}

# Scoop cleanup *
function sccc
{
    scoop cleanup *
}

# Scoop update *
function scuu
{
    scoop update *
}

# Scoop update 
function scu
{
    param (
        [string]$keyword
    )
    scoop update $keyword
}

# Scoop search
function scs
{
    param (
        [string]$keyword
    )
    scoop search $keyword
}

# Scoop install
function sci
{
    param (
        [string]$packageName
    )
    scoop install $packageName
}

# Scoop uninstall
function scr
{
    param (
        [string]$packageName
    )
    scoop uninstall $packageName
}

# Init prompt
oh-my-posh init pwsh --config '~/scoop/apps/oh-my-posh/current/themes/amro.omp.json' | Invoke-Expression
winfetch
