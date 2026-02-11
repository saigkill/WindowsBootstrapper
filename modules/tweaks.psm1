# -----------------------------
# Disable Sleep
# -----------------------------
function Disable-Sleep {
    Write-Log "Disable Sleepmode."

    try {
        powercfg -change -standby-timeout-ac 0
        powercfg -change -monitor-timeout-ac 20
        powercfg -change -hibernate-timeout-ac 0
        Write-Log "Sleepmode disabled."
    }
    catch {
        Write-Log "Error while disabling Sleepmode: $($_.Exception.Message)" 'ERROR'
    }
}

# -----------------------------
# Add "This PC" Desktop Icon
# -----------------------------
function Add-ThisPCDesktopIcon {
    Write-Log "Add 'This PC' Desktop-Symbol."

    try {
        $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
        $thisPCIconRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
        $thisPCRegValname = "{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
        $item = Get-ItemProperty -Path $thisPCIconRegPath -Name $thisPCRegValname -ErrorAction SilentlyContinue
        if ($item) {
            Set-ItemProperty  -Path $thisPCIconRegPath -name $thisPCRegValname -Value 0
        }
        else {
            New-ItemProperty -Path $thisPCIconRegPath -Name $thisPCRegValname -Value 0 -PropertyType DWORD | Out-Null
        }
        Write-Log "'This PC' Symbol added."
    }
    catch {
        Write-Log "Error while adding 'This PC' Symbol: $($_.Exception.Message)" 'ERROR'
    }
}

# -----------------------------
# Developer Mode
# -----------------------------
function Enable-DeveloperMode {
    Write-Log "Enabling Developer Mode."

    try {
        $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
        try{
            New-Item -Path $regPath -Force | Out-Null
        }
        catch {
            Write-Debug "Registry key already exists or cannot be created, continuing..."
        }
        
        Set-ItemProperty -Path $regPath -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -Type DWord
        Write-Log "Developer Mode enabled."
    }
    catch {
        Write-Log "Error while activating Developer Mode: $($_.Exception.Message)" 'ERROR'
    }
}

# -----------------------------
# Remote Desktop Enable (optional)
# -----------------------------
function Check-EnableRemoteDesktop {
    Invoke-Optional "Enable Remote Desktop?" {
        Enable-RemoteDesktop
    } -DefaultYes $false
}

function Enable-RemoteDesktop {
    Write-Log "Enable Remote Desktop."

    try {
        Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\" -Name "UserAuthentication" -Value 1
        Write-Log "Remote Desktop enabled."
    }
    catch {
        Write-Log "Error while enabling Remote Desktop: $($_.Exception.Message)" 'ERROR'
    }
}

# ------------------------------
# Rubbish folder grouping
# -----------------------------
function Remove-ShellBagByGuid {
    param(
        [string]$Guid = '{885a186e-a440-4ada-812b-db871b942259}'
    )

    $bagsPath = 'HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags'

    try {
        $items = Get-ChildItem $bagsPath -Recurse | Where-Object { $_.PSChildName -eq $Guid }

        if ($items) {
            Write-Log "Entferne ShellBag-Einträge für GUID $Guid"
            $items | Remove-Item -Recurse -Force
        }
        else {
            Write-Log "Keine ShellBag-Einträge für GUID $Guid gefunden"
        }
    }
    catch {
        Write-Log "Fehler beim Entfernen der ShellBag-Einträge: $($_.Exception.Message)" "ERROR"
    }
}

# ------------------------------
# Custom Explorer Settings
# -----------------------------
function Set-CustomExplorerSettings {

    Write-Log "Applying custom Explorer-Settings"

    # Key anlegen, Fehler ignorieren
    try {
        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -ErrorAction Stop | Out-Null
    }
    catch {
        # Nur loggen, wenn du willst – aber kein Abbruch
        Write-Log "Registry key already exists or cannot be created, continuing..."
    }

    try {
        $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

        Set-ItemProperty -Path $path -Name HideFileExt     -Value 0 -Type DWord
        Set-ItemProperty -Path $path -Name AutoCheckSelect -Value 0 -Type DWord
        Set-ItemProperty -Path $path -Name LaunchTo        -Value 1 -Type DWord
        Set-ItemProperty -Path $path -Name ShowSuperHidden -Value 1 -Type DWord
        Set-ItemProperty -Path $path -Name Hidden          -Value 1 -Type DWord

        Write-Log "Applied Explorer-Settings"
    }
    catch {
        Write-Log "Error while applying Explorer-Setting: $($_.Exception.Message)" 'ERROR'
    }
}


# ------------------------------
# Disable Lock Screen
# ------------------------------
function Check-DisableLockScreen {
    Invoke-Optional "Disable LockScreen?" {
        DisableLockScreen
    } -DefaultYes $false
}

function DisableLockScreen {
    Write-Log "Disabling LockScreen"
    try{
        try{
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" -Force | Out-Null
        }
        catch{
            Write-Debug "Registry key already exists or cannot be created, continuing..."
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" -Name NoLockScreen 1
    }
    catch{
        Write-Log "Error while disabling LockScreen: $($_.Exception.Message)" 'ERROR'
    }
}

# ------------------------------
# Disable Ink Workspace
# -----------------------------
function Disable-InkWorkspace {
    Write-Log "Disabling Ink Workspace."

    try {
        $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Pen"
        try{
            New-Item -Path $regPath -Force | Out-Null
        }
        catch {
            Write-Debug "Registry key already exists or cannot be created, continuing..."
        }
        Set-ItemProperty -Path $regPath -Name "PenWorkspaceButtonDesiredVisibility" -Value 0 -Type DWord
        Write-Log "Ink Workspace disabled."
    }
    catch {
        Write-Log "Error while disabling Ink Workspace: $($_.Exception.Message)" 'ERROR'
    }
}

# ------------------------------
# Darkmode
# -----------------------------
function Enable-DarkMode {
    Write-Log "Enabling Dark Mode."

    try {
        $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
        try{
            New-Item -Path $regPath -Force | Out-Null
        }
        catch {
            Write-Debug "Registry key already exists or cannot be created, continuing..."
        }
        Set-ItemProperty -Path $regPath -Name "AppsUseLightTheme" -Value 0 -Type DWord
        Set-ItemProperty -Path $regPath -Name "SystemUsesLightTheme" -Value 0 -Type DWord
        Write-Log "Dark Mode enabled."
    }
    catch {
        Write-Log "Error while enabling the Dark Mode: $($_.Exception.Message)" 'ERROR'
    }
}

# -----------------------------
# EnableHardware-Accelerated GPU Scheduling
# -----------------------------
function Enable-HardwareAcceleratedGPUScheduling {
    Write-Log "Enabling Hardware-Acclerated GPU-Scheduling."

    try {
        $regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
        try{
            New-Item -Path $regPath -Force | Out-Null
        }
        catch {
            Write-Debug "Registry key already exists or cannot be created, continuing..."
        }
        Set-ItemProperty -Path $regPath -Name "HwSchMode" -Value 2 -Type DWord
        Write-Log "Enabled Hardware-Acclerated GPU-Scheduling."
    }
    catch {
        Write-Log "Error while enabling Hardware-Acclerated GPU-Scheduling: $($_.Exception.Message)" 'ERROR'
    }
}

# -----------------------------
# Add 'Run As Administrator' to Context Menu
# -----------------------------
function Add-RunAsAdminContextMenu {    
    Write-Log "Add 'Execute as Administrator' to Contextmenu."

    try {
        $regPath = "HKCR:\*\shell\RunAsAdmin"
        try{
            New-Item -Path $regPath -Force | Out-Null
        }
        catch {
            Write-Debug "Registry key already exists or cannot be created, continuing..."
        }
        Set-ItemProperty -Path $regPath -Name "HasLUAShield" -Value "" -Type String
        Set-ItemProperty -Path $regPath -Name "(Default)" -Value "Als Administrator ausführen" -Type String
        $commandPath = Join-Path $regPath "command"
        try{
            New-Item -Path $commandPath -Force | Out-Null
        }
        catch {
            Write-Debug "Registry key already exists or cannot be created, continuing..."
        }
        $ps = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
        Set-ItemProperty -Path $commandPath -Name "(Default)" -Value "$ps -Command `"Start-Process '%1' -Verb runAs`"" -Type String
        Write-Log "''Execute as Administrator' added."
    }
    catch {
        Write-Log "Error while adding 'Execute as Administrator': $($_.Exception.Message)" 'ERROR'
    }
}

# -----------------------------
# Add 'Take Ownership' to Context Menu
# -----------------------------
function Check-AddTakeOwnership {
    Invoke-Optional "Enable 'Take Ownership'?" {
        AddTakeOwnership
    } -DefaultYes $false
}

function AddTakeOwnership {
    Write-Log "Add 'Take Ownership' to Contextmenu."

    try{
        reg.exe import ./windows-registry/Add_Take_Ownership_to_context_menu.reg
        reg.exe import ./windows-registry/Add_Take_Ownership_with_Pause_to_context_menu.reg
        Write-Log "Added 'Take Ownership' to Context Menu"
    }
    catch{
        Write-Log "Error while adding 'Take Ownership' to Context Menu"
    }
}