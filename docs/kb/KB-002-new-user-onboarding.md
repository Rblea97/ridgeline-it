# KB-002: End-to-End New Employee Setup

**Category:** Account Management / Onboarding  
**Applies To:** All new RTS employees  
**Last Updated:** 2026-04-18

---

## Overview

This article describes the complete process for onboarding a new RTS employee: creating their Active Directory account, syncing to Azure AD, and assigning an M365 license.

## Prerequisites

- Access to DC01 as a domain administrator
- Access to admin.microsoft.com as admin@fx934y.onmicrosoft.com
- Employee details: first name, last name, department, job title
- Valid departments: Operations, Finance, IT

## Procedure

### Step 1 — Run the Onboarding Script on DC01

```powershell
cd C:\Users\Richie\Projects\IT\ridgeline-it\scripts
.\Invoke-RTSOnboarding.ps1 -FirstName <First> -LastName <Last> -Department <Dept> -JobTitle "<Title>"
```

The script will:
- Create the AD account in the correct department OU
- Set the username (first initial + last name, e.g., jchen for Jamie Chen)
- Set UPN to `<username>@fx934y.onmicrosoft.com`
- Assign the user to **All Staff** and the department security group
- Set a temporary password (`Welcome1!2`) with force-change at first logon
- Trigger an Azure AD Connect delta sync

### Step 2 — Assign M365 License

Wait 2-3 minutes for the sync to complete, then:

1. Sign in to **admin.microsoft.com** as `admin@fx934y.onmicrosoft.com`
2. Go to **Users → Active users → [new user]**
3. Click **Licenses and apps**
4. Check **Microsoft 365 E5 Developer SKU V2**
5. Click **Save changes**

### Step 3 — Communicate Credentials

Provide the user with their credentials via a secure channel:

| Field | Value |
|-------|-------|
| Username | `<username>@fx934y.onmicrosoft.com` |
| Temp Password | `Welcome1!2` |
| First login | User will be prompted to set a new password |

## For Bulk Onboarding

Use `New-RTSUser.ps1` with a CSV file:

```powershell
.\New-RTSUser.ps1 -CsvPath "C:\path\to\users.csv"
```

CSV format: `FirstName, LastName, Department, JobTitle`

## Related

- `scripts/Invoke-RTSOnboarding.ps1`
- `scripts/New-RTSUser.ps1`
- `docs/sops/new-user-onboarding.md`
- `tickets/TICKET-005.md`
