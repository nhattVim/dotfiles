<#
.SYNOPSIS
    Backup or restore Windhawk configuration, mods, and registry settings.

.DESCRIPTION
    This script checks if Windhawk is installed, then prompts the user
    to either create a backup or restore from an existing backup. The
    backup includes the ModsSource folder, the Engine\Mods folder, and
    the Windhawk registry settings.

    By default, it stores or retrieves the backup from:
        $env:USERPROFILE\Downloads\windhawk-backup.zip
#>

[CmdletBinding()]
param()

###############################################################################
#                            CONFIGURABLE VARIABLES                           #
###############################################################################

# Where the final backup zip should be stored or restored from:
$backupZipPath = Join-Path $env:USERPROFILE "Downloads\windhawk-backup.zip"

# The root Windhawk installation folder:
$windhawkRoot  = "C:\ProgramData\Windhawk"

# Registry key where Windhawk stores its settings:
$registryKey   = "HKLM:\SOFTWARE\Windhawk"

###############################################################################
#                               HELPER FUNCTIONS                              #
###############################################################################

function Test-WindhawkInstalled {
    param(
        [string]$WindhawkFolder
    )
    if (Test-Path $WindhawkFolder) {
        return $true
    } else {
        return $false
    }
}

function Do-Backup {
    param(
        [string]$WindhawkFolder,
        [string]$BackupPath,
        [string]$RegistryKey
    )

    Write-Host "`n--- Starting Windhawk backup ---" -ForegroundColor Cyan
    
    # Create a temporary folder to stage the backup contents
    $timeStamp    = (Get-Date -Format 'yyyyMMddHHmmss')
    $backupFolder = Join-Path $env:TEMP ("WindhawkBackup_$timeStamp")
    New-Item -ItemType Directory -Path $backupFolder -Force | Out-Null

    # Prepare Engine folder structure inside the backup
    $engineFolder = Join-Path $backupFolder "Engine"
    New-Item -ItemType Directory -Path $engineFolder -Force | Out-Null

    # Define the paths to copy from
    $modsSourceFolder = Join-Path $WindhawkFolder "ModsSource"
    $modsFolder       = Join-Path $WindhawkFolder "Engine\Mods"

    # Copy ModsSource if it exists
    if (Test-Path $modsSourceFolder) {
        Write-Host "Copying ModsSource folder..."
        Copy-Item -Path $modsSourceFolder -Destination $backupFolder -Recurse -Force
    } else {
        Write-Warning "ModsSource folder not found at: $modsSourceFolder"
    }

    # Copy Mods folder if it exists
    if (Test-Path $modsFolder) {
        Write-Host "Copying Engine\Mods folder..."
        Copy-Item -Path $modsFolder -Destination $engineFolder -Recurse -Force
    } else {
        Write-Warning "Mods folder not found at: $modsFolder"
    }

    # Export registry key
    Write-Host "Exporting Windhawk registry key..."
    $regExportFile = Join-Path $backupFolder "Windhawk.reg"
    # Using reg.exe for consistent export. /y overwrites without prompt.
    reg export "HKLM\SOFTWARE\Windhawk" $regExportFile /y | Out-Null

    # Create/overwrite the existing backup zip
    if (Test-Path $BackupPath) {
        Write-Host "Removing existing backup zip at: $BackupPath"
        Remove-Item $BackupPath -Force
    }

    Write-Host "Compressing backup to: $BackupPath"
    Compress-Archive -Path (Join-Path $backupFolder '*') -DestinationPath $BackupPath -Force

    Write-Host "`nBackup completed successfully!"
    Write-Host "Backup archive saved to: $BackupPath"
}

function Do-Restore {
    param(
        [string]$WindhawkFolder,
        [string]$BackupPath,
        [string]$RegistryKey
    )

    Write-Host "`n--- Starting Windhawk restore ---" -ForegroundColor Cyan

    # Check if the backup zip exists
    if (!(Test-Path $BackupPath)) {
        Write-Warning "Backup zip not found at: $BackupPath"
        return
    }

    # Create a temporary folder to extract contents
    $timeStamp     = (Get-Date -Format 'yyyyMMddHHmmss')
    $extractFolder = Join-Path $env:TEMP ("WindhawkRestore_$timeStamp")
    New-Item -ItemType Directory -Path $extractFolder -Force | Out-Null

    Write-Host "Extracting backup zip: $BackupPath"
    Expand-Archive -Path $BackupPath -DestinationPath $extractFolder -Force

    # After extraction, we expect:
    #   ModsSource in the root of $extractFolder
    #   Engine\Mods in $extractFolder\Engine
    #   Windhawk.reg also in $extractFolder

    $modsSourceBackup = Join-Path $extractFolder "ModsSource"
    $modsBackup       = Join-Path $extractFolder "Engine\Mods"
    $regBackup        = Join-Path $extractFolder "Windhawk.reg"

    # Copy ModsSource back if present
    if (Test-Path $modsSourceBackup) {
        Write-Host "Copying ModsSource to Windhawk folder..."
        Copy-Item -Path $modsSourceBackup -Destination $WindhawkFolder -Recurse -Force
    } else {
        Write-Warning "ModsSource not found in backup."
    }

    # Copy Mods back if present
    if (Test-Path $modsBackup) {
        Write-Host "Copying Engine\Mods to Windhawk folder..."
        # Ensure Engine folder exists
        $engineFolder = Join-Path $WindhawkFolder "Engine"
        if (!(Test-Path $engineFolder)) {
            New-Item -ItemType Directory -Path $engineFolder -Force | Out-Null
        }
        Copy-Item -Path $modsBackup -Destination $engineFolder -Recurse -Force
    } else {
        Write-Warning "Mods folder not found in backup."
    }

    # Import registry if present
    if (Test-Path $regBackup) {
        Write-Host "Importing Windhawk registry settings..."
        reg import $regBackup | Out-Null
    } else {
        Write-Warning "Windhawk registry file not found in backup."
    }

    Write-Host "`nRestore completed successfully!"
}

###############################################################################
#                                 MAIN SCRIPT                                 #
###############################################################################

Write-Host "Checking if Windhawk is installed at: $windhawkRoot"

if (!(Test-WindhawkInstalled -WindhawkFolder $windhawkRoot)) {
    Write-Warning "`nWindhawk folder not found at: $windhawkRoot"
    $choice = Read-Host "Windhawk might not be installed. Continue anyway? (y/n)"
    if ($choice -notmatch '^(y|Y)$') {
        Write-Host "Exiting."
        return
    }
}

Write-Host "`nWould you like to (B)ackup or (R)estore or (E)xit?"
$action = Read-Host "Enter your choice (B/R/E)"

switch ($action.ToUpper()) {
    'B' {
        Do-Backup -WindhawkFolder $windhawkRoot -BackupPath $backupZipPath -RegistryKey $registryKey
    }
    'R' {
        Do-Restore -WindhawkFolder $windhawkRoot -BackupPath $backupZipPath -RegistryKey $registryKey
    }
    'E' {
        Write-Host "Exiting script."
    }
    Default {
        Write-Host "Unrecognized choice. Exiting."
    }
}

Write-Host "`nDone."

