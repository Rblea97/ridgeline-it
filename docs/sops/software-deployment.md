# SOP: Win32 App Deployment via Intune

**Organization:** Ridgeline Technology Services  
**Version:** 1.0  
**Last Updated:** 2026-04-18

---

## Purpose

This SOP documents the procedure for packaging and deploying Win32 applications to RTS workstations via Microsoft Intune.

## Scope

Applies to any Windows desktop application (.exe or .msi installer) deployed to Intune-enrolled RTS workstations.

## Tools Required

| Tool | Purpose | Location |
|------|---------|----------|
| Microsoft Win32 Content Prep Tool (IntuneWinAppUtil.exe) | Package installer into .intunewin format | `C:\Users\Richie\Projects\IT\intune-staging\IntuneWinAppUtil.exe` |
| Intune Admin Center | Upload and configure the app | https://intune.microsoft.com |

Download the Win32 Content Prep Tool from:  
`https://raw.githubusercontent.com/microsoft/Microsoft-Win32-Content-Prep-Tool/master/IntuneWinAppUtil.exe`

---

## Step 1 — Download the Installer

Download the application installer (.msi or .exe) and place it in a dedicated staging folder:

```
C:\intune-staging\<appname>\<installer.msi>
```

Example for 7-Zip 24.09:
```
C:\Users\Richie\Projects\IT\intune-staging\7zip\7z2409-x64.msi
```

---

## Step 2 — Package with Win32 Content Prep Tool

Run IntuneWinAppUtil.exe with the following arguments:

```cmd
IntuneWinAppUtil.exe -c <source-folder> -s <setup-file> -o <output-folder> -q
```

Example:
```cmd
IntuneWinAppUtil.exe -c "C:\intune-staging\7zip" -s "7z2409-x64.msi" -o "C:\intune-staging\output" -q
```

This produces a `.intunewin` file in the output folder (e.g., `7z2409-x64.intunewin`).

---

## Step 3 — Upload to Intune

1. Sign in to **intune.microsoft.com** as `admin@fx934y.onmicrosoft.com`
2. Go to **Apps → All apps → + Add**
3. App type: **Windows app (Win32)** → click **Select**
4. Click **Select app package file** → browse to the `.intunewin` file → click **OK**

---

## Step 4 — Configure App Information

Fill in the app details:

| Field | Value (7-Zip example) |
|-------|-----------------------|
| Name | 7-Zip 24.09 |
| Description | Open source file archiver |
| Publisher | Igor Pavlov |
| Version | 24.09 |

Click **Next**.

---

## Step 5 — Configure Program Settings

| Field | Value (MSI example) |
|-------|---------------------|
| Install command | `msiexec /i 7z2409-x64.msi /qn` |
| Uninstall command | `msiexec /x {23170F69-40C1-2702-2409-000001000000} /qn` |
| Install behavior | **System** |

> **Tip:** The uninstall GUID can be found in the registry at `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\` after installing locally, or in the MSI metadata.

Click **Next**.

---

## Step 6 — Requirements

| Field | Value |
|-------|-------|
| OS architecture | 64-bit |
| Minimum OS | Windows 10 1607 |

Click **Next**.

---

## Step 7 — Detection Rules

- Rules format: **Manually configure detection rules**
- Click **+ Add**

| Field | Value (7-Zip example) |
|-------|-----------------------|
| Rule type | File |
| Path | `C:\Program Files\7-Zip` |
| File or folder | `7z.exe` |
| Detection method | File or folder exists |

Click **OK** → **Next**.

---

## Step 8 — Assignments

- Under **Required** → click **+ Add group** or **+ Add all users / Add all devices**
- For RTS lab: assign to **All Devices**
- Click **Next** → **Create**

---

## Step 9 — Verify Deployment

After ~30 minutes, verify the app installed on enrolled devices:

```powershell
# Run on target workstation
Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*' |
    Where-Object { $_.DisplayName -like '*7-Zip*' } |
    Select-Object DisplayName, DisplayVersion
```

Or check in Intune: **Apps → All apps → [App name] → Device install status**.

---

## Deployed Applications

| App | Version | Installer | Detection |
|-----|---------|-----------|-----------|
| 7-Zip | 24.09 | `7z2409-x64.msi` | `C:\Program Files\7-Zip\7z.exe` exists |

---

## Related Resources

- `docs/sops/device-enrollment.md`
- [Intune Win32 app documentation](https://learn.microsoft.com/en-us/mem/intune/apps/apps-win32-app-management)
