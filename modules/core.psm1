# -----------------------------
# Autoupdate
# -----------------------------
function Get-LocalVersion {
    $versionFile = Join-Path $PSScriptRoot "version.json"
    if (Test-Path $versionFile) {
        return (Get-Content $versionFile -Raw | ConvertFrom-Json).version
    }
    return "0.0.0"
}

function Get-RemoteVersion {
    $url = "https://api.github.com/repos/saigkill/windows-bootstrap/releases/latest"
    $response = Invoke-RestMethod -Uri $url -Headers @{ "User-Agent" = "windows-bootstrap" }
    return $response.tag_name.TrimStart("v")
}

function Update-Bootstrapper {
    $localVersion  = [Version](Get-LocalVersion)
    $remoteVersion = [Version](Get-RemoteVersion)

    if ($remoteVersion -le $localVersion) {
        Write-Log "Bootstrapper is the current version (Version $localVersion)"
        return
    }

    Write-Log "Found new Version: $remoteVersion (lokal: $localVersion)"

    $url = "https://raw.githubusercontent.com/saigkill/windows-bootstrap/main/bootstrapper/bootstrap.ps1"
    $target = Join-Path $PSScriptRoot "bootstrap.ps1"

    try {
        Invoke-RestMethod -Uri $url -OutFile $target -Headers @{ "User-Agent" = "windows-bootstrap" }
        Write-Log "Bootstrapper updated to Version $remoteVersion"
        Write-Log "Restarting Bootstrapper…"

        Start-Process pwsh -ArgumentList "-File `"$target`""
        exit
    }
    catch {
        Write-Log "Error while Update: $($_.Exception.Message)" "ERROR"
    }
}

# -----------------------------
# Logging & Helper
# -----------------------------
function Write-Log {
    param(
        [Parameter(Mandatory)][string]$Message,
        [ValidateSet('INFO','WARN','ERROR')][string]$Level = 'INFO'
    )
    $LogFile = Join-Path $PSScriptRoot "../deploy.log"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$timestamp] [$Level] $Message"
    Write-Host $line
    Add-Content -Path $LogFile -Value $line
}

function Invoke-Section {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][scriptblock]$ScriptBlock
    )
    Write-Log "Starting Part: $Name"
    try {
        & $ScriptBlock
        Write-Log "Part successful: $Name"
    }
    catch {
        Write-Log "Error in Part '$Name': $($_.Exception.Message)" 'ERROR'
    }
}

function Invoke-Optional {
    param(
        [Parameter(Mandatory)][string]$Question,
        [Parameter(Mandatory)][scriptblock]$Action,
        [bool]$DefaultYes = $true
    )

    $default = if ($DefaultYes) { "[Y/N]" } else { "[y/n]" }
    $answer = Read-Host "$Question $default"

    if ([string]::IsNullOrWhiteSpace($answer)) {
        $answer = if ($DefaultYes) { "y" } else { "n" }
    }

    switch ($answer.ToLower()) {
        "j" { & $Action }
        "ja" { & $Action }
        "y" { & $Action }
        "yes" { & $Action }
        default { Write-Host "Skipped: $Question" }
    }
}

function Test-Url {
    param(
        [Parameter(Mandatory)][string]$Url
    )
    try {
        $response = Invoke-WebRequest -Uri $Url -Method Head -UseBasicParsing -TimeoutSec 15
        return ($response.StatusCode -ge 200 -and $response.StatusCode -lt 400)
    }
    catch {
        Write-Log "URL not reached: $Url – $($_.Exception.Message)" 'WARN'
        return $false
    }
}

function Test-Command {
    param(
        [Parameter(Mandatory)][string]$Name
    )
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function AddToPath {
    param(
        [string]$folder
    )

    $currentEnv = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine).Trim(";");
    $addedEnv = $currentEnv + ";$folder"
    $trimmedEnv = (($addedEnv.Split(';') | Select-Object -Unique) -join ";").Trim(";")
    [Environment]::SetEnvironmentVariable(
        "Path",
        $trimmedEnv,
        [EnvironmentVariableTarget]::Machine)

    Write-Log "Reloaded environment variables."
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}