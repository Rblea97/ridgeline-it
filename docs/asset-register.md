# Ridgeline Technology Services — Asset Register

## Virtual Machines

| Asset | Hostname | OS | IP Address | Role | Switch |
|---|---|---|---|---|---|
| DC01 | WIN-DTBFF0R4BBQ | Windows Server 2022 Standard (Desktop Experience) | 192.168.1.10 (static) | Domain Controller, DNS, DHCP | RTS-LAN + Default Switch |
| WRK01 | DESKTOP-4PL0V3F | Windows 11 Pro | 192.168.1.102 (static) | Employee Workstation — Operations | RTS-LAN |
| WRK02 | DESKTOP-BTK0BJ4 | Windows 11 Pro | 192.168.1.103 (static) | Employee Workstation — Operations | RTS-LAN |

> **Note on hostnames:** DC01, WRK01, and WRK02 retain their auto-generated Hyper-V hostnames. Renaming a domain controller post-promotion risks breaking DNS SRV records and Kerberos authentication. Hostnames were accepted as-is. See TICKET-001 for details.

## VM Specifications

All VMs are hosted on a single Hyper-V host (Windows 11 Pro).

| Asset | vCPUs | RAM | Disk |
|---|---|---|---|
| DC01 | 2 | 4 GB | 60 GB (dynamic VHD) |
| WRK01 | 2 | 4 GB | 60 GB (dynamic VHD) |
| WRK02 | 2 | 4 GB | 60 GB (dynamic VHD) |

## User Assignments

| Workstation | Primary User | Sam Account | Department | UPN |
|---|---|---|---|---|
| WRK01 | Alex Torres | atorres | Operations | atorres@fx934y.onmicrosoft.com |
| WRK02 | Jordan Reyes | jreyes | Operations | jreyes@fx934y.onmicrosoft.com |

## AD User Accounts

| Display Name | SamAccountName | Department | OU |
|---|---|---|---|
| Alex Torres | atorres | Operations | OU=Operations,OU=RTS Users |
| Jordan Reyes | jreyes | Operations | OU=Operations,OU=RTS Users |
| Morgan Ellis | mellis | Finance | OU=Finance,OU=RTS Users |
| Casey Park | cpark | Finance | OU=Finance,OU=RTS Users |
| Richard Blea | rblea | IT | OU=IT,OU=RTS Users |
| Sam Nguyen | snguyen | IT | OU=IT,OU=RTS Users |

## Security Groups

| Group Name | Scope | Members |
|---|---|---|
| All Staff | Global Security | atorres, jreyes, mellis, cpark, rblea, snguyen |
| Operations Users | Global Security | atorres, jreyes |
| Finance Users | Global Security | mellis, cpark |
| IT Staff | Global Security | rblea, snguyen |

## Group Policy Objects

| GPO Name | Linked To | Key Settings |
|---|---|---|
| RTS-Password-Policy | DC=ridgeline,DC=local | Min length 10, complexity on, 90-day max age, lockout 5 attempts/15 min |
| RTS-Workstation-Policy | OU=Workstations,OU=RTS Computers | Block Cortana (OMA-URI), lock screen display name only |

## Cloud Resources

| Resource | Value |
|---|---|
| M365 tenant | fx934y.onmicrosoft.com |
| Admin account | admin@fx934y.onmicrosoft.com |
| License tier | Microsoft 365 E5 Developer |
| MDM provider | Microsoft Intune |
| Sync tool | Azure AD Connect (Entra Connect Sync) on DC01 |
| Compliance policy | RTS-Workstation-Compliance (assigned to All Devices) |
| Configuration profile | RTS-Workstation-Config (Block Cortana, lock screen name) |
