Describe "Module loading" {
    It "loads core module" {
        { Import-Module "$PSScriptRoot/../modules/core.psm1" -Force } | Should -Not -Throw
    }

    It "loads installers module" {
        { Import-Module "$PSScriptRoot/../modules/installers.psm1" -Force } | Should -Not -Throw
    }

    It "loads tweaks module" {
        { Import-Module "$PSScriptRoot/../modules/tweaks.psm1" -Force } | Should -Not -Throw
    }
}