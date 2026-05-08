<#
.SYNOPSIS
    Creates multiple Active Directory users from a CSV file and syncs to Azure AD.

.DESCRIPTION
    Reads a CSV with FirstName, LastName, Department, and JobTitle columns.
    Creates each user in the correct OU, assigns them to department and All Staff
    security groups, and triggers an Azure AD Connect delta sync when complete.

.PARAMETER CsvPath
    Path to the input CSV file.

.PARAMETER DefaultPassword
    Optional [SecureString] temporary password applied to all new accounts.
    If not provided, a 14-character cryptographically random temp password is
    generated once and applied to every account in this batch (printed to the
    console for secure communication). Users must change at first logon.

.EXAMPLE
    .\New-RTSUser.ps1 -CsvPath ".\new-hires.csv"

    CSV format:
    FirstName,LastName,Department,JobTitle
    Taylor,Morgan,Operations,Project Coordinator

.EXAMPLE
    .\New-RTSUser.ps1 -CsvPath "C:\IT\Imports\march-hires.csv"

.NOTES
    Requires: ActiveDirectory module, ADSync module
    Run as: Domain Admin on DC01 (192.168.1.10)
    Valid departments: Operations, Finance, IT
#>

#Requires -Modules ActiveDirectory, ADSync

[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]$CsvPath,

    [Parameter()]
    [SecureString]$DefaultPassword
)

# If no password supplied, generate a cryptographically random 14-char temp password.
# Caller may also pass -DefaultPassword <SecureString> to set a specific value.
if (-not $DefaultPassword) {
    Add-Type -AssemblyName 'System.Web'
    $generated = [System.Web.Security.Membership]::GeneratePassword(14, 4)
    $DefaultPassword = ConvertTo-SecureString $generated -AsPlainText -Force
    Write-Host "Generated temporary password: $generated (applied to all created accounts)" -ForegroundColor Yellow
    Write-Host "Communicate to users via secure channel. Users must change at first logon." -ForegroundColor Yellow
}

$TenantDomain    = "ridgelinets.onmicrosoft.com"

$OUMap = @{
    "Operations" = "OU=Operations,OU=RTS Users,DC=ridgeline,DC=local"
    "Finance"    = "OU=Finance,OU=RTS Users,DC=ridgeline,DC=local"
    "IT"         = "OU=IT,OU=RTS Users,DC=ridgeline,DC=local"
}

$GroupMap = @{
    "Operations" = "Operations Users"
    "Finance"    = "Finance Users"
    "IT"         = "IT Staff"
}

if (-not (Test-Path $CsvPath)) {
    Write-Error "CSV not found: $CsvPath"
    exit 1
}

$Users   = Import-Csv -Path $CsvPath
$Created = @()
$Failed  = @()

foreach ($User in $Users) {
    $Sam = ($User.FirstName.Substring(0,1) + $User.LastName).ToLower()
    $UPN = "$Sam@$TenantDomain"
    $OU  = $OUMap[$User.Department]

    if (-not $OU) {
        Write-Warning "Unknown department '$($User.Department)' for $Sam — skipping"
        $Failed += $Sam
        continue
    }

    try {
        New-ADUser `
            -Name              "$($User.FirstName) $($User.LastName)" `
            -GivenName         $User.FirstName `
            -Surname           $User.LastName `
            -SamAccountName    $Sam `
            -UserPrincipalName $UPN `
            -Department        $User.Department `
            -Title             $User.JobTitle `
            -Path              $OU `
            -AccountPassword   $DefaultPassword `
            -Enabled           $true `
            -ChangePasswordAtLogon $true `
            -ErrorAction       Stop

        Add-ADGroupMember -Identity "All Staff"                  -Members $Sam -ErrorAction Stop
        Add-ADGroupMember -Identity $GroupMap[$User.Department]  -Members $Sam -ErrorAction Stop

        Write-Host "[+] Created: $Sam ($UPN)" -ForegroundColor Green
        $Created += $Sam
    }
    catch {
        Write-Error "Failed to create or configure $Sam`: $_"
        $Failed += $Sam
    }
}

Write-Host "`n--- Summary ---"
Write-Host "Created : $($Created.Count)" -ForegroundColor Green
if ($Failed.Count -gt 0) {
    Write-Host "Failed  : $($Failed.Count)" -ForegroundColor Red
} else {
    Write-Host "Failed  : 0" -ForegroundColor Green
}

if ($Created.Count -gt 0) {
    Write-Host "`nTriggering Azure AD Connect delta sync..."
    try {
        Import-Module ADSync -ErrorAction Stop
        Start-ADSyncSyncCycle -PolicyType Delta | Out-Null
        Write-Host "Sync triggered. Users appear in Azure AD within 2-3 minutes." -ForegroundColor Green
    }
    catch {
        Write-Warning "Could not auto-trigger sync. Run manually: Start-ADSyncSyncCycle -PolicyType Delta"
    }
}
