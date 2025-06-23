# WARNING: I just vibe coded this with copilot lol, I don't understand this
# code's implications.

$DebloatName = "Win11Debloat"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$DebloatSrc = Join-Path -Path $ScriptDir -ChildPath $DebloatName

function Get-Script {
    # Check if the debloat folder exists.
    if (Test-Path -Path $DebloatSrc -PathType Container) {
        Write-Host "Debloat folder exists, pulling latest updates."
        Push-Location $DebloatSrc
        git pull --quiet
        Pop-Location
    }
    # If folder doesn't exist, clone it instead.
    else {
        Write-Host "Source folder '$DebloatSrc' not found. Cloning instead."
        git clone https://github.com/Raphire/Win11Debloat $DebloatName --quiet
    }
}

function New-Debloat {
    $DebloatScript = "Win11Debloat.ps1"
    $GetScriptPath = Join-Path -Path $DebloatSrc -ChildPath $DebloatScript

    # Run the debloat script.
    if (Test-Path -Path $GetScriptPath -PathType Leaf) {
        $SourceSavedSettings = Join-Path -Path $ScriptDir -ChildPath "SavedSettings"
        $TargetSavedSettings = Join-Path -Path $DebloatSrc -ChildPath "SavedSettings"

        # Check if SaveSettings exists, otherwise copy from source folder.
        if (-not (Test-Path -Path $TargetSavedSettings -PathType Leaf)) {
            Write-Host "No existing SavedSettings found, copying from source."
            Copy-Item -Path $SourceSavedSettings -Destination $DebloatSrc
        }

        # Finally, run the debloat script with admin access.
        Write-Host "Running $DebloatScript with arguments -Silent and -RunSavedSettings..."
        & $GetScriptPath -Silent -RunSavedSettings
    }
    else {
        Write-Error "$DebloatScript not found at '$GetScriptPath'."
    }
}

function Get-Admin {
    # Check for administrator privileges
    if (-not ([Security.Principal.WindowsIdentity]::GetCurrent().Owner.IsWellKnown(
                [Security.Principal.WellKnownSidType]::BuiltinAdministratorsSid))) {
        Write-Host "Requesting administrator privileges for $DebloatName script."
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-File", "`"$($MyInvocation.MyCommand.Definition)`""

        Exit
    }
}

function Get-Admin2 {
    # Check for administrator privileges
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
            [Security.Principal.WindowsBuiltInRole] 'Administrator')) {
        Write-Host "Requesting administrator privileges for $DebloatName script."
        Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList "-File `"$($MyInvocation.MyCommand.Path)`"  `"$($MyInvocation.MyCommand.UnboundArguments)`""
        Exit
    }
}

#Get-Script
Get-Admin2
New-Debloat
