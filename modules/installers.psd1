@{
    RootModule        = 'installers.psm1'
    ModuleVersion     = '1.0.0'
    Author            = 'Sascha Manns'
    Description       = 'Bootstrapper installers'
    FunctionsToExport = @(
        'Install-WingetApp',
        'Install-WingetApps',
        'Install-Choco',
        'Install-ChocoApps',
        'Install-Scoop',
        'Configure-Scoop',
        'Install-FromZip',
        'Install-FromExe'    
    )
}