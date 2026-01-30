@{
    RootModule = 'core.psm1' 
    ModuleVersion = '1.0.0' 
    Author = 'Sascha Manns' 
    Description = 'Bootstrapper core functions' 
    FunctionsToExport = @( 
        'Get-LocalVersion', 
        'Get-RemoteVersion', 
        'Update-Bootstrapper', 
        'Load-Config',
        'Write-Log',
        'Invoke-Section',
        'Invoke-Optional',
        'Test-Url',
        'Test-Command',
        'AddToPath',
        'Write-Log',
        'Invoke-Section',
        'Invoke-Optional',
        'Test-Url',
        'Test-Command',
        'AddToPath' )
}