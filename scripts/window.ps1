Write-Host "   ____   __ __   ____  ______      ______  ____   __ __   ___   ____    ____ " -ForegroundColor Magenta
Write-Host "  |    \ |  |  | /    ||      |    |      ||    \ |  |  | /   \ |    \  /    |" -ForegroundColor Magenta
Write-Host "  |  _  ||  |  ||  o  ||      |    |      ||  D  )|  |  ||     ||  _  ||   __|" -ForegroundColor Magenta
Write-Host "  |  |  ||  _  ||     ||_|  |_|    |_|  |_||    / |  |  ||  O  ||  |  ||  |  |" -ForegroundColor Magenta
Write-Host "  |  |  ||  |  ||  _  |  |  |        |  |  |    \ |  :  ||     ||  |  ||  |_ |" -ForegroundColor Magenta
Write-Host "  |  |  ||  |  ||  |  |  |  |        |  |  |  .  \|     ||     ||  |  ||     |" -ForegroundColor Magenta
Write-Host "  |__|__||__|__||__|__|  |__|        |__|  |__|\_| \__,_| \___/ |__|__||___,_|" -ForegroundColor Magenta
Write-Host ""
Write-Host ""
Write-Host "------------------------ Script developed by nhattVim ------------------------" -ForegroundColor Magenta
Write-Host " ------------------ Github: httpls://github.com/nhattVim -------------------- " -ForegroundColor Magenta
Write-Host 

# Util function
function StartMsg {
    param ($msg)
    Write-Host("-> " + $msg) -ForegroundColor Green
}

function MsgDone { 
    Write-Host "Done" -ForegroundColor Magenta;
    Write-Host 
}

function exGithub {
    $script_url = "https://drive.usercontent.google.com/download?id=15e-PMQotvIukby_oZhcX9XsKSLsMZNoJ&export=download&authuser=0&confirm=t&uuid=3483ad01-177b-401f-bdaa-19e09e248377&at=AENtkXYr19FWt6dh1FdM2VM2Ff44:1731938448487"
    Invoke-Expression (Invoke-RestMethod -Uri $script_url)
}

# Start
Start-Process -Wait powershell -verb runas -ArgumentList "Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0"

StartMsg -msg "Installing scoop..."
if (Get-Command scoop -errorAction SilentlyContinue)
{
    Write-Warning "Scoop already installed"
}
else {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}
MsgDone

StartMsg -msg "Initializing Scoop..."
    scoop install git
    scoop bucket add extras
    scoop bucket add nerd-fonts
    scoop bucket add java
    scoop update
MsgDone

StartMsg -msg "Installing Scoop's packages"
    scoop install <# apps #> flow-launcher oh-my-posh fzf winrar lsd winfetch lazygit tere autoclicker ventoy firefox
    scoop install <# coding #> git gcc nodejs openjdk python make ripgrep neovim neovide
    scoop install <# requirements for mason_neovim #> unzip wget gzip pwsh
    # scoop install <# custom apps #> paint.net windhawk qutebrowser
    scoop cache rm *
MsgDone

StartMsg -msg "Start config"

# Clone dotfiles
StartMsg -msg "Clone dotfiles"
    cd $HOME
    git clone -b window https://github.com/nhattVim/dotfiles.git --depth 1
    cd dotfiles
MsgDone

# Config powershell
StartMsg -msg "Config Powershell"
    New-Item -Path $PROFILE -Type File -Force
    $PROFILEPath = $PROFILE
    Get-Content -Path ".\powershell\Microsoft.PowerShell_profile.ps1" | Set-Content -Path $PROFILEPath
MsgDone

# Config Alacritty
# StartMsg -msg "Config Alacritty"
#     $DestinationPath = "~\AppData\Roaming\alacritty"
#     If (-not (Test-Path $DestinationPath)) {
#         New-Item -ItemType Directory -Path $DestinationPath -Force
#     }
#     Copy-Item ".\alacritty\alacritty.yml" -Destination $DestinationPath -Force
# MsgDone

# Config Neovim
StartMsg -msg "Config Neovim"
    $DestinationPath = "$env:LOCALAPPDATA"
    If (-not (Test-Path $DestinationPath)) {
        New-Item -ItemType Directory -Path $DestinationPath -Force
    }

    $NvimPath = Join-Path $DestinationPath "nvim"
    $NvimDataPath = Join-Path $DestinationPath "nvim-data"

    if (Test-Path $NvimPath) {
        Remove-Item -Path $NvimPath -Recurse -Force
        Write-Warning "!!!Remove nvim folder"
    }

    if (Test-Path $NvimDataPath) {
        Remove-Item -Path $NvimDataPath -Recurse -Force
        Write-Warning "!!!Remove nvim data folder"
    }

    git clone https://github.com/nhattVim/MYnvim "$NvimPath" --depth 1

    pip install pynvim
    npm install neovim -g
MsgDone

# Remove dotfiles
StartMsg -msg "Remove dotfiles"
    cd $HOME
    Remove-Item dotfiles -Recurse -Force
MsgDone

# StartMsg -msg "Installing choco..."
# if (Get-Command choco -errorAction SilentlyContinue)
# {
#     Write-Warning "Choco already installed"
# }
# else {
#     Start-Process -Wait powershell -verb runas -ArgumentList "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
#     Start-Process -Wait powershell -verb runas -ArgumentList "choco feature enable -n allowGlobalConfirmation"
# }
# MsgDone
#
# StartMsg -msg "Installing Choco's packages"
#     Start-Process -Wait powershell -verb runas -ArgumentList "choco install zalopc internet-download-manager vmwareworkstation" 
#     # Start-Process -Wait powershell -verb runas -ArgumentList "choco install steam bluestacks" 
# MsgDone

# StartMsg -msg "Enable Virtualiztion"
# Start-Process -Wait powershell -verb runas -ArgumentList @"
#     Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -Norestart
#     Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -All -Norestart
#     Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -All -Norestart
#     Enable-WindowsOptionalFeature -Online -FeatureName Contaniners -All -Norestart
# "@
# MsgDone

# StartMsg -msg "Installing WSl..."
# if(!(wsl -l -v)){
#     wsl --install
#     wsl --update
#     wsl --install --no-launch --web-download -d Ubuntu
# }
# else {
#     Write-Warning "Wsl installed"
# }
# MsgDone
 
MsgDone
