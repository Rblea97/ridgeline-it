# KB-003: Requesting and Deploying Software via Intune

**Category:** Software Deployment  
**Applies To:** All RTS-managed workstations  
**Last Updated:** 2026-04-22

---

## Symptoms

A user or manager submits a software request ticket (e.g., "I need VLC Media Player installed on my workstation"). The software is not currently in the Intune app catalog, and the user cannot install it themselves because standard user accounts do not have local administrator rights on RTS-managed workstations.

## Cause

RTS workstations are managed via Microsoft Intune with standard user permissions enforced by policy. Users cannot install software locally. All software must be packaged as a Win32 app, uploaded to Intune, and deployed through the Intune management pipeline to ensure it is installed consistently, inventoried, and removable by IT.

## Tools Required

- **IntuneWinAppUtil.exe** — located at `C:\intune-staging\IntuneWinAppUtil.exe`
- **Intune Admin Center** — intune.microsoft.com

## Procedure

### Step 1 — Download the Installer

Save the installer (.exe or .msi) to a dedicated staging folder named after the application:

```
C:\intune-staging\<AppName>\<installer>
```

**Example — staging VLC:**
```
C:\intune-staging\VLC\vlc-3.0.21-win64.exe
```

### Step 2 — Package with Win32 Content Prep Tool

```cmd
IntuneWinAppUtil.exe -c "C:\intune-staging\<AppName>" -s "<installer-file>" -o "C:\intune-staging\output" -q
```

**Example — package VLC:**
```cmd
IntuneWinAppUtil.exe -c "C:\intune-staging\VLC" -s "vlc-3.0.21-win64.exe" -o "C:\intune-staging\output" -q
```

This creates a `.intunewin` file (e.g., `vlc-3.0.21-win64.intunewin`) in `C:\intune-staging\output`.

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

**Example — VLC install/uninstall commands:**
- Install: `vlc-3.0.21-win64.exe /S`
- Uninstall: `C:\Program Files\VideoLAN\VLC\uninstall.exe /S`
- Detection: File exists at `C:\Program Files\VideoLAN\VLC\vlc.exe`

### Step 5 — Verify Deployment

After ~30 minutes, check **Apps → [App name] → Device install status** in Intune, or run on the workstation:

```powershell
Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*' |
    Where-Object { $_.DisplayName -like '*VLC*' } |
    Select-Object DisplayName, DisplayVersion
```

Expected output shows the app name and version. Confirm with the user that the application launches successfully.

## Currently Deployed Apps

| App | Version | Detection |
|-----|---------|-----------|
| 7-Zip | 24.09 | `C:\Program Files\7-Zip\7z.exe` |
| Notepad++ | 8.7.4 | `C:\Program Files\Notepad++\notepad++.exe` |

## Related

- `docs/sops/software-deployment.md`
- `tickets/TICKET-006.md`
