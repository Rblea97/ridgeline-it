# TICKET-006: Software Request — Notepad++ Deployment via Intune

**Ticket ID:** TICKET-006
**Date:** 2026-04-18
**Reported by:** Operations Team
**Assigned to:** Richard Blea (Lab Admin)
**Status:** Closed — Resolved
**Priority:** Low
**Category:** Software Deployment / Intune

---

## Summary

The Operations team requested Notepad++ be deployed to all RTS workstations for editing configuration files and scripts. The application was packaged and deployed via Microsoft Intune Win32 app deployment.

---

## Environment

| Field | Value |
|-------|-------|
| Application | Notepad++ 8.7.4 |
| Installer | npp.8.7.4.Installer.x64.exe |
| Packaging Tool | Microsoft Win32 Content Prep Tool (IntuneWinAppUtil.exe) |
| Staging Path | C:\intune-staging\notepadpp on DC01 |
| Target Devices | WRK01 (DESKTOP-4PL0V3F), WRK02 (DESKTOP-BTK0BJ4) |
| Deployment Method | Intune Win32 app — Required assignment to All Devices |
| Install Behavior | System context |

---

## Root Cause

Not applicable — this is a software deployment request, not an incident. Notepad++ was absent from all workstations because no software deployment pipeline had been configured prior to this ticket. The standard Win32 app packaging and Intune deployment workflow was followed to fulfill the request.

---

## Actions Taken

### Step 1 — Download Installer

```powershell
$stagingPath = 'C:\intune-staging\notepadpp'
New-Item -ItemType Directory -Force -Path $stagingPath

Invoke-WebRequest `
    -Uri 'https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.7.4/npp.8.7.4.Installer.x64.exe' `
    -OutFile "$stagingPath\npp.8.7.4.Installer.x64.exe"
```

### Step 2 — Package with Win32 Content Prep Tool

```cmd
IntuneWinAppUtil.exe -c "C:\intune-staging\notepadpp" -s "npp.8.7.4.Installer.x64.exe" -o "C:\intune-staging\output" -q
```

Output: `npp.8.7.4.Installer.x64.intunewin` (6.3 MB)

### Step 3 — Upload and Configure in Intune

Uploaded to **intune.microsoft.com → Apps → All apps → + Add → Windows app (Win32)**

| Setting | Value |
|---------|-------|
| Name | Notepad++ 8.7.4 |
| Publisher | Notepad++ Team |
| Version | 8.7.4 |
| Install command | `npp.8.7.4.Installer.x64.exe /S` |
| Uninstall command | `"C:\Program Files\Notepad++\uninstall.exe" /S` |
| Install behavior | System |
| OS architecture | 64-bit |
| Minimum OS | Windows 10 1607 |
| Detection rule | File: `C:\Program Files\Notepad++\notepad++.exe` exists |
| Assignment | Required — All Devices |

### Step 4 — Verify Deployment

After approximately 30 minutes, confirmed installation on both workstations:

```powershell
# Run on WRK01 and WRK02 to confirm installation
Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*' |
    Where-Object { $_.DisplayName -like 'Notepad++*' } |
    Select-Object DisplayName, DisplayVersion, InstallLocation
```

Both workstations returned `Notepad++ 8.7.4` installed at `C:\Program Files\Notepad++`.

---

## Lessons Learned

- The `/S` silent install flag works for Notepad++ NSIS-based installers. Always test the silent install command locally (`cmd /c installer.exe /S`) before uploading to Intune to catch flag variations early.
- Intune Win32 app deployments take approximately 30 minutes to appear on enrolled devices after assignment — check the **Device install status** report in Intune rather than polling the device manually.
- Detection rules using file existence are reliable for apps that install to predictable paths. For apps that install to user-specific paths, use registry-based detection rules instead.

---

## Related

- `docs/sops/software-deployment.md`
- `docs/kb/KB-003-software-request.md`
