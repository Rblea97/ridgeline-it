# SOP: New Employee Onboarding

**Company:** Ridgeline Technology Services
**Version:** 1.0
**Last Updated:** April 2026

---

## Purpose

This procedure covers creating a new employee's Active Directory account, syncing it to Azure AD (Entra ID), assigning an M365 E5 license, and confirming first login.

## Prerequisites

- Domain Admin access to DC01 (RIDGELINE\Administrator)
- Access to Microsoft 365 Admin Center (admin@fx934y.onmicrosoft.com)
- New hire details: first name, last name, department, job title

Valid departments: **Operations**, **Finance**, **IT**

---

## Procedure

### Step 1: Create Active Directory Account

On DC01, open PowerShell as Administrator and run:

```powershell
.\scripts\Invoke-RTSOnboarding.ps1 `
    -FirstName  "FirstName" `
    -LastName   "LastName" `
    -Department "Department" `
    -JobTitle   "Job Title"
```

Expected output:
```
=== RTS New Employee Onboarding ===
Name       : FirstName LastName
Username   : flastname
UPN        : flastname@fx934y.onmicrosoft.com
Department : Department
Job Title  : Job Title
OU         : OU=Department,OU=RTS Users,DC=ridgeline,DC=local

[1/3] Creating Active Directory account...
    AD account created.
[2/3] Adding to security groups...
    Added to 'All Staff' and 'Department Users'.
[3/3] Triggering Azure AD Connect delta sync...
    Sync triggered successfully.

=== Onboarding Complete ===
Next step: Assign M365 E5 license in admin.microsoft.com
```

### Step 2: Assign M365 License

1. Go to [admin.microsoft.com](https://admin.microsoft.com)
2. Navigate to **Users → Active users**
3. Wait 2–3 minutes after sync for the user to appear
4. Click the new user → **Licenses and apps** tab
5. Check **Microsoft 365 E5 Developer** → **Save changes**

### Step 3: Communicate Credentials to New Hire

Provide:
- **Username:** `flastname@fx934y.onmicrosoft.com`
- **Temp password:** `Welcome1!`
- User will be prompted to change password at first login

### Step 4: Verify First Login

Have the employee sign in on their assigned workstation using `RIDGELINE\flastname`. Confirm:
- Password change prompt appears and completes successfully
- They can access M365 apps at portal.office.com

---

## For Bulk Onboarding

Use `scripts/New-RTSUser.ps1` with a CSV file:

```csv
FirstName,LastName,Department,JobTitle
Taylor,Morgan,Operations,Project Coordinator
Drew,Kim,Finance,Junior Accountant
```

```powershell
.\scripts\New-RTSUser.ps1 -CsvPath ".\new-hires.csv"
```

---

## Related

- [New-RTSUser.ps1](../../scripts/New-RTSUser.ps1)
- [Invoke-RTSOnboarding.ps1](../../scripts/Invoke-RTSOnboarding.ps1)
