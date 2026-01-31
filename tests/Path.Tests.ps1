Describe "Add-ToSystemPath" {

    BeforeAll {
        Import-Module "$PSScriptRoot/../modules/core.psm1" -Force
    }

    It "does not throw when adding a valid folder" {
        $temp = "$env:TEMP\testfolder"
        New-Item -ItemType Directory -Path $temp -Force | Out-Null

        { AddToPath -Folder $temp } | Should -Not -Throw
    }
}
