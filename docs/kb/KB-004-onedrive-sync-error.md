# KB-004: Resolving OneDrive Sync Errors (Invalid Filenames)

**Category:** Cloud Services / OneDrive  
**Applies To:** All RTS users with OneDrive for Business  
**Last Updated:** 2026-04-18

---

## Symptoms

- OneDrive taskbar icon shows a red X or yellow warning badge
- Clicking the icon reveals one or more files that "couldn't be synced"
- Error message: "We can't sync this file because of the file name or type"

## Cause

OneDrive for Business cannot sync files or folders whose names contain certain characters or patterns that are not permitted by SharePoint Online.

**Blocked characters:**

| Character | Symbol |
|-----------|--------|
| Double quote | `"` |
| Asterisk | `*` |
| Colon | `:` |
| Less-than | `<` |
| Greater-than | `>` |
| Question mark | `?` |
| Forward slash | `/` |
| Backslash | `\` |
| Pipe | `\|` |

**Also blocked:**
- Filenames ending with a period (`.`) or space
- Filenames exceeding 400 characters in total path length
- Reserved names: CON, PRN, AUX, NUL, COM1–COM9, LPT1–LPT9

## Resolution

### Step 1 — Identify the affected file

Click the **OneDrive icon** in the system tray → the sync error panel shows the filename and error.

### Step 2 — Rename the file

In File Explorer, right-click the file → **Rename** → remove or replace the invalid character:

**Example:**
```
Budget<Final>.xlsx  →  Budget-Final.xlsx
Q3 Report*.docx     →  Q3 Report.docx
```

### Step 3 — Verify sync

OneDrive automatically retries the upload after the rename. The error badge clears within 30–60 seconds.

## Prevention

- Avoid using special characters in filenames, especially in OneDrive-synced folders
- Consider using dashes (`-`) or underscores (`_`) instead of special characters
- Educate users during onboarding about OneDrive filename restrictions

## Related

- `tickets/TICKET-007.md`
- [Microsoft OneDrive restrictions and limitations](https://support.microsoft.com/en-us/office/restrictions-and-limitations-in-onedrive-and-sharepoint-64883a5d-228e-48f5-b3d2-eb39e07630fa)
