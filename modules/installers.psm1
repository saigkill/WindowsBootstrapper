# -----------------------------
# Paketmanaging
# -----------------------------
function Install-WingetApp { 
    param(
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][string]$Source
    )

    Write-Log "Initialize via winget: $Id (Source: $Source)"

    try {
        winget install --id $Id --source $Source --silent --accept-package-agreements --accept-source-agreements -h 0
    }
    catch{
        Write-Log "Error while winget Installation from $Id $($_.Exception.Message)"
    }
}

function Install-WingetApps {
    param( 
        [Parameter(Mandatory)] 
        $Config 
    )

    if (-not (Test-Command "winget")) {
        Write-Log "winget not found – skipping Winget-Installation." 'WARN'
        return
    }

    $AllApps = $Config.WingetApps + $Config.StoreApps
    foreach ($app in $AllApps) {        
        Write-Log "Installing via winget: $app.id"
        try {
            Install-WingetApp -Id $app.Id -Source $app.Source
        }
        catch {
            Write-Log "Error while winget-Installation from $app.Id: $($_.Exception.Message)" 'ERROR'
        }
    }
}

function Install-Choco {
    if (Test-Command "choco") {
        Write-Log "Choco already installied."
        return
    }

    try {
        Set-ExecutionPolicy AllSigned -Scope CurrentUser -Force
        Invoke-RestMethod -Uri "https://community.chocolatey.org/install.ps1" | Invoke-Expression
        Write-Log "Chocolatey installied."
    }
    catch {
        Write-Log "Error while Installation from Chocolatey: $($_.Exception.Message)" 'ERROR'
    }
}

function Install-ChocoApps {
    param( 
        [Parameter(Mandatory)] 
        $Config 
    )

    if (-not (Test-Command "choco")) {
        Write-Log "Chocolatey not found – skipping Choco-Installation." 'WARN'
        return
    }

    foreach ($pkg in $Config.ChocoApps) {
        Write-Log "Installing via choco: $pkg"
        try {
            choco install $pkg -y --no-progress
        }
        catch {
            Write-Log "Error while choco-Installation from $pkg $($_.Exception.Message)" 'ERROR'
        }
    }
}

function Install-Scoop {
    if (Test-Command "scoop") {
        Write-Log "Scoop already installed."
        return
    }

    try {
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Invoke-RestMethod -Uri "https://get.scoop.sh" | Invoke-Expression
        Write-Log "Scoop installed."
    }
    catch {
        Write-Log "Error while Installation from Scoop: $($_.Exception.Message)" 'ERROR'
    }
}

function Configure-Scoop {
    param( 
        [Parameter(Mandatory)] 
        $Config 
    )

    if (-not (Test-Command "scoop")) {
        Write-Log "Scoop not found – skipping Scoop-Configuration." 'WARN'
        return
    }

    foreach ($bucket in $Config.ScoopBuckets) {
        Write-Log "Adding Scoop-Bucket: $bucket"
        try {
            scoop bucket add $bucket
        }
        catch {
            Write-Log "Error while adding Buckets '$bucket': $($_.Exception.Message)" 'ERROR'
        }
    }

    foreach ($app in $Config.ScoopApps) {
        Write-Log "Installing via scoop: $app"
        try {
            scoop install $app
        }
        catch {
            Write-Log "Error while scoop-Installation from $app $($_.Exception.Message)" 'ERROR'
        }
    }
}

# -----------------------------
# External Downloads (ZIP / EXE)
# -----------------------------

function Install-FromZip {
    param( 
        [Parameter(Mandatory)] 
        $Config 
    )

    foreach ($item in $Config.ExternalZips) {
        $name   = $item.Name
        $url    = $item.Url
        $target = $item.Target

        Write-Log "Working on ZIP: $name ($url)"

        if (-not (Test-Url $url)) {
            Write-Log "Skipping $name, URL not reachable." 'WARN'
            continue
        }

        try {
            $tempZip = Join-Path $env:TEMP "$name.zip"
            Write-Log "Downloading to $tempZip"
            Invoke-WebRequest -Uri $url -OutFile $tempZip -UseBasicParsing

            if (-not (Test-Path $target)) {
                New-Item -ItemType Directory -Path $target -Force | Out-Null
            }

            Write-Log "Extracting to $target"
            Expand-Archive -Path $tempZip -DestinationPath $target -Force

            Remove-Item $tempZip -Force
        }
        catch {
            Write-Log "Error while ZIP-Installation from $name $($_.Exception.Message)" 'ERROR'
        }
    }
}

function Install-FromExe {
    param( 
        [Parameter(Mandatory)] 
        $Config 
    )

    foreach ($item in $Config.ExternalExes) {
        $name      = $item.Name
        $url       = $item.Url
        $arguments = $item.Arguments

        Write-Log "Working on EXE: $name ($url)"

        if (-not (Test-Url $url)) {
            Write-Log "Skipping $name, URL not reachable." 'WARN'
            continue
        }

        try {
            $tempExe = Join-Path $env:TEMP "$name.exe"
            Write-Log "Downloading to $tempExe"
            Invoke-WebRequest -Uri $url -OutFile $tempExe -UseBasicParsing

            Write-Log "Starting Installer: $tempExe $arguments"
            $p = Start-Process -FilePath $tempExe -ArgumentList $arguments -Wait -PassThru
            Write-Log "Installer finished to ExitCode $($p.ExitCode)"

            Remove-Item $tempExe -Force
        }
        catch {
            Write-Log "Error while EXE-Installation from $name $($_.Exception.Message)" 'ERROR'
        }
    }
}