$DebloatName = "Win11Debloat"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$DebloatSrc = Join-Path -Path $ScriptDir -ChildPath $DebloatName

# Check for administrator privileges
if (-not ([Security.Principal.WindowsIdentity]::GetCurrent().Owner.IsWellKnown(
            [Security.Principal.WellKnownSidType]::BuiltinAdministratorsSid))) {
    Write-Host "Requesting administrator privileges for $DebloatName script."
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-File", "`"$($MyInvocation.MyCommand.Definition)`""

    Exit
}

function Get-Script {
    # Check if the debloat folder exists.
    if (Test-Path -Path $DebloatSrc -PathType Container) {
        Write-Host "Debloat folder exists, pulling latest updates."
        Push-Location $DebloatSrc
        git pull
        Pop-Location
    }
    # If folder doesn't exist, clone it instead.
    else {
        Write-Host "Source folder '$DebloatSrc' not found. Cloning instead."
        git clone https://github.com/Raphire/Win11Debloat $DebloatName
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

function Get-DebloatTask {
    Write-Host "Setting up new Debloat Task."
    $TaskTrigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At 1am
    $TaskAction = New-ScheduledTaskAction -Execute "PowerShell" -Argument $PSCommandPath -WorkingDirectory $ScriptDir

    Register-ScheduledTask 'Win11Debloat Task' -AsJob -RunLevel Highest -Action $TaskAction -Trigger $TaskTrigger -Description "Periodically re-runs win11 debloat to re-disable anything that windows update may have re-enabled."
}

Get-Script
Get-DebloatTask
New-Debloat

Start-Sleep -Seconds 5
