<#
.SYNOPSIS
    End-to-end new employee onboarding for a single user.

.DESCRIPTION
    Creates an Active Directory account in the correct OU, assigns the user to
    their department security group and All Staff, then triggers an Azure AD
    Connect delta sync. M365 license must be assigned manually in admin.microsoft.com
    after sync completes (typically 2-3 minutes).

.PARAMETER FirstName
    Employee first name.

.PARAMETER LastName
    Employee last name.

.PARAMETER Department
    Department. Valid values: Operations, Finance, IT.

.PARAMETER JobTitle
    Employee job title.

.PARAMETER DefaultPassword
    Optional [SecureString] temporary password for the new account. If not
    provided, a 14-character cryptographically random temp password is
    generated at runtime and printed to the console for secure communication
    to the user. The user must change it at first logon.

.EXAMPLE
    .\Invoke-RTSOnboarding.ps1 -FirstName "Jamie" -LastName "Chen" -Department "Finance" -JobTitle "Accountant"

.EXAMPLE
    .\Invoke-RTSOnboarding.ps1 -FirstName "Alex" -LastName "Rivera" -Department "IT" -JobTitle "Help Desk Technician"

.NOTES
    Requires: ActiveDirectory module, ADSync module
    Run as: Domain Admin on DC01 (192.168.1.10)

    Lab-only values used in this script:
      - $TenantDomain = "ridgelinets.onmicrosoft.com"  (RTS lab M365 tenant)
      - OU paths under "OU=RTS Users,DC=ridgeline,DC=local"  (RTS lab AD)
      - Security group names: All Staff, Operations Users, Finance Users, IT Staff

    For production use, parameterize $TenantDomain, OU paths, and group
    names; do not assume the RTS-lab values.
#>

#Requires -Modules ActiveDirectory, ADSync

[CmdletBinding()]
param (
    [Parameter(Mandatory)] [string]$FirstName,
    [Parameter(Mandatory)] [string]$LastName,
    [Parameter(Mandatory)]
    [ValidateSet("Operations","Finance","IT")]
    [string]$Department,
    [Parameter(Mandatory)] [string]$JobTitle,

    [Parameter()]
    [SecureString]$DefaultPassword
)

# If no password supplied, generate a cryptographically random 14-char temp password.
# Caller may also pass -DefaultPassword <SecureString> to set a specific value.
if (-not $DefaultPassword) {
    Add-Type -AssemblyName 'System.Web'
    $generated = [System.Web.Security.Membership]::GeneratePassword(14, 4)
    $DefaultPassword = ConvertTo-SecureString $generated -AsPlainText -Force
    Write-Host "Generated temporary password: $generated" -ForegroundColor Yellow
    Write-Host "Communicate to user via secure channel. User must change at first logon." -ForegroundColor Yellow
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

$Sam = ($FirstName.Substring(0,1) + $LastName).ToLower()
$UPN = "$Sam@$TenantDomain"
$OU  = $OUMap[$Department]

Write-Host "`n=== RTS New Employee Onboarding ===" -ForegroundColor Cyan
Write-Host "Name       : $FirstName $LastName"
Write-Host "Username   : $Sam"
Write-Host "UPN        : $UPN"
Write-Host "Department : $Department"
Write-Host "Job Title  : $JobTitle"
Write-Host "OU         : $OU`n"

# Step 1: Create AD user
Write-Host "[1/3] Creating Active Directory account..."
try {
    New-ADUser `
        -Name              "$FirstName $LastName" `
        -GivenName         $FirstName `
        -Surname           $LastName `
        -SamAccountName    $Sam `
        -UserPrincipalName $UPN `
        -Department        $Department `
        -Title             $JobTitle `
        -Path              $OU `
        -AccountPassword   $DefaultPassword `
        -Enabled           $true `
        -ChangePasswordAtLogon $true `
        -ErrorAction       Stop
    Write-Host "    AD account created." -ForegroundColor Green
}
catch {
    Write-Error "Failed to create AD account for ${Sam}: $_"
    exit 1
}

# Step 2: Add to security groups
Write-Host "[2/3] Adding to security groups..."
try {
    Add-ADGroupMember -Identity "All Staff"            -Members $Sam -ErrorAction Stop
    Add-ADGroupMember -Identity $GroupMap[$Department] -Members $Sam -ErrorAction Stop
    Write-Host "    Added to 'All Staff' and '$($GroupMap[$Department])'." -ForegroundColor Green
}
catch {
    Write-Error "Failed to add $Sam to security groups: $_"
    exit 1
}

# Step 3: Trigger Azure AD Connect sync
Write-Host "[3/3] Triggering Azure AD Connect delta sync..."
try {
    Import-Module ADSync -ErrorAction Stop
    Start-ADSyncSyncCycle -PolicyType Delta | Out-Null
    Write-Host "    Sync triggered successfully." -ForegroundColor Green
}
catch {
    Write-Warning "    Could not auto-trigger sync. Run manually: Start-ADSyncSyncCycle -PolicyType Delta"
}

Write-Host "`n=== Onboarding Complete ===" -ForegroundColor Cyan
Write-Host "Next step  : Assign M365 E5 license in admin.microsoft.com -> Users -> $FirstName $LastName"
Write-Host "Temp pass  : [as provided - user must change at first login]`n"
