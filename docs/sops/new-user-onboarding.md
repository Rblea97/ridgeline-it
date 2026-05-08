# SOP: New Employee Onboarding

**Company:** Ridgeline Technology Services
**Version:** 1.1
**Last Updated:** April 2026

---

## Purpose

This procedure covers creating a new employee's Active Directory account, syncing it to Azure AD (Entra ID), assigning an M365 E5 license, and confirming first login.

## Prerequisites / Before You Begin

Before starting this procedure, confirm you have:

- [ ] Remote Desktop (RDP) access to DC01 at `192.168.1.10` using `RIDGELINE\Administrator`
- [ ] The onboarding script present on DC01 at `C:\scripts\Invoke-RTSOnboarding.ps1`
- [ ] Sign-in access to the Microsoft 365 Admin Center at [admin.microsoft.com](https://admin.microsoft.com) using `admin@<TENANT>.onmicrosoft.com`
- [ ] The new hire's full name, department, and job title

Valid departments: **Operations**, **Finance**, **IT**

---

## Procedure

### Step 1: Connect to DC01

1. On your technician workstation, open **Remote Desktop Connection** (Start → search "Remote Desktop Connection").
2. In the **Computer** field, enter `192.168.1.10` and click **Connect**.
3. Log in as `RIDGELINE\Administrator` with the domain admin password.
4. Once logged in, open **PowerShell as Administrator** (Start → right-click **Windows PowerShell** → **Run as administrator**).
5. Navigate to the scripts directory:
   ```powershell
   cd C:\scripts
   ```

### Step 2: Create Active Directory Account

Run the onboarding script with the new hire's details:

```powershell
.\Invoke-RTSOnboarding.ps1 `
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
UPN        : flastname@<TENANT>.onmicrosoft.com
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

### Step 3: Assign M365 License

1. Go to [admin.microsoft.com](https://admin.microsoft.com).
2. Navigate to **Users → Active users**.
3. Wait 2–3 minutes after sync for the user to appear, then refresh the page.
4. Click the new user's display name to open their profile.
5. Click the **Licenses and apps** tab.
6. Check **Microsoft 365 E5 Developer** → click **Save changes**.

### Step 4: Communicate Credentials to New Hire

1. Open a new email or Teams message addressed to the new hire's personal email address (not their new work account).
2. Include the following information:
   - **Username:** `flastname@<TENANT>.onmicrosoft.com`
   - **Temporary password:** [generated temp password — communicated to user via secure channel]
   - **Instructions:** Sign in at [portal.office.com](https://portal.office.com). You will be prompted to set a new password on first login.
3. Send the message and note the date/time you sent it.

### Step 5: Verify Successful Onboarding

After the new hire has completed first login, confirm the following as the technician:

1. In **Active Directory Users and Computers** on DC01, navigate to **OU=RTS Users → OU=Department** and confirm the account exists and is enabled.
2. In [admin.microsoft.com](https://admin.microsoft.com) → **Users → Active users**, confirm the account shows a sync status of **In cloud** or **Synced with Active Directory**.
3. On the user's profile → **Licenses and apps** tab, confirm **Microsoft 365 E5 Developer** is listed as assigned.
4. Ask the new hire to confirm they can access [portal.office.com](https://portal.office.com) and open at least one M365 app (e.g., Outlook or Teams).

---

## For Bulk Onboarding

Use `scripts/New-RTSUser.ps1` with a CSV file:

```csv
FirstName,LastName,Department,JobTitle
Taylor,Morgan,Operations,Project Coordinator
Drew,Kim,Finance,Junior Accountant
```

```powershell
.\New-RTSUser.ps1 -CsvPath ".\new-hires.csv"
```

---

## Related

- [New-RTSUser.ps1](../../scripts/New-RTSUser.ps1)
- [Invoke-RTSOnboarding.ps1](../../scripts/Invoke-RTSOnboarding.ps1)
