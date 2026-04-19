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
| Target | All enrolled RTS workstations (WRK01, WRK02) |
| Deployment method | Intune Win32 app |

---

## Actions Taken

### Step 1 — Download Installer

```powershell
Invoke-WebRequest `
    -Uri 'https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.7.4/npp.8.7.4.Installer.x64.exe' `
    -OutFile '<STAGING-PATH>\notepadpp\npp.8.7.4.Installer.x64.exe'
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

---

## Lessons Learned

- The `/S` silent install flag works for Notepad++ NSIS-based installers.
- Intune Win32 app deployments take approximately 30 minutes to appear on enrolled devices after assignment.
- Detection rules using file existence are reliable for apps that install to predictable paths.

---

## Related

- `docs/sops/software-deployment.md`
- `docs/kb/KB-003-software-request.md`
