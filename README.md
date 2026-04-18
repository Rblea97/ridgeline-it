# Ridgeline Technology Services — IT Support Lab

**Technician:** Richard Blea  
**Status:** Complete  
**Built:** April 2026

A hands-on IT support home lab simulating the on-premises and cloud infrastructure of a 20-person company. Built to demonstrate the core skills required for a help desk or IT support role: Active Directory administration, Microsoft Intune MDM, M365, PowerShell automation, and end-user support.

---

## Architecture

| Asset | Hostname | OS | IP | Role |
|-------|----------|----|----|------|
| DC01 | WIN-DTBFF0R4BBQ | Windows Server 2022 | 192.168.1.10 | AD DS, DNS, DHCP, Azure AD Connect |
| WRK01 | DESKTOP-4PL0V3F | Windows 11 Pro | 192.168.1.102 | Domain workstation — atorres |
| WRK02 | DESKTOP-BTK0BJ4 | Windows 11 Pro | 192.168.1.103 | Domain workstation — jreyes |

All VMs run on Hyper-V with an internal switch (`RTS-LAN 192.168.1.0/24`). DC01 has a second NIC on the Default Switch for internet access. The domain `ridgeline.local` syncs to Microsoft 365 tenant `fx934y.onmicrosoft.com` via Azure AD Connect (Password Hash Sync).

---

## What Was Built

1. **Active Directory** — domain `ridgeline.local`, 3 department OUs (Operations, Finance, IT), 6 users, 4 security groups
2. **DNS & DHCP** — DNS forwarder to 8.8.8.8, DHCP scope 192.168.1.100–200 on DC01
3. **Group Policy** — RTS-Password-Policy (10-char min, lockout after 5 attempts), RTS-Workstation-Policy (Cortana block, lock screen)
4. **Azure AD Connect** — Password Hash Sync, all 6 users synced to Entra ID
5. **Microsoft Intune** — both workstations enrolled, compliance policy (RTS-Workstation-Compliance), configuration profile (RTS-Workstation-Config)
6. **Win32 App Deployment** — 7-Zip 24.09 and Notepad++ 8.7.4 deployed to all devices via Intune
7. **PowerShell Automation** — user onboarding, bulk provisioning, compliance reporting, password reset with audit log
8. **Support Scenarios** — 5 real tickets worked end-to-end: account lockout, new hire onboarding, software request, OneDrive sync error, file share permissions

---

## Scripts

| Script | Description |
|--------|-------------|
| `scripts/New-RTSUser.ps1` | Bulk AD user creation from CSV with AAD sync |
| `scripts/Invoke-RTSOnboarding.ps1` | End-to-end single user onboarding (AD + groups + sync) |
| `scripts/Reset-RTSUserPassword.ps1` | Reset AD password and log action to `C:\IT\Logs\password-resets.log` |
| `scripts/Get-RTSComplianceReport.ps1` | Pull Intune device compliance data via Graph API and export to CSV |

---

## Documentation

### Standard Operating Procedures

| SOP | Description |
|-----|-------------|
| `docs/sops/new-user-onboarding.md` | End-to-end new employee setup procedure |
| `docs/sops/device-enrollment.md` | Intune MDM enrollment for domain-joined Windows 11 devices |
| `docs/sops/software-deployment.md` | Win32 app packaging and deployment via Intune |

### Knowledge Base

| Article | Topic |
|---------|-------|
| `docs/kb/KB-001-account-lockout.md` | Unlocking locked AD accounts |
| `docs/kb/KB-002-new-user-onboarding.md` | New employee setup reference |
| `docs/kb/KB-003-software-request.md` | Software deployment via Intune |
| `docs/kb/KB-004-onedrive-sync-error.md` | Resolving OneDrive invalid filename errors |
| `docs/kb/KB-005-file-share-permissions.md` | Granting and revoking file share access |

### Support Tickets

| Ticket | Summary | Status |
|--------|---------|--------|
| TICKET-001 | DC hostname not renamed post-promotion | Closed — accepted |
| TICKET-002 | Azure AD Cloud Sync blocked by network | Closed — switched to AD Connect |
| TICKET-003 | BitLocker non-compliance on lab VMs (no TPM) | Closed — accepted risk |
| TICKET-004 | Account lockout — atorres on WRK01 | Closed — resolved |
| TICKET-005 | New employee onboarding — Jamie Chen (Finance) | Closed — resolved |
| TICKET-006 | Software request — Notepad++ deployment | Closed — resolved |
| TICKET-007 | OneDrive sync error — invalid filename characters | Closed — resolved |
| TICKET-008 | File share access denied — Finance$ share | Closed — resolved |

---

## Skills Demonstrated

- **Active Directory** — OU design, user/group management, GPO creation and linking
- **Azure AD / Entra ID** — AD Connect sync, M365 licensing, cloud identity management
- **Microsoft Intune** — MDM enrollment, compliance policies, configuration profiles, Win32 app deployment
- **PowerShell** — AD automation, Graph API calls, audit logging, Hyper-V remoting
- **Networking** — DNS, DHCP, SMB file shares, internal virtual switching
- **M365** — Exchange Online, OneDrive for Business, Teams (via E5 license)
- **Troubleshooting** — systematic diagnosis of enrollment errors, permission issues, sync failures

---

## Screenshots

Deployment proof in `screenshots/`:

| File | Shows |
|------|-------|
| `01-aduc-ous.png` | AD Users and Computers — RTS OU structure and users |
| `02-azure-ad-users.png` | Entra ID — synced RTS users in M365 admin center |
| `03-intune-devices.png` | Intune — both workstations enrolled and managed |
| `04-compliance-policy.png` | Intune — RTS-Workstation-Compliance policy |
| `04b-compliance-status.png` | Intune — compliance monitor showing noncompliant: 2 |
| `05-7zip-deployed.png` | Intune — 7-Zip installed on both devices |
| `06-gpo-console.png` | GPMC — RTS-Password-Policy and RTS-Workstation-Policy |
| `07-dhcp-scope.png` | DHCP — Scope 192.168.1.0 RTS-LAN |
| `08-password-reset-log.png` | DC01 — password reset audit log entry |
