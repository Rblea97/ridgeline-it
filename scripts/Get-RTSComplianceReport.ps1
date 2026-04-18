<#
.SYNOPSIS
    Exports Intune device compliance status for all RTS-managed devices.

.DESCRIPTION
    Connects to Microsoft Graph using the OAuth2 device code flow, retrieves
    all managed devices from the Ridgeline Technology Services Intune tenant,
    and exports a compliance report to a CSV file with a timestamped filename.

.PARAMETER TenantId
    The Azure AD tenant ID. Defaults to the RTS tenant.

.PARAMETER OutputPath
    Directory to write the CSV report. Defaults to the user's Documents folder.

.EXAMPLE
    .\Get-RTSComplianceReport.ps1

.EXAMPLE
    .\Get-RTSComplianceReport.ps1 -OutputPath "C:\Reports"

.NOTES
    No additional modules required — uses Invoke-RestMethod with native OAuth2
    device code authentication.

    Run on the host machine (not inside a VM).
    A browser code prompt will appear during authentication.
#>

[CmdletBinding()]
param(
    [string]$TenantId  = 'a9566324-fd0d-49ef-aa14-7ec036854bca',
    [string]$ClientId  = '14d82eec-204b-4c2f-b7e8-296a70dab67e', # Microsoft Graph PowerShell app
    [string]$OutputPath = [Environment]::GetFolderPath('MyDocuments')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --- Device code authentication ---
Write-Host '[1/3] Connecting to Microsoft Graph...'

$deviceCodeResponse = Invoke-RestMethod `
    -Method Post `
    -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/devicecode" `
    -Body @{
        client_id = $ClientId
        scope     = 'https://graph.microsoft.com/DeviceManagementManagedDevices.Read.All'
    }

Write-Host "`nTo sign in, use a web browser to open:" -ForegroundColor Yellow
Write-Host "  $($deviceCodeResponse.verification_uri)" -ForegroundColor Cyan
Write-Host "Enter code: $($deviceCodeResponse.user_code)" -ForegroundColor Cyan
Write-Host "`nWaiting for authentication..."

# Poll for token
$tokenParams = @{
    client_id   = $ClientId
    grant_type  = 'urn:ietf:params:oauth:grant-type:device_code'
    device_code = $deviceCodeResponse.device_code
}

$accessToken = $null
$deadline    = (Get-Date).AddSeconds($deviceCodeResponse.expires_in)

while ((Get-Date) -lt $deadline) {
    Start-Sleep -Seconds $deviceCodeResponse.interval
    try {
        $tokenResponse = Invoke-RestMethod `
            -Method Post `
            -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" `
            -Body $tokenParams `
            -ErrorAction Stop
        $accessToken = $tokenResponse.access_token
        break
    }
    catch {
        $errBody = $_.ErrorDetails.Message | ConvertFrom-Json -ErrorAction SilentlyContinue
        if ($errBody.error -eq 'authorization_pending') { continue }
        throw
    }
}

if (-not $accessToken) {
    Write-Error 'Authentication timed out. Re-run the script and complete sign-in within the time limit.'
    exit 1
}

Write-Host 'Authenticated.' -ForegroundColor Green

# --- Retrieve devices ---
Write-Host '[2/3] Retrieving managed devices...'

$headers = @{ Authorization = "Bearer $accessToken" }
$uri     = 'https://graph.microsoft.com/v1.0/deviceManagement/managedDevices'
$devices = [System.Collections.Generic.List[object]]::new()

do {
    $page = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
    $devices.AddRange([object[]]$page.value)
    $uri  = if ($page.PSObject.Properties['@odata.nextLink']) { $page.'@odata.nextLink' } else { $null }
} while ($uri)

if ($devices.Count -eq 0) {
    Write-Warning 'No managed devices found in tenant.'
    exit 0
}

# --- Build report ---
$report = $devices | Select-Object `
    @{N='DeviceName';       E={$_.deviceName}},
    @{N='UserPrincipalName';E={$_.userPrincipalName}},
    @{N='OperatingSystem';  E={$_.operatingSystem}},
    @{N='OSVersion';        E={$_.osVersion}},
    @{N='ComplianceState';  E={$_.complianceState}},
    @{N='ManagementAgent';  E={$_.managementAgent}},
    @{N='Ownership';        E={$_.managedDeviceOwnerType}},
    @{N='EnrolledDateTime'; E={[datetime]$_.enrolledDateTime | Get-Date -Format 'yyyy-MM-dd HH:mm'}},
    @{N='LastSyncDateTime'; E={[datetime]$_.lastSyncDateTime | Get-Date -Format 'yyyy-MM-dd HH:mm'}},
    @{N='SerialNumber';     E={$_.serialNumber}},
    @{N='Model';            E={$_.model}}

# --- Export CSV ---
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$csvPath   = Join-Path $OutputPath "RTS-ComplianceReport-$timestamp.csv"

Write-Host "[3/3] Exporting $($report.Count) device(s) to $csvPath"
$report | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8

# --- Console summary ---
Write-Host "`n=== RTS Compliance Summary ===" -ForegroundColor Cyan
$report | Format-Table DeviceName, UserPrincipalName, ComplianceState, LastSyncDateTime -AutoSize

$compliant    = @($report | Where-Object ComplianceState -eq 'compliant').Count
$noncompliant = @($report | Where-Object ComplianceState -eq 'noncompliant').Count
$unknown      = @($report | Where-Object ComplianceState -notin @('compliant','noncompliant')).Count

Write-Host "Compliant:    $compliant" -ForegroundColor Green
Write-Host "Noncompliant: $noncompliant" -ForegroundColor Red
Write-Host "Unknown/Other:$unknown" -ForegroundColor Yellow
Write-Host "`nReport saved to: $csvPath"
