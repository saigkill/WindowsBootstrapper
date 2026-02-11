##requires -RunAsAdministrator
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module "$PSScriptRoot\modules\core.psd1" -Force
Import-Module "$PSScriptRoot\modules\installers.psd1" -Force
Import-Module "$PSScriptRoot\modules\tweaks.psd1" -Force
#Update-Bootstrapper

# -----------------------------
# Configuration
# -----------------------------
function Get-Config {
    $devConfigPath  = Join-Path $PSScriptRoot "config/config.Development.json"
    $prodConfigPath = Join-Path $PSScriptRoot "config/config.json"

    if (Test-Path $devConfigPath) {
        Write-Log "Lade Development-Konfiguration: $devConfigPath"
        return Get-Content $devConfigPath -Raw | ConvertFrom-Json
    }

    Write-Log "Development-Konfiguration nicht gefunden. Lade Standard-Konfiguration: $prodConfigPath" "WARN"
    return Get-Content $prodConfigPath -Raw | ConvertFrom-Json
}
$config = Get-Config

# -----------------------------
# OS-Check (Windows 11 prefered)
# -----------------------------

function Assert-Windows11 {
    $os = Get-CimInstance Win32_OperatingSystem
    $build = [int]$os.BuildNumber
    # Windows 11 beginnt bei Build 22000
    if ($build -lt 22000) {
        Write-Log "This Script is optimized for Windows 11 (Build >= 22000). Current: $build" 'WARN'
    }
    else {
        Write-Log "Windows 11 detected (Build $build)."
    }
}

# -----------------------------
# Unneeded Apps
# -----------------------------

function Remove-UnneededApps {
    Write-Log "Deleting Bloatware Apps."

    if ($config.AppsToRemove.Count -eq 0) { 
        Write-Log "AppsToRemove not found. Skipping." "WARN" 
        return 
    }

    foreach ($app in $config.AppsToRemove) {
        Write-Log "Removing App: $app"
        try {
            Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage
            Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "*$app*"} | Remove-AppxProvisionedPackage -Online
        }
        catch {
            Write-Log "App not found '$app': $($_.Exception.Message)" 'INFO'
        }
    }
}

# -----------------------------
# Renaming Computer
# -----------------------------
function Check-RenameComputer {
    Invoke-Optional "Would you like to rename the computer?" {
        $newName = Read-Host "Enter new computer name"
        Rename-ComputerIfNeeded -NewName $newName
    } -DefaultYes $false
}

function Rename-ComputerIfNeeded {
    param(
        [Parameter(Mandatory)][string]$NewName
    )

    $currentName = $env:COMPUTERNAME
    if ($currentName -ne $NewName) {
        Write-Log "Rename Computername from '$currentName' to '$NewName'."
        try {
            Rename-Computer -NewName $NewName
        }
        catch {
            Write-Log "Error while renaming Computer: $($_.Exception.Message)" 'ERROR'
        }
    }
    else {
        Write-Log "Computername already set to '$NewName'. No Change needed."
    }
}

# -----------------------------
# IIS Installation
# -----------------------------
function Check-IISInstallation {
    Invoke-Optional "Install IIS?" {
        Install-IIS
    } -DefaultYes $false
}

function Install-IIS {
    Write-Log "Installing IIS."

    try {
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-DefaultDocument -All
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpCompressionDynamic -All
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpCompressionStatic -All
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebSockets -All
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-ApplicationInit -All
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-ASPNET45 -All
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-ServerSideIncludes
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-BasicAuthentication
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-WindowsAuthentication
        Write-Log "IIS installiert."
    }
    catch {
        Write-Log "Error while installing IIS: $($_.Exception.Message)" 'ERROR'
    }
}

# -----------------------------
# Windows Subsystem for Linux (WSL) Installation
# -----------------------------
function Check-WSLInstallation {
    Invoke-Optional "Install WSL?" {
        Install-WSL
    } -DefaultYes $false
}

function Install-WSL {
    Write-Log "Installing Windows Subsystem for Linux (WSL)."

    try {
        dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
        wsl.exe --install -d
        Write-Log "WSL installed."
    }
    catch {
        Write-Log "Error while Installation from WSL: $($_.Exception.Message)" 'ERROR'
    }
}

# -----------------------------
# Go Installation (Optional)
# -----------------------------
function Check-InstallGo {

    if ([string]::IsNullOrWhiteSpace($config.Variables.GoVersion)) { 
        Write-Log "GoVersion not found. Skipping." "WARN" 
        return 
    }

    Invoke-Optional "Install Go $config.Variables.GoVersion?" {
        Install-Go
    } -DefaultYes $false
}


function Install-Go {
    Write-Log "Installing Go $config.Variables.GoVersion."

    try {
        winget install GoLang.Go.$config.Variables.GoVersion
        Write-Log "Go $config.Variables.GoVersion installed."
    }
    catch {
        Write-Log "Error while Installation of Go: $($_.Exception.Message)" 'ERROR'
    }
}

# ------------------------------
# Rust (Optional)
# -----------------------------
function Check-InstallRust {
    Invoke-Optional "Install Rust?" {
        Install-Rust
    } -DefaultYes $false
}

function Install-Rust {
    Write-Log "Installing Rust."

    try {
        winget install Rustlang.Rust.MSVC
        Write-Log "Rust installied."
    }
    catch {
        Write-Log "Error while Installation of Rust: $($_.Exception.Message)" 'ERROR'
    }
}

# -----------------------------
# Anndroid Studio Installation (Optional)
# -----------------------------
function CheckAndroidStudio {
    Invoke-Optional "Install Android Studio?" {
        Install-AndroidStudio
    } -DefaultYes $false
    
}

function Install-AndroidStudio {
    Write-Log "Installing Android Studio."

    try {
        winget install Google.AndroidStudio
        Write-Log "Android Studio installed."
    }
    catch {
        Write-Log "Error while Installation of Android Studio: $($_.Exception.Message)" 'ERROR'
    }
}

# -----------------------------
# Android CLI Installation (Optional)
# -----------------------------
function Check-InstallAndroidCLI {
    Invoke-Optional "Install Android CLI?" {
        Install-AndroidCLI
    } -DefaultYes $false
}
function Install-AndroidCLI {
    Write-Log "Installing Android CLI."

    try {
        winget install Google.PlatformTools
        Write-Log "Android CLI installed."
    }
    catch {
        Write-Log "Error while Installation of Android CLI: $($_.Exception.Message)" 'ERROR'
    }
}

# ------------------------------
# Powershell Modules
# -----------------------------
function Import-RequiredModules {
    if ($config.PowershellModules.Count -eq 0) { 
        Write-Log "PowershellModules not found. Skipping." "WARN" 
        return 
    }
    foreach($module in $config.PowershellModules){        
        Write-Host "Installing module $module"
            try {
                Install-Module $module
                WriteLog "Installed PS $module"    
            }
            catch{
                Write-Log "Error while installing module $module."
            }
    }
}

# -----------------------------
# Git Credential Manager
# -----------------------------
function Install-GitCredentialManager {
    Write-Log "Installing Git Credential Manager."

    try {
        winget install Git.GCM
        Write-Log "Git Credential Manager installed."
    }
    catch {
        Write-Log "Error while Installation of Git Credential Manager: $($_.Exception.Message)" 'ERROR'
    }
}

# -----------------------------
# Typescript
# -----------------------------
function Check-InstallTypescript {
    Invoke-Optional "Install Typescript?" {
        Install-Typescript
    } -DefaultYes $false
}

function Install-Typescript {
    Write-Log "Installing Typescript."

    try {
        npm install -g typescript
        Write-Log "Typescript installed."
    }
    catch {
        Write-Log "Error while Installation of Typescript: $($_.Exception.Message)" 'ERROR'
    }
}

# ------------------------------
# Inshellisense
# -----------------------------
function Check-InstallInshellisense {
    Invoke-Optional "Install Inshellisense?" {
        Install-Inshellisense
    } -DefaultYes $false
}

function Install-Inshellisense {
    Write-Log "Installing Inshellisense."

    try {
        npm install -g inshellisense
        Write-Log "Inshellisense installed."
    }
    catch {
        Write-Log "Error while Installation of Inshellisense: $($_.Exception.Message)" 'ERROR'
    }
}

# -----------------------------
# Github Copilot
# -----------------------------
function Install-GithubCopilot {
    Write-Log "Installing Github Copilot."

    try {
        npm install -g @github/copilot
        Write-Log "Github Copilot installed."
    }
    catch {
        Write-Log "Error while Installation of Github Copilot: $($_.Exception.Message)" 'ERROR'
    }
}

# ------------------------------
# Dotnet Tools Installation
# -----------------------------
function Check-InstallDotnetTools {
    Invoke-Optional "Install dotnet Tools?" {
        Install-DotnetTools
    } -DefaultYes $false
}

function Install-DotnetTools {
    Write-Log "Installing dotnet Tools."
    dotnet tool install --global dotnet-ef
    if ($config.DotnetWorkloads.Count -eq 0) { 
        Write-Log "DotnetWorkloads not found. Skipping." "WARN" 
        return 
    }
    foreach($workload in $config.DotnetWorkloads){
        try {        
            sudo dotnet workload install $workload
            Write-Log "dotnet Tool $workload installed."
        }   
        catch {
            Write-Log "Error while Installation of dotnet Tools: $($_.Exception.Message)" 'ERROR'
        }
    }    
}

# ------------------------------
# Exclude Pathes for Defender
# -----------------------------
function Check-ExcludeDefenderPathes {
    Invoke-Optional "Exclude Defender Pathes? (If you use other Antivirus Software, you can skip this step)" {
        Exclude-DefenderPathes
    } -DefaultYes $false
}

function Exclude-DefenderPathes {
    if ($config.ExcludeDefenderPathes.Count -eq 0) { 
        Write-Log "ExcludeDefenderPathes not found. Skipping." "WARN" 
        return 
    }

    foreach ($path in $config.ExcludeDefenderPathes) {
        Write-Log "Adding Windows Defender Exclusions: $path"
        try {
            Add-MpPreference -ExclusionPath $path
        }
        catch {
            Write-Log "Error while adding Defender-Exclusions for '$path': $($_.Exception.Message)" 'ERROR'
        }
    }
}

# ------------------------------
# Sync time with timeserver
# -----------------------------
function Sync-TimeWithServer {  
    Write-Log "Synchronisizing Time."

    try {
        net stop w32time
        net start w32time
        w32tm /resync /force
        w32tm /query /status
        Set-TimeZone -Name $config.Variables.Timezone
        Write-Log "Time synchronized. Used Timezone: $config.Variables.Timezone"
    }
    catch {
        Write-Log "Error while Time-Synchronisation: $($_.Exception.Message)" 'ERROR'
    }
}

# ------------------------------
# Install Microsoft Artifacts Credential Manager
# -----------------------------
function Install-MicrosoftArtifactsCredentialManager {
    Write-Log "Installing Microsoft Artifacts Credential Manager."

    try {
        iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/microsoft/artifacts-credprovider/master/helpers/installcredprovider.ps1'))
        Write-Log "Microsoft Artifacts Credential Manager installed."
    }
    catch {
        Write-Log "Error while Installation of Microsoft Artifacts Credential Manager: $($_.Exception.Message)" 'ERROR'
    }
}

# -----------------------------
# Install Awesome Windows Terminal Fonts
# -----------------------------
function Install-AwesomeWindowsTerminalFonts {
    Write-Log "Installing Awesome Windows Terminal Fonts."

    try {
        pushd $pwd/../external
        cd awesome-terminal-fonts
        Start-Process -FilePath "install.ps1" -NoNewWindow -Wait
        popd
        Write-Log "Awesome Windows Terminal Fonts installed."
    }
    catch {
        Write-Log "Error while Installation of Awesome Windows Terminal Fonts: $($_.Exception.Message)" 'ERROR'
    }
}

# ------------------------------
# Check for Windows Updates
# -----------------------------
function Check-WindowsUpdates {
    Write-Log "Checking Windows Updates."

    try {
        Install-Module -Name PSWindowsUpdate -Force
        Get-WindowsUpdate -AcceptAll -Install -ForceInstall
        Write-Log "Windows Updates checked and installed."
    }
    catch {
        Write-Log "Error while checking Windows Updates: $($_.Exception.Message)" 'ERROR'
    }
}

# -----------------------------
# Adding Pathes to PATH
# -----------------------------
function AddPathesToPATH {
    Write-Log "Adding Pathes to PATH."
    
    if ($config.PathesForPATH.Count -eq 0) { 
        Write-Log "PathesForPATH not found. Skipping." "WARN" 
        return 
    }

    try{
        foreach($path in $config.PathesForPATH){
            Add-ToPath $path
            Write-Log "Added $path to PATH"
        }
        Write-Log "Added all Pathes to PATH"
    }
    catch{
        Write-Log "Error while adding Pathes to PATH: $($_.Exception.Message)" 'ERROR'
    }
}

# -----------------------------
# After Installation Notes
# -----------------------------
function Show-ManualSteps {
    if ($config.ManualApps.Count -eq 0) { 
        Write-Log "ManualApps not found. Skipping." "WARN" 
        return 
    }

    Write-Log "Some steps are needed after Installation:"
    $desktop = [Environment]::GetFolderPath("Desktop") 
    $outFile = Join-Path $desktop "AfterInstallation.txt" 
    $config.ManualApps | Out-File -FilePath $outFile -Encoding UTF8 
    Write-Log "Check file on Desktop: $outFile"
}

# -----------------------------
# Hauptablauf
# -----------------------------

Write-Log "Deploy-Script started."
Assert-Windows11

# ------------------------------
# Cleanup
# ------------------------------
Invoke-Section "Removing Bloatware" { Remove-UnneededApps }

# ------------------------------
# Installations
# ------------------------------
Invoke-Section "Paketmanager: Scoop installing" { Install-Scoop }
Invoke-Section "Paketmanager: Scoop configuring" { Configure-Scoop -Config $config }
Invoke-Section "Paketmanager: Winget-Apps" { Install-WingetApps -Config $config }
Invoke-Section "Chocolatey installing" { Install-Choco }
Invoke-Section "Paketmanager: Choco-Apps" { Install-ChocoApps -Config $config }
Invoke-Section "External ZIP-Installations" { Install-FromZip -Config $config }
Invoke-Section "External EXE-Installations" { Install-FromExe -Config $config }
Invoke-Section "IIS Installation" { Check-IISInstallation }
Invoke-Section "WSL Installation" { Check-WSLInstallation }
Invoke-Section "Go Installation" { Check-InstallGo }
Invoke-Section "Rust Installation" { Check-InstallRust }
Invoke-Section "Android Studio Installation" { CheckAndroidStudio }
Invoke-Section "Installing PowerShell-Modules" { Import-RequiredModules }
Invoke-Section "Installing Git Credential Manager" { Install-GitCredentialManager }
Invoke-Section "Installing Typescript" { Check-InstallTypescript }
Invoke-Section "Installing Inshellisense" { Check-InstallInshellisense }
Invoke-Section "Installing Github Copilot" { Install-GithubCopilot }
Invoke-Section "Installing Dotnet Tools" { Check-InstallDotnetTools }
Invoke-Section "Installing Android CLI" { Check-InstallAndroidCLI }
Invoke-Section "Grouping Rubbish Folders" { Remove-ShellBagByGuid }
Invoke-Section "Applying custom Explorer-Settings" { Set-CustomExplorerSettings }
Invoke-Section "Disable Ink Workspace" { Disable-InkWorkspace }
Invoke-Section "Installing Microsoft Artifacts Credential Manager" { Install-MicrosoftArtifactsCredentialManager }
Invoke-Section "Installing Awesome Windows Terminal Fonts" { Install-AwesomeWindowsTerminalFonts }

# ------------------------------
# Tweaks and Settings
# ------------------------------
Invoke-Section "Disabling Sleepmode" { Disable-Sleep }
Invoke-Section "Disabling LockScreen" { Check-DisableLockScreen }
Invoke-Section "Adding 'This PC' Desktop-Symbol" { Add-ThisPCDesktopIcon }
Invoke-Section "Adding 'Take Ownership'" { Check-AddTakeOwnership }
Invoke-Section "Enabling Developermode" { Enable-DeveloperMode }
Invoke-Section "Enabling Remote Desktop" { Check-EnableRemoteDesktop }
Invoke-Section "Computer renaming" { Check-RenameComputer }
Invoke-Section "Enabling Dark Mode" { Enable-DarkMode }
Invoke-Section "Sync Time with Timeserver" { Sync-TimeWithServer }
Invoke-Section "Enable Hardware Accelerated GPU-Scheduling" { Enable-HardwareAcceleratedGPUScheduling }
Invoke-Section "Add 'Execute as Administrator' to Contextmenu" { Add-RunAsAdminContextMenu }

# ------------------------------
# Pathes
# -----------------------------
Invoke-Section "Adding Defender Exclusion-Pathes" { Check-ExcludeDefenderPathes }
Invoke-Section "Adding needed Pathes to PATH" { AddPathesToPATH }

# ------------------------------
# Final Steps
# ------------------------------
Invoke-Section "Checking Windows Updates" { Check-WindowsUpdates }
Invoke-Section "Show manual todos" { Show-ManualSteps }

Read-Host -Prompt "Setup is done, restart is needed, press [ENTER] to restart computer."
Restart-Computer
Write-Log "Deploy-Script finished."