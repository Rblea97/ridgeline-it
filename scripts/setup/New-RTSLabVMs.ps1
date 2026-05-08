<#
.SYNOPSIS
    Provisions the Ridgeline Technology Services Hyper-V lab environment.

.DESCRIPTION
    Creates the RTS-LAN internal virtual switch and three Generation 2 virtual machines:
    RTS-DC01 (Windows Server 2022), RTS-WRK01 (Windows 11), and RTS-WRK02 (Windows 11).

    WRK01 and WRK02 are created with virtual TPM enabled to support BitLocker compliance
    testing in Microsoft Intune. DC01 is created without TPM (not required for a domain controller).

    All VMs use dynamic memory (2-4 GB), 2 vCPUs, and 60 GB dynamic VHDX disks.
    Boot order: DVD -> HDD -> Network. Secure Boot enabled with MicrosoftUEFICertificateAuthority template.

.PARAMETER ISOPath
    Path to the folder containing the Windows Server 2022 and Windows 11 ISO files.
    Defaults to C:\ISOs.

    Expected filenames:
      SERVER_EVAL_x64FRE_en-us.iso  (Windows Server 2022 Evaluation)
      Win11_25H2_English_x64_v2.iso (Windows 11 25H2)

.EXAMPLE
    .\New-RTSLabVMs.ps1

.EXAMPLE
    .\New-RTSLabVMs.ps1 -ISOPath "D:\ISOs"

.NOTES
    Requires: Hyper-V PowerShell module
    Run as: Local Administrator on the Hyper-V host

    Lab-only values used in this script:
      - VM names: RTS-DC01, RTS-WRK01, RTS-WRK02
      - Switch name: RTS-LAN
      - Default ISO file names (Windows Server 2022 Eval, Windows 11 25H2)

    For production use, parameterize VM names, switch name, and ISO paths.

    After running this script, install the operating systems on each VM via
    Hyper-V Manager, then run the AD configuration scripts from the repo.
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$ISOPath = "C:\ISOs"
)

$ServerISO  = Join-Path $ISOPath "SERVER_EVAL_x64FRE_en-us.iso"
$Win11ISO   = Join-Path $ISOPath "Win11_25H2_English_x64_v2.iso"
$VHDPath    = (Get-VMHost).VirtualHardDiskPath
$SwitchName = "RTS-LAN"

# Virtual Switch
Write-Host "[1/4] Creating virtual switch '$SwitchName'..." -ForegroundColor Cyan
if (-not (Get-VMSwitch -Name $SwitchName -ErrorAction SilentlyContinue)) {
    try {
        New-VMSwitch -Name $SwitchName -SwitchType Internal -ErrorAction Stop | Out-Null
        Write-Host "      Created '$SwitchName'." -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to create virtual switch '$SwitchName': $_"
        exit 1
    }
} else {
    Write-Host "      '$SwitchName' already exists - skipping." -ForegroundColor Yellow
}

# Helper: create a single VM
function New-RTSvm {
    param(
        [string]$Name,
        [string]$ISO,
        [bool]$EnableTPM
    )

    if (Get-VM -Name $Name -ErrorAction SilentlyContinue) {
        Write-Host "  '$Name' already exists - skipping." -ForegroundColor Yellow
        return
    }

    $vhdFile = Join-Path $VHDPath "$Name.vhdx"

    try {
        New-VM -Name $Name -Generation 2 -MemoryStartupBytes 4GB `
               -SwitchName $SwitchName -NewVHDPath $vhdFile -NewVHDSizeBytes 60GB `
               -ErrorAction Stop | Out-Null

        Set-VMProcessor -VMName $Name -Count 2 -ErrorAction Stop

        Set-VMMemory -VMName $Name -DynamicMemoryEnabled $true `
                     -MinimumBytes 2GB -StartupBytes 4GB -MaximumBytes 4GB `
                     -ErrorAction Stop

        Add-VMDvdDrive -VMName $Name -Path $ISO -ErrorAction Stop

        $dvd = Get-VMDvdDrive      -VMName $Name
        $hdd = Get-VMHardDiskDrive -VMName $Name
        $net = Get-VMNetworkAdapter -VMName $Name
        Set-VMFirmware -VMName $Name -BootOrder $dvd, $hdd, $net `
                       -EnableSecureBoot On `
                       -SecureBootTemplate "MicrosoftUEFICertificateAuthority" `
                       -ErrorAction Stop
    }
    catch {
        Write-Error "Failed to provision VM '$Name': $_"
        return
    }

    if ($EnableTPM) {
        try {
            Set-VMKeyProtector -VMName $Name -NewLocalKeyProtector -ErrorAction Stop
            Enable-VMTPM -VMName $Name -ErrorAction Stop
        }
        catch {
            Write-Error "Failed to enable virtual TPM on '$Name': $_"
            return
        }
    }

    Write-Host "  $Name created." -ForegroundColor Green
}

# Create VMs
Write-Host "[2/4] Creating RTS-DC01 (Windows Server 2022)..." -ForegroundColor Cyan
New-RTSvm -Name "RTS-DC01" -ISO $ServerISO -EnableTPM $false

Write-Host "[3/4] Creating RTS-WRK01 (Windows 11)..." -ForegroundColor Cyan
New-RTSvm -Name "RTS-WRK01" -ISO $Win11ISO -EnableTPM $true

Write-Host "[4/4] Creating RTS-WRK02 (Windows 11)..." -ForegroundColor Cyan
New-RTSvm -Name "RTS-WRK02" -ISO $Win11ISO -EnableTPM $true

# Summary
Write-Host ""
Write-Host "VM Summary:" -ForegroundColor Cyan
Get-VM -Name "RTS-DC01","RTS-WRK01","RTS-WRK02" |
    Select-Object Name, State, Generation,
        @{N="RAM_GB"; E={[math]::Round($_.MemoryStartup/1GB,0)}},
        @{N="VHD"; E={(Get-VMHardDiskDrive $_.Name).Path}} |
    Format-Table -AutoSize

Write-Host "Switch:" -ForegroundColor Cyan
Get-VMSwitch -Name $SwitchName | Select-Object Name, SwitchType | Format-Table -AutoSize

Write-Host "Next: Install OSes on each VM via Hyper-V Manager, then run the AD configuration scripts." -ForegroundColor White
