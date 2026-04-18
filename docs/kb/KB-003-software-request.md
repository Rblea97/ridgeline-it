# KB-003: Requesting and Deploying Software via Intune

**Category:** Software Deployment  
**Applies To:** All RTS-managed workstations  
**Last Updated:** 2026-04-18

---

## Overview

Software for RTS workstations is deployed centrally through Microsoft Intune. This article covers how to package and deploy a Win32 application.

## Tools Required

- **IntuneWinAppUtil.exe** — located at `C:\Users\Richie\Projects\IT\intune-staging\IntuneWinAppUtil.exe`
- **Intune Admin Center** — intune.microsoft.com

## Procedure

### Step 1 — Download the Installer

Save the installer (.exe or .msi) to a dedicated staging folder:

```
C:\Users\Richie\Projects\IT\intune-staging\<appname>\<installer>
```

### Step 2 — Package with Win32 Content Prep Tool

```cmd
IntuneWinAppUtil.exe -c "<source-folder>" -s "<installer-file>" -o "C:\intune-staging\output" -q
```

This creates a `.intunewin` file in the output folder.

### Step 3 — Upload to Intune

1. Go to **intune.microsoft.com → Apps → All apps → + Add**
2. App type: **Windows app (Win32)**
3. Upload the `.intunewin` file

### Step 4 — Configure the App

| Setting | Notes |
|---------|-------|
| Install command | Silent install flag (e.g., `/S` for NSIS, `/qn` for MSI) |
| Uninstall command | Use uninstaller path or MSI GUID |
| Install behavior | **System** (installs for all users) |
| OS architecture | 64-bit |
| Detection rule | File existence in `C:\Program Files\<AppName>\` |
| Assignment | Required — All Devices |

### Step 5 — Verify Deployment

After ~30 minutes, check **Apps → [App name] → Device install status** in Intune, or run on the workstation:

```powershell
Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*' |
    Where-Object { $_.DisplayName -like '*<AppName>*' } |
    Select-Object DisplayName, DisplayVersion
```

## Currently Deployed Apps

| App | Version | Detection |
|-----|---------|-----------|
| 7-Zip | 24.09 | `C:\Program Files\7-Zip\7z.exe` |
| Notepad++ | 8.7.4 | `C:\Program Files\Notepad++\notepad++.exe` |

## Related

- `docs/sops/software-deployment.md`
- `tickets/TICKET-006.md`
