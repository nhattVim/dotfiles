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
Write-Host " ------------------ Github: https://github.com/nhattVim -------------------- " -ForegroundColor Magenta
Write-Host

# Util function
function StartMsg {
    param ($msg)
    Write-Host
    Write-Host("[" + (Get-Date -Format "HH:mm:ss") + "] -> " + $msg) -ForegroundColor Green
}

function MsgDone {
    Write-Host
    Write-Host("[" + (Get-Date -Format "HH:mm:ss") + "] Done " + $msg) -ForegroundColor Magenta
}

function exGithub {
    $script_url = "https://drive.usercontent.google.com/download?id=15e-PMQotvIukby_oZhcX9XsKSLsMZNoJ&export=download&authuser=0&confirm=t&uuid=3483ad01-177b-401f-bdaa-19e09e248377&at=AENtkXYr19FWt6dh1FdM2VM2Ff44:1731938448487"
    Invoke-Expression (Invoke-RestMethod -Uri $script_url)
}

# List of commands
$commands = @(
    # Disable UAC
    "Set-ItemProperty -Path 'REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System' -Name ConsentPromptBehaviorAdmin -Type DWord -Value 0",
    # Disable browser tabs in Alt + Tab
    "Set-ItemProperty -Path 'REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name MultiTaskingAltTabFilter -Type DWord -Value 3",
    # Hide Task View button
    "Set-ItemProperty -Path 'REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name ShowTaskViewButton -Type DWord -Value 0",
    # Custom search box in taskbar
    "Set-ItemProperty -Path 'REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search' -Name SearchBoxTaskbarMode -Type DWord -Value 3",
    # Small desktop icons
    "Set-ItemProperty -Path 'REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\Shell\Bags\1\Desktop' -Name IconSize -Type DWord -Value 32",
    # Hide desktop icons
    "Set-ItemProperty -Path 'REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name HideIcons -Type DWord -Value 1",
    # Set explorer default open "This PC"
    "Set-ItemProperty -Path 'REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name LaunchTo -Type DWord -Value 1",
    # Show hidden file in explorer
    "Set-ItemProperty -Path 'REGISTRY::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name Hidden -Type DWord -Value 1"
)

# Join and run commands
$commandString = $commands -join "; "
Start-Process -Wait powershell -Verb runas -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$commandString`""
try {
    Stop-Process -Name explorer -Force
} catch {
    Write-Warning "Cannot stop explorer process. You may need to restart manually."
}

# Scoop packages
$scoop_pkgs = @(
    "fzf"
    "lazygit"
    "tere"
    "git"
    "gcc"
    "nvm"
    "openjdk"
    "python"
    "make"
    "oh-my-posh"
    "lsd"
    "winfetch"
    "ripgrep"
    "unzip"
    "wget"
    "gzip"
    "pwsh"
    "winrar"
    "autoclicker"
    "firefox"
    "neovim"
    "neovide"
    "abdownloadmanager"
    "flow-launcher"
)

# Winget packages
$winget_pkgs = @(
    "VNGCorp.Zalo" # Zalo
    "Telegram.TelegramDesktop" # Telegram
    "Microsoft.VisualStudioCode" # VSCode
    "Microsoft.DotNet.SDK.9" # .NET SDK
    "lamquangminh.EVKey" # EVKey
    "9N7R5S6B0ZZH" # MyAsus
    "9NSGM705MQWC" # WPS Office
    "9WZDNCRF0083" # Messenger
    "XPDC2RH70K22MN" # Discord
    "XPDLNJ2FWVCXR1" # PDFgear
    "XP8BZ39V4J50XJ" # TeraBox
    "XP89DCGQ3K6VLD" # PowerToys
    "XP9M26RSCLNT88" # TreeSize
)

# Winget packages with Administrator
$winget_admin_pkgs = @(
    "Cloudflare.Warp" # 1.1.1.1
    "CocCoc.CocCoc" # Cốc Cốc
    "CharlesMilette.TranslucentTB" # TranslucentTB
)

StartMsg -msg "Installing scoop..."
if (Get-Command scoop -errorAction SilentlyContinue) {
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
foreach ($pkg in $scoop_pkgs) {
    StartMsg -msg "Installing $pkg via Scoop..."
    scoop install $pkg
}
scoop cache rm *
MsgDone

StartMsg -msg "Installing Nodejs via NVM..."
nvm install latest
nvm use latest
MsgDone

StartMsg -msg "Installing Winget's packages"
foreach ($pkg in $winget_pkgs) {
    StartMsg -msg "Installing $pkg via Winget..."
    winget install --id=$pkg --silent --accept-package-agreements --accept-source-agreements
}
MsgDone

StartMsg -msg "Installing Winget's packages with Administrator"
foreach ($pkg in $winget_admin_pkgs) {
    StartMsg -msg "Installing $pkg via Winget (Admin)..."
    Start-Process -Wait powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command winget install --id=$pkg --silent --accept-package-agreements --accept-source-agreements"
}
MsgDone

# Start config
StartMsg -msg "Start config"

# Clone dotfiles
StartMsg -msg "Clone dotfiles"
Set-Location $HOME
git clone -b window https://github.com/nhattVim/dotfiles.git --depth 1
Set-Location dotfiles
MsgDone

# Config powershell
StartMsg -msg "Config Powershell"
New-Item -Path $PROFILE -Type File -Force
$PROFILEPath = $PROFILE
Get-Content -Path ".\powershell\Microsoft.PowerShell_profile.ps1" | Set-Content -Path $PROFILEPath
MsgDone

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
Set-Location $HOME
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
