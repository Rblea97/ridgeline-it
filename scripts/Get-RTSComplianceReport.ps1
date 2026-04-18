#Requires -Modules Microsoft.Graph.DeviceManagement

<#
.SYNOPSIS
    Exports Intune device compliance status for all RTS-managed devices.

.DESCRIPTION
    Connects to Microsoft Graph, retrieves all managed devices from the
    Ridgeline Technology Services Intune tenant, and exports a compliance
    report to a CSV file with a timestamped filename.

.PARAMETER TenantId
    The Azure AD tenant ID. Defaults to the RTS tenant.

.PARAMETER OutputPath
    Directory to write the CSV report. Defaults to the user's Documents folder.

.EXAMPLE
    .\Get-RTSComplianceReport.ps1

.EXAMPLE
    .\Get-RTSComplianceReport.ps1 -OutputPath "C:\Reports"

.NOTES
    Requires the Microsoft.Graph.DeviceManagement module:
    Install-Module Microsoft.Graph.DeviceManagement -Scope CurrentUser

    Run on the host machine (not inside a VM) where Graph modules are installed.
    Uses device code authentication — a browser code prompt will appear.
#>

[CmdletBinding()]
param(
    [string]$TenantId = 'a9566324-fd0d-49ef-aa14-7ec036854bca',
    [string]$OutputPath = [Environment]::GetFolderPath('MyDocuments')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --- Connect ---
Write-Host '[1/3] Connecting to Microsoft Graph...'
Connect-MgGraph `
    -TenantId $TenantId `
    -Scopes 'DeviceManagementManagedDevices.Read.All' `
    -UseDeviceAuthentication `
    -NoWelcome

# --- Retrieve devices ---
Write-Host '[2/3] Retrieving managed devices...'
$devices = Get-MgDeviceManagementManagedDevice -All

if (-not $devices) {
    Write-Warning 'No managed devices found in tenant.'
    Disconnect-MgGraph | Out-Null
    exit 0
}

# --- Build report ---
$report = $devices | Select-Object `
    @{N='DeviceName';      E={$_.DeviceName}},
    @{N='UserPrincipalName'; E={$_.UserPrincipalName}},
    @{N='OperatingSystem'; E={$_.OperatingSystem}},
    @{N='OSVersion';       E={$_.OsVersion}},
    @{N='ComplianceState'; E={$_.ComplianceState}},
    @{N='ManagementAgent'; E={$_.ManagementAgent}},
    @{N='Ownership';       E={$_.ManagedDeviceOwnerType}},
    @{N='EnrolledDateTime';E={$_.EnrolledDateTime.ToString('yyyy-MM-dd HH:mm')}},
    @{N='LastSyncDateTime';E={$_.LastSyncDateTime.ToString('yyyy-MM-dd HH:mm')}},
    @{N='SerialNumber';    E={$_.SerialNumber}},
    @{N='Model';           E={$_.Model}}

# --- Export CSV ---
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$csvPath = Join-Path $OutputPath "RTS-ComplianceReport-$timestamp.csv"

Write-Host "[3/3] Exporting $($report.Count) device(s) to $csvPath"
$report | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8

# --- Console summary ---
Write-Host "`n=== RTS Compliance Summary ===" -ForegroundColor Cyan
$report | Format-Table DeviceName, UserPrincipalName, ComplianceState, LastSyncDateTime -AutoSize

$compliant    = ($report | Where-Object ComplianceState -eq 'compliant').Count
$noncompliant = ($report | Where-Object ComplianceState -eq 'noncompliant').Count
$unknown      = ($report | Where-Object ComplianceState -notin @('compliant','noncompliant')).Count

Write-Host "Compliant:    $compliant" -ForegroundColor Green
Write-Host "Noncompliant: $noncompliant" -ForegroundColor Red
Write-Host "Unknown/Other:$unknown" -ForegroundColor Yellow
Write-Host "`nReport saved to: $csvPath"

Disconnect-MgGraph | Out-Null
