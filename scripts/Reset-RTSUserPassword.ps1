<#
.SYNOPSIS
    Resets an Active Directory user password and logs the action.

.DESCRIPTION
    Resets the password for a specified AD user account, unlocks the account
    if locked, and forces a password change at next logon. Appends a
    timestamped entry to the password reset log at C:\IT\Logs\password-resets.log.

.PARAMETER SamAccountName
    The sAMAccountName of the user whose password will be reset.

.PARAMETER NewPassword
    The new temporary password. Defaults to 'Welcome1!2'.

.PARAMETER LogPath
    Path to the log file. Defaults to C:\IT\Logs\password-resets.log.

.EXAMPLE
    .\Reset-RTSUserPassword.ps1 -SamAccountName atorres

.EXAMPLE
    .\Reset-RTSUserPassword.ps1 -SamAccountName jreyes -NewPassword 'Temp2026!'

.NOTES
    Must be run on DC01 (192.168.1.10) as a domain administrator.
    The log directory is created automatically if it does not exist.
#>

#Requires -Modules ActiveDirectory

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$SamAccountName,

    [string]$NewPassword = 'Welcome1!2',

    [string]$LogPath = 'C:\IT\Logs\password-resets.log'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --- Validate user exists ---
try {
    $user = Get-ADUser -Identity $SamAccountName -Properties DisplayName, LockedOut -ErrorAction Stop
    Write-Host "Found user: $($user.DisplayName) ($SamAccountName)"
}
catch {
    Write-Error "User '$SamAccountName' not found in Active Directory: $_"
    exit 1
}

# --- Reset password ---
try {
    $securePassword = ConvertTo-SecureString $NewPassword -AsPlainText -Force
    Set-ADAccountPassword -Identity $SamAccountName -NewPassword $securePassword -Reset -ErrorAction Stop
    Write-Host 'Password reset.'
}
catch {
    Write-Error "Failed to reset password for '$SamAccountName': $_"
    exit 1
}

# --- Unlock if locked ---
if ($user.LockedOut) {
    try {
        Unlock-ADAccount -Identity $SamAccountName -ErrorAction Stop
        Write-Host 'Account unlocked.'
    }
    catch {
        Write-Error "Failed to unlock account '$SamAccountName': $_"
        exit 1
    }
}

# --- Force password change at next logon ---
try {
    Set-ADUser -Identity $SamAccountName -ChangePasswordAtLogon $true -ErrorAction Stop
    Write-Host 'User will be prompted to change password at next logon.'
}
catch {
    Write-Error "Failed to set ChangePasswordAtLogon for '$SamAccountName': $_"
    exit 1
}

# --- Log the action ---
try {
    $logDir = Split-Path $LogPath
    if (-not (Test-Path $logDir)) {
        New-Item -Path $logDir -ItemType Directory -Force | Out-Null
    }

    $timestamp  = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $adminWho   = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    $logEntry   = "$timestamp`t$adminWho`tRESET`t$SamAccountName`t$($user.DisplayName)"
    Add-Content -Path $LogPath -Value $logEntry -ErrorAction Stop

    Write-Host "`nLogged to: $LogPath"
    Write-Host "Entry: $logEntry"
}
catch {
    Write-Error "Password was reset but failed to write log entry to '$LogPath': $_"
}
