#Requires -RunAsAdministrator

#region Banner and Header
# =============================================================================
#                              BANNER AND HEADER
# =============================================================================

$banner = @"
 ____   __ __   ____  ______      ______  ____   __ __   ___   ____    ____ 
|    \ |  |  | /    ||      |    |      ||    \ |  |  | /   \ |    \  /    |
|  _  ||  |  ||  o  ||      |    |      ||  D  )|  |  ||     ||  _  ||   __|
|  |  ||  _  ||     ||_|  |_|    |_|  |_||    / |  |  ||  O  ||  |  ||  |  |
|  |  ||  |  ||  _  |  |  |        |  |  |    \ |  :  ||     ||  |  ||  |_ |
|  |  ||  |  ||  |  |  |  |        |  |  |  .  \|     ||     ||  |  ||     |
|__|__||__|__||__|__|  |__|        |__|  |__|\_| \__,_| \___/ |__|__||___,_|
"@

Write-Host "$banner" -ForegroundColor Magenta
Write-Host "`n------------------------ Script developed by nhattVim ------------------------" -ForegroundColor Magenta
Write-Host " ------------------ Github: https://github.com/nhattVim --------------------`n" -ForegroundColor Magenta
#endregion

#region Utility Functions
# =============================================================================
#                              UTILITY FUNCTIONS
# =============================================================================

function Write-Log {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [System.ConsoleColor]$Color = 'Green'
    )
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "[$timestamp] -> $Message" -ForegroundColor $Color
}

function Write-ErrorLog {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message
    )
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "[$timestamp] ERROR: $Message" -ForegroundColor Red
}

function Write-TaskDone {
    param ($TaskName = "Task")
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "[$timestamp] ✔ Done: $TaskName`n" -ForegroundColor Magenta
}
#endregion

#region Configuration Variables
# =============================================================================
#                           CONFIGURATION VARIABLES
# =============================================================================

# Temporary directory for dotfiles
$dotfilesTempDir = Join-Path $env:TEMP "dotfiles"

# List of Scoop packages
$scoopPackages = @(
    "fzf", "lazygit", "tere", "git", "gcc", "nvm", "yarn", "openjdk", "python",
    "make", "oh-my-posh", "lsd", "winfetch", "fastfetch", "ripgrep", "unzip",
    "wget", "gzip", "pwsh", "winrar", "autoclicker", "firefox", "neovim",
    "neovide", "abdownloadmanager", "flow-launcher"
)

# List of Winget packages (user context)
$wingetPackages = @(
    "RamenSoftware.Windhawk", "VNGCorp.Zalo", "Telegram.TelegramDesktop",
    "Microsoft.VisualStudioCode", "Microsoft.DotNet.SDK.9", "lamquangminh.EVKey",
    "9N7R5S6B0ZZH", # MyAsus
    "9NSGM705MQWC", # WPS Office
    "XPDC2RH70K22MN", # Discord
    "XPDLNJ2FWVCXR1", # PDFgear
    "XP8BZ39V4J50XJ", # TeraBox
    "XP9M26RSCLNT88"  # TreeSize
)

# List of Winget packages (admin context)
$wingetAdminPackages = @(
    "CocCoc.CocCoc"
)
#endregion

#region Helper Functions
# =============================================================================
#                               HELPER FUNCTIONS
# =============================================================================

function Set-WindowsCustomizations {
    Write-Log "Applying Windows registry customizations..."
    $commands = @(
        # Dark theme
        "Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name AppsUseLightTheme -Value 0",
        "Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name SystemUsesLightTheme -Value 0",
        # Disable UAC (ConsentPromptBehaviorAdmin=0 means elevate without prompting)
        "Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System' -Name ConsentPromptBehaviorAdmin -Value 0",
        # Disable browser tabs in Alt + Tab
        "Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name MultiTaskingAltTabFilter -Value 3",
        # Hide Task View button
        "Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name ShowTaskViewButton -Value 0",
        # Custom search box in taskbar (3 = Search icon only)
        "Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' -Name SearchBoxTaskbarMode -Value 3",
        # Small desktop icons
        "Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\Shell\Bags\1\Desktop' -Name IconSize -Value 32 -ErrorAction SilentlyContinue",
        # Hide desktop icons
        "Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name HideIcons -Value 1",
        # Set explorer default open "This PC"
        "Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name LaunchTo -Value 1",
        # Show hidden files in explorer
        "Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name Hidden -Value 1"
    )
    
    $commandString = $commands -join "; "
    Start-Process -Wait powershell -Verb runas -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$commandString`""
    
    try {
        Stop-Process -Name explorer -Force -ErrorAction Stop
        Write-Log "Explorer process restarted to apply changes."
    }
    catch {
        Write-ErrorLog "Failed to restart explorer. A manual restart may be required."
    }
    Write-TaskDone "Windows customizations"
}

function Install-Packages {
    param(
        [Parameter(Mandatory=$true)]
        [string]$PackageManager, # 'scoop' or 'winget'
        [Parameter(Mandatory=$true)]
        [string[]]$Packages,
        [switch]$AsAdmin
    )

    Write-Log "Installing packages via $PackageManager..."
    foreach ($pkg in $Packages) {
        Write-Log "Installing $pkg..."
        $command = ""
        switch ($PackageManager) {
            'scoop'  { $command = "scoop install $pkg" }
            'winget' { $command = "winget install --id=$pkg --silent --accept-package-agreements --accept-source-agreements" }
            default  { Write-ErrorLog "Unknown package manager: $PackageManager"; return }
        }

        try {
            if ($AsAdmin) {
                Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$command`"" -Wait
            } else {
                Invoke-Expression $command -ErrorAction Stop
            }
        }
        catch {
            Write-ErrorLog "Failed to install $pkg."
        }
    }
    Write-TaskDone "$PackageManager packages installation"
}

function Copy-Config {
    param(
        [Parameter(Mandatory=$true)]
        [string]$SourceName, # e.g., 'fastfetch'
        [Parameter(Mandatory=$true)]
        [string]$DestinationPath,
        [switch]$IsFile
    )

    $sourcePath = Join-Path $dotfilesTempDir $SourceName
    if (!(Test-Path $sourcePath)) {
        Write-ErrorLog "Source '$SourceName' not found in dotfiles."
        return
    }

    $parentDir = if ($IsFile) { Split-Path $DestinationPath -Parent } else { $DestinationPath }
    if (!(Test-Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }

    Copy-Item -Path $sourcePath -Destination $DestinationPath -Recurse -Force
    Write-Log "Copied '$SourceName' configuration successfully."
}

function Setup-Github {
    Write-Log "Setting up SSH keys from GitHub..."
    Add-Type -AssemblyName System.Windows.Forms
    
    # GUI Prompt for GitHub Token
    $form = New-Object System.Windows.Forms.Form -Property @{ Text = "GitHub Token"; Width = 400; Height = 150; StartPosition = "CenterScreen" }
    $label = New-Object System.Windows.Forms.Label -Property @{ Text = "Paste your GitHub token:"; AutoSize = $true; Location = New-Object System.Drawing.Point(10, 20) }
    $textbox = New-Object System.Windows.Forms.TextBox -Property @{ Location = New-Object System.Drawing.Point(10, 50); Width = 360; UseSystemPasswordChar = $true }
    $okButton = New-Object System.Windows.Forms.Button -Property @{ Text = "OK"; Location = New-Object System.Drawing.Point(150, 80) }
    $okButton.Add_Click({ $form.Close() })
    $form.Controls.AddRange(@($label, $textbox, $okButton))
    $form.ShowDialog() | Out-Null
    $token = $textbox.Text

    if ([string]::IsNullOrWhiteSpace($token)) {
        Write-ErrorLog "GitHub token is empty. Aborting SSH setup."
        return
    }

    $sshDir = Join-Path $env:USERPROFILE ".ssh"
    $tempRepoDir = Join-Path $env:TEMP "temp_secrets_$(New-Guid)"
    $repoUrl = "https://$($token)@github.com/nhattVim/sshKey"
    New-Item -ItemType Directory -Path $sshDir -ErrorAction SilentlyContinue | Out-Null
    
    try {
        Write-Log "Cloning SSH key repository..."
        git clone --quiet $repoUrl $tempRepoDir
        if ($LASTEXITCODE -ne 0) { throw "Git clone failed." }

        $privateKeySrc = Join-Path $tempRepoDir "window/id_ed25519"
        $publicKeySrc  = Join-Path $tempRepoDir "window/id_ed25519.pub"
        
        if ((Test-Path $privateKeySrc) -and (Test-Path $publicKeySrc)) {
            Copy-Item -Path $privateKeySrc -Destination $sshDir -Force
            Copy-Item -Path $publicKeySrc -Destination $sshDir -Force
            Write-Log "SSH keys copied."
            
            # Set permissions
            $privateKeyDest = Join-Path $sshDir "id_ed25519"
            icacls $privateKeyDest /inheritance:r /grant:r "$($env:USERNAME):(F)" | Out-Null
            Write-Log "Private key permissions set."
        } else {
            throw "SSH key files not found in the repository."
        }

        # Configure SSH
        $sshConfigPath = Join-Path $sshDir "config"
        @"
Host github.com
    StrictHostKeyChecking no
    UserKnownHostsFile NUL
"@ | Set-Content -Path $sshConfigPath -Encoding ASCII -Force
        Write-Log "SSH config created."

        # Configure Git
        git config --global user.name "nhattvim"
        git config --global user.email "nhattruong13112000@gmail.com"
        git config --global core.autocrlf false
        Write-Log "Git user configured."
    }
    catch {
        Write-ErrorLog "Failed to set up SSH keys. $_"
    }
    finally {
        if (Test-Path $tempRepoDir) {
            Remove-Item -Recurse -Force $tempRepoDir
        }
    }
    Write-TaskDone "SSH Key Setup"
}

function Prompt-ForRestart {
    Add-Type -AssemblyName System.Windows.Forms
    $result = [System.Windows.Forms.MessageBox]::Show(
        "Do you want to restart your computer now to apply the changes?",
        "Restart Required",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )
    if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
        Write-Log "Restarting computer..."
        Restart-Computer -Force
    }
}
#endregion

#region Main Execution
# =============================================================================
#                               MAIN EXECUTION
# =============================================================================

# -- Step 1: Apply Windows Customizations --
Set-WindowsCustomizations

# -- Step 2: Install Scoop and its packages --
Write-Log "Installing Scoop..."
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
} else {
    Write-Log "Scoop is already installed." -Color Yellow
}
Write-Log "Initializing Scoop buckets..."
scoop install git
scoop bucket add extras
scoop bucket add nerd-fonts
scoop bucket add java
scoop update
Install-Packages -PackageManager 'scoop' -Packages $scoopPackages
scoop cache rm * | Out-Null
Write-TaskDone "Scoop Setup"

# -- Step 3: Install Node.js via NVM --
Write-Log "Installing latest Node.js via NVM..."
try {
    nvm install latest
    nvm use latest
    Write-TaskDone "Node.js installation"
} catch {
    Write-ErrorLog "Failed to install Node.js. Is NVM installed correctly?"
}

# -- Step 4: Install Winget packages --
Install-Packages -PackageManager 'winget' -Packages $wingetPackages
Install-Packages -PackageManager 'winget' -Packages $wingetAdminPackages -AsAdmin
Write-TaskDone "Winget package installations"

# -- Step 5: Clone dotfiles and configure applications --
Write-Log "Cloning dotfiles for configuration..."
if (Test-Path $dotfilesTempDir) { Remove-Item $dotfilesTempDir -Recurse -Force }
git clone -b window https://github.com/nhattVim/dotfiles.git --depth 1 $dotfilesTempDir

if ($LASTEXITCODE -eq 0) {
    # PowerShell Profile
    Copy-Config -SourceName "powershell\Microsoft.PowerShell_profile.ps1" -DestinationPath $PROFILE -IsFile
    
    # Fastfetch config
    $configDir = Join-Path $env:USERPROFILE ".config"
    Copy-Config -SourceName "fastfetch" -DestinationPath $configDir

    # Windhawk
    $windhawkScript = Join-Path $dotfilesTempDir "windhawk\windhawk-backup.ps1"
    Copy-Config -SourceName "windhawk\windhawk-backup.zip" -DestinationPath "$env:USERPROFILE\Downloads\windhawk-backup.zip" -IsFile
    if (Test-Path $windhawkScript) {
        Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$windhawkScript`" -Action R" -Wait
    }

    # Flow Launcher
    $flowLauncherAppPath = (Get-Item "$env:USERPROFILE\scoop\apps\flow-launcher\current\app-*").FullName
    $flowSettingsDir = Join-Path $flowLauncherAppPath "UserData\Settings\Settings.json"
    Copy-Config -SourceName "flow-launcher\Settings.json" -DestinationPath $flowSettingsDir -IsFile
    
    Write-TaskDone "Application Configuration"
} else {
    Write-ErrorLog "Failed to clone dotfiles repository. Skipping configuration."
}

# -- Step 7: Configure Neovim --
Write-Log "Configuring Neovim..."
$nvimConfigPath = Join-Path $env:LOCALAPPDATA "nvim"
$nvimDataPath = Join-Path $env:LOCALAPPDATA "nvim-data"
if (Test-Path $nvimConfigPath) { Remove-Item $nvimConfigPath -Recurse -Force }
if (Test-Path $nvimDataPath) { Remove-Item $nvimDataPath -Recurse -Force }

try {
    git clone https://github.com/nhattVim/MYnvim $nvimConfigPath --depth 1
    # Install dependencies
    pip install pynvim
    npm install -g neovim
    Write-TaskDone "Neovim Configuration"
} catch {
    Write-ErrorLog "Failed to clone Neovim configuration."
}

# -- Step 8: Cleanup and Start Apps --
Write-Log "Cleaning up temporary files..."
if (Test-Path $dotfilesTempDir) { Remove-Item $dotfilesTempDir -Recurse -Force }
Write-TaskDone "Cleanup"

Write-Log "Starting essential applications..."
try {
    # Sử dụng đường dẫn đầy đủ cho Windhawk
    Start-Process (Join-Path $env:ProgramFiles "Windhawk\windhawk.exe") -ErrorAction Stop
    Start-Process (Join-Path $env:UserProfile "scoop\apps\flow-launcher\current\Flow.Launcher.exe") -ErrorAction Stop    Start-Process "C:\Program Files\WindowsApps\28017CharlesMilette.TranslucentTB_2024.3.0.0_x64__v826wp6bftszj\TranslucentTB.exe"
}
catch {
    Write-ErrorLog "An error occurred while starting applications. A restart or manual start might be needed. Error: $_"
}
Write-TaskDone "Application Start"

# -- Step 9: Final Restart Prompt --
Prompt-ForRestart
#endregion
