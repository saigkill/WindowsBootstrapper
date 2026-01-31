Describe "Winget installer behavior" {

    BeforeAll {
        Import-Module "$PSScriptRoot/../modules/core.psm1" -Force
        Import-Module "$PSScriptRoot/../modules/installers.psm1" -Force
    }

    It "skips installation when winget is missing" {
        Mock Test-Command { return $false }

        { Install-WingetApps -Config @{ WingetApps = @(); StoreApps = @() } } |
            Should -Not -Throw
    }
}
