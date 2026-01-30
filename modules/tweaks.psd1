@{
    RootModule        = 'tweaks.psm1'
    ModuleVersion     = '1.0.0'
    Author            = 'Sascha Manns'
    Description       = 'Bootstrapper Tweaks'
    FunctionsToExport = @(
        'Disable-Sleep',
        'Add-ThisPCDesktopIcon',
        'Enable-DeveloperMode',
        'Check-EnableRemoteDesktop',
        'Enable-RemoteDesktop',
        'Remove-ShellBagByGuid',
        'Set-CustomExplorerSettings',
        'Check-DisableLockScreen',
        'DisableLockScreen',
        'Disable-InkWorkspace',
        'Enable-DarkMode',
        'Enable-HardwareAcceleratedGPUScheduling',
        'Add-RunAsAdminContextMenu',
        'Check-AddTakeOwnership',
        'AddTakeOwnership'
    )
}