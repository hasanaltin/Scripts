<#
.SYNOPSIS
    PowerShell script to remotely manage files and services on computers within Active Directory.

.DESCRIPTION
    Author: HASAN ALTIN
    Version: v1
    This script performs two main functions:
    1. Clears contents inside the "C:\Program Files\NVIDIA Corporation\vGPU Licensing\ClientConfigToken" folder
       on each computer with names starting with "VDI" and copies files from a local "C:\IT" folder to this location.
    2. Uses PsExec to restart the "NVDisplay.ContainerLocalSystem" service on each target computer. If the service 
       is already stopped, it proceeds to start it.
    All actions are logged for tracking and troubleshooting purposes.

#>

# Path to PsExec executable
$PsExecPath = "C:\Windows\System32\PsExec.exe"

# Function to log actions to a file with timestamps
function Write-Log {
    param (
        [string]$Message,
        [string]$LogFile
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp] $Message"
    Add-Content -Path $LogFile -Value $LogEntry
}

# Function to delete files in the ClientConfigToken folder and then copy new files
function ClearAndCopy-Files {
    $SourceFolder = "C:\IT"
    $Computers = Get-ADComputer -Filter 'Name -like "VDI*"' | Select-Object -ExpandProperty Name
    $LogFile = "C:\ITLogs\CopyFilesLog_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').log"
    
    foreach ($Computer in $Computers) {
        $DestinationFolder = "\\$Computer\C$\Program Files\NVIDIA Corporation\vGPU Licensing\ClientConfigToken"
        
        # Remove all contents inside the ClientConfigToken folder on the destination computer but keep the folder itself
        if (Test-Path $DestinationFolder) {
            Get-ChildItem -Path $DestinationFolder -Recurse | Remove-Item -Recurse -Force
            Write-Log "Cleared existing contents in ClientConfigToken folder on $Computer" $LogFile
        } else {
            # If the ClientConfigToken folder doesn't exist, create it
            New-Item -Path $DestinationFolder -ItemType Directory -Force
            Write-Log "Created ClientConfigToken folder on $Computer" $LogFile
        }

        # Copy files from source to destination and overwrite if exists
        Copy-Item -Path "$SourceFolder\*" -Destination $DestinationFolder -Recurse -Force
        Write-Host "Files copied to $Computer"
        Write-Log "Files copied to $Computer" $LogFile
    }

    Write-Host "Log file created at $LogFile"
}

# Function to restart a service using PsExec, with error handling for stopping and starting
function Restart-ServiceOnComputers {
    $ServiceName = "NVDisplay.ContainerLocalSystem"
    $Computers = Get-ADComputer -Filter 'Name -like "VDI*"' | Select-Object -ExpandProperty Name
    $LogFile = "C:\ITLogs\RestartServiceLog_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').log"
    
    foreach ($Computer in $Computers) {
        try {
            # Attempt to stop the service
            $stopProcess = Start-Process -FilePath $PsExecPath -ArgumentList "\\$Computer -s -d sc stop $ServiceName" -NoNewWindow -PassThru -Wait
            Start-Sleep -Seconds 5  # Short delay to allow process to complete
            if ($stopProcess.ExitCode -eq 0) {
                Write-Host "Service '$ServiceName' stopped on $Computer"
                Write-Log "Service '$ServiceName' stopped on $Computer" $LogFile
            } else {
                Write-Host "Service '$ServiceName' may already be stopped on $Computer. Proceeding to start it."
                Write-Log "Service '$ServiceName' may already be stopped on $Computer. Proceeding to start it." $LogFile
            }
        }
        catch {
            Write-Host "Service '$ServiceName' may already be stopped on $Computer. Proceeding to start it."
            Write-Log "Service '$ServiceName' may already be stopped on $Computer. Proceeding to start it." $LogFile
        }

        # Now, attempt to start the service
        try {
            $startProcess = Start-Process -FilePath $PsExecPath -ArgumentList "\\$Computer -s -d sc start $ServiceName" -NoNewWindow -PassThru -Wait
            Start-Sleep -Seconds 5  # Short delay to allow process to complete
            if ($startProcess.ExitCode -eq 0) {
                Write-Host "Service '$ServiceName' started on $Computer"
                Write-Log "Service '$ServiceName' started on $Computer" $LogFile
            } else {
                Write-Host "Failed to start service on $Computer (Exit Code: $($startProcess.ExitCode))"
                Write-Log "Failed to start service on $Computer (Exit Code: $($startProcess.ExitCode))" $LogFile
            }
        }
        catch {
            Write-Host "Failed to start service on $Computer - Error: $_"
            Write-Log "Failed to start service on $Computer - Error: $_" $LogFile
        }
    }

    Write-Host "Log file created at $LogFile"
}

# Function to ensure the log directory exists
function Ensure-LogDirectory {
    $LogDirectory = "C:\ITLogs"
    if (-not (Test-Path $LogDirectory)) {
        New-Item -Path $LogDirectory -ItemType Directory
    }
}

# Main menu function
function Show-Menu {
    Write-Host "1: Copy ClientConfigToken to Computers"
    Write-Host "2: Restart NVDisplay Service on Computers"
    Write-Host "0: Exit"
}

# Script execution
Ensure-LogDirectory  # Ensure the log directory exists
do {
    Show-Menu
    $Choice = Read-Host "Enter your choice (1, 2, or 0 to exit)"
    
    switch ($Choice) {
        1 { ClearAndCopy-Files }
        2 { Restart-ServiceOnComputers }
        0 { Write-Host "Exiting..."; break }
        default { Write-Host "Invalid selection, please choose again." }
    }
} while ($Choice -ne 0)
