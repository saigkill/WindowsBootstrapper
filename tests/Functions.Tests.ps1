Describe "Function availability" {

    BeforeAll {
        Import-Module "$PSScriptRoot/../modules/core.psm1" -Force
        Import-Module "$PSScriptRoot/../modules/installers.psm1" -Force
        Import-Module "$PSScriptRoot/../modules/tweaks.psm1" -Force
    }

    $expectedFunctions = @(
        "AddToPath",
        "Add-TakeOwnership",
        "Add-ThisPCDesktopIcon",
        "Add-RunAsAdminContextMenu",
        "Configure-Scoop",
        "Check-AddTakeOwnership",
        "Check-EnableRemoteDesktop",
        "Check-DisableLockScreen",
        "Disable-InkWorkspace",
        "Disable-LockScreen",
        "Enable-DarkMode",
        "Enable-DeveloperMode",
        "Enable-HardwareAcceleratedGPUScheduling",
        "Enable-RemoteDesktop",
        "Disable-Sleep",
        "Get-Localversion",
        "Get-Remoteversion",        
        "Install-WingetApp",
        "Install-WingetApps",
        "Install-Choco",
        "Install-ChocoApps",
        "Install-Scoop",
        "Install-ExternalZip",
        "Install-ExternalExe",
        "Install-FromZIP",
        "Install-FromExe",
        "Invoke-Section",
        "Invoke-Optional",
        "Load-Config",
        "Remove-ShellBagByGuid",
        "Set-CustomExplorerSettings",
        "Set-ExplorerTweaks",
        "Test-Url",
        "Test-Command",
        "Update-Bootstrapper",
        "Write-Log"
    )

    foreach ($fn in $expectedFunctions) {
        It "exports function $fn" {
            Get-Command $fn -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        }
    }
}
