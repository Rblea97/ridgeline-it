# KB-002: End-to-End New Employee Setup

**Category:** Account Management / Onboarding  
**Applies To:** All new RTS employees  
**Last Updated:** 2026-04-22

---

## Symptoms

A new hire has been added to the HR system but has no Active Directory account, cannot log in to any domain-joined workstation, and has no Microsoft 365 access or email address. This procedure is triggered when IT receives a new-hire request (typically via a ticket from HR or a manager).

## Cause

RTS user accounts are not created automatically. Every new employee requires a manually initiated onboarding process to create the AD account, sync it to Azure AD via Azure AD Connect, and assign an M365 license. Skipping any step leaves the user without domain login, email, or cloud access.

## Prerequisites

- Access to DC01 as a domain administrator
- Access to admin.microsoft.com as `admin@ridgeline.onmicrosoft.com`
- Employee details: first name, last name, department, job title
- Valid departments: Operations, Finance, IT

## Procedure

### Step 1 — Run the Onboarding Script on DC01

```powershell
cd C:\ridgeline-it\scripts
.\Invoke-RTSOnboarding.ps1 -FirstName <First> -LastName <Last> -Department <Dept> -JobTitle "<Title>"
```

**Example — onboard Jamie Chen in Finance as Accountant:**
```powershell
cd C:\ridgeline-it\scripts
.\Invoke-RTSOnboarding.ps1 -FirstName Jamie -LastName Chen -Department Finance -JobTitle "Accountant"
```

The script will:
- Create the AD account in the correct department OU
- Set the username (first initial + last name, e.g., `jchen` for Jamie Chen)
- Set UPN to `<username>@ridgeline.onmicrosoft.com`
- Assign the user to **All Staff** and the department security group
- Set a temporary password (`Welcome1!2`) with force-change at first logon
- Trigger an Azure AD Connect delta sync

### Step 2 — Assign M365 License

Wait 2-3 minutes for the sync to complete, then:

1. Sign in to **admin.microsoft.com** as `admin@ridgeline.onmicrosoft.com`
2. Go to **Users → Active users → [new user]**
3. Click **Licenses and apps**
4. Check **Microsoft 365 E5 Developer SKU V2**
5. Click **Save changes**

### Step 3 — Communicate Credentials

Provide the user with their credentials via a secure channel:

| Field | Value |
|-------|-------|
| Username | `<username>@ridgeline.onmicrosoft.com` |
| Temp Password | `Welcome1!2` |
| First login | User will be prompted to set a new password |

**Example for Jamie Chen:** username is `jchen@ridgeline.onmicrosoft.com`

## Verification

After completing all three steps, confirm the following before closing the ticket:

```powershell
# Confirm AD account exists and is enabled
Get-ADUser -Identity jchen -Properties Enabled, MemberOf | Select-Object Name, Enabled, MemberOf
```

Expected: `Enabled : True` and MemberOf includes both `All Staff` and the department group.

Then confirm in admin.microsoft.com that the user appears under **Users → Active users** with a license assigned (status shows **Licensed**).

Finally, ask the user (or confirm via the ticket) that they were able to log in and set their new password successfully.

## For Bulk Onboarding

Use `New-RTSUser.ps1` with a CSV file:

```powershell
.\New-RTSUser.ps1 -CsvPath "C:\ridgeline-it\scripts\users.csv"
```

CSV format: `FirstName, LastName, Department, JobTitle`

## Related

- `scripts/Invoke-RTSOnboarding.ps1`
- `scripts/New-RTSUser.ps1`
- `docs/sops/new-user-onboarding.md`
- `tickets/TICKET-005.md`
