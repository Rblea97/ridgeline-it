# TICKET-007: OneDrive Sync Error — Invalid Filename Characters

**Ticket ID:** TICKET-007  
**Date:** 2026-04-18  
**Reported by:** Alex Torres (atorres)  
**Assigned to:** Richard Blea (Lab Admin)  
**Status:** Closed — Resolved  
**Priority:** Low  
**Category:** Cloud Services / OneDrive

---

## Summary

User Alex Torres reported that a file saved to their OneDrive for Business folder was not syncing. The OneDrive taskbar icon displayed a red X sync error badge. The file name contained characters not permitted by OneDrive for Business.

---

## Environment

| Field | Value |
|-------|-------|
| Affected User | atorres (Alex Torres) |
| Device | WRK01 (DESKTOP-4PL0V3F) |
| Service | OneDrive for Business (<TENANT>.onmicrosoft.com) |
| Problematic File | `Budget<Final>.xlsx` |

---

## Root Cause

The file `Budget<Final>.xlsx` contained angle bracket characters (`<` and `>`) in the filename. While NTFS (Windows file system) permits these characters when files are created programmatically using the `\\?\` extended path prefix, OneDrive for Business does not permit them and cannot upload or sync files with these characters in their names.

**Characters not permitted by OneDrive for Business:**

| Character | Description |
|-----------|-------------|
| `"` | Double quote |
| `*` | Asterisk |
| `:` | Colon |
| `<` | Less-than sign |
| `>` | Greater-than sign |
| `?` | Question mark |
| `/` | Forward slash |
| `\` | Backslash |
| `\|` | Pipe |

Files ending with a period or space are also blocked.

---

## Impact

- File was not backed up to OneDrive
- User could not access the file from other devices or the web
- OneDrive showed a persistent sync error badge in the system tray

---

## Resolution

### Step 1 — Identify the problem file

Click the **OneDrive icon** in the system tray → click the sync error to view affected files.

### Step 2 — Rename the file

Right-click the file in File Explorer → **Rename** → remove or replace the invalid characters:

```
Budget<Final>.xlsx  →  Budget-Final.xlsx
```

### Step 3 — Verify sync

After renaming, OneDrive automatically retries the upload. The error badge clears within 30–60 seconds and the file appears in OneDrive on the web.

---

## Lessons Learned

- Educate users not to use special characters (`< > : " * ? \ / |`) in filenames, especially in OneDrive-synced folders.
- Consider deploying a Group Policy or OneDrive Known Folder Move configuration to prevent sync issues proactively.
- The [Microsoft OneDrive sync error documentation](https://support.microsoft.com/en-us/office/restrictions-and-limitations-in-onedrive-and-sharepoint-64883a5d-228e-48f5-b3d2-eb39e07630fa) lists all restricted characters and filenames.

---

## Related

- `docs/kb/KB-004-onedrive-sync-error.md`
