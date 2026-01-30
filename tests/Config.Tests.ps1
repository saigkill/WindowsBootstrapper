Describe "Configuration loading" {

    BeforeAll {
        Import-Module "$PSScriptRoot/../modules/core.psm1" -Force
    }

    It "loads config.json without error" {
        { Load-Config } | Should -Not -Throw
    }

    It "returns a PowerShell object" {
        $config = Load-Config
        $config | Should -BeOfType [pscustomobject]
    }    
}
