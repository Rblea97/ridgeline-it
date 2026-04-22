# SOP: Win32 App Deployment via Intune

**Organization:** Ridgeline Technology Services  
**Version:** 1.1  
**Last Updated:** 2026-04-22

---

## Purpose

This SOP documents the procedure for packaging and deploying Win32 applications to RTS workstations via Microsoft Intune.

## Scope

Applies to any Windows desktop application (.exe or .msi installer) deployed to Intune-enrolled RTS workstations.

## Prerequisites / Before You Begin

Before starting this procedure, confirm you have:

- [ ] Sign-in access to the Intune Admin Center at [intune.microsoft.com](https://intune.microsoft.com) using `admin@<TENANT>.onmicrosoft.com`
- [ ] At least one Intune-enrolled RTS workstation to test the deployment against
- [ ] A Windows machine (your technician workstation or DC01) with a staging folder created at `C:\intune-staging\`
- [ ] **Microsoft Win32 Content Prep Tool** (`IntuneWinAppUtil.exe`) downloaded and placed in `C:\intune-staging\`. Download from:  
  `https://raw.githubusercontent.com/microsoft/Microsoft-Win32-Content-Prep-Tool/master/IntuneWinAppUtil.exe`

---

## Step 1 — Download the Installer

1. Download the application installer (.msi or .exe) from the vendor's official site.
2. Create a subfolder for the application inside the staging directory:
   ```
   C:\intune-staging\<appname>\
   ```
3. Place the installer file in that subfolder.

Example for 7-Zip 24.09:
```
C:\intune-staging\7zip\7z2409-x64.msi
```

---

## Step 2 — Package with Win32 Content Prep Tool

> **Prerequisite:** Confirm `IntuneWinAppUtil.exe` is present at `C:\intune-staging\IntuneWinAppUtil.exe` before proceeding.  
> If missing, download it from:  
> `https://raw.githubusercontent.com/microsoft/Microsoft-Win32-Content-Prep-Tool/master/IntuneWinAppUtil.exe`

Open **Command Prompt as Administrator** on your technician workstation and run:

```cmd
IntuneWinAppUtil.exe -c <source-folder> -s <setup-file> -o <output-folder> -q
```

Example:
```cmd
C:\intune-staging\IntuneWinAppUtil.exe -c "C:\intune-staging\7zip" -s "7z2409-x64.msi" -o "C:\intune-staging\output" -q
```

This produces a `.intunewin` file in the output folder (e.g., `C:\intune-staging\output\7z2409-x64.intunewin`).

---

## Step 3 — Upload to Intune

1. Sign in to **intune.microsoft.com** as `admin@<TENANT>.onmicrosoft.com`
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
| Notepad++ | 8.7.4 | `npp.8.7.4.Installer.x64.exe` | `C:\Program Files\Notepad++\notepad++.exe` exists |

---

## Related Resources

- `docs/sops/device-enrollment.md`
- [Intune Win32 app documentation](https://learn.microsoft.com/en-us/mem/intune/apps/apps-win32-app-management)
