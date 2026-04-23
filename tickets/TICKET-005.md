# TICKET-005: New Employee Onboarding — Jamie Chen (Finance)

**Ticket ID:** TICKET-005
**Date:** 2026-04-18
**Reported by:** HR / Manager
**Assigned to:** Richard Blea (Lab Admin)
**Status:** Closed — Resolved
**Priority:** Medium
**Category:** Account Management / Onboarding

---

## Summary

New employee Jamie Chen joined the Finance department as a Financial Analyst. An Active Directory account, security group memberships, and Microsoft 365 license were provisioned using the RTS onboarding script and admin portal.

---

## Environment

| Field | Value |
|-------|-------|
| New User | Jamie Chen |
| Username | jchen |
| UPN | jchen@ridgelinets.onmicrosoft.com |
| Department | Finance |
| Job Title | Financial Analyst |
| OU | OU=Finance,OU=RTS Users,DC=ridgeline,DC=local |
| Domain | ridgeline.local |
| Provisioning Server | DC01 — WIN-DTBFF0R4BBQ, IP 192.168.1.10 |

---

## Root Cause

Not applicable — this is a provisioning request, not an incident. A script defect was encountered during execution: the onboarding script's default temporary password (`Welcome1!`, 9 characters) did not meet the domain password policy minimum length of 10 characters, causing the `New-ADUser` call to create the account in a disabled state. See Notes section for details.

---

## Actions Taken

### Step 1 — Run Onboarding Script on DC01

```powershell
.\Invoke-RTSOnboarding.ps1 -FirstName Jamie -LastName Chen -Department Finance -JobTitle "Financial Analyst"
```

**Script output:**
- AD account `jchen` created in `OU=Finance,OU=RTS Users,DC=ridgeline,DC=local`
- Added to security groups: **All Staff**, **Finance Users**
- UPN set to `jchen@ridgelinets.onmicrosoft.com`
- Temporary password: `Welcome1!2` (user must change at first logon)
- Azure AD Connect delta sync triggered (Result: Success)

### Step 2 — Assign M365 License

Navigated to **admin.microsoft.com → Users → Active users → Jamie Chen → Licenses and apps** and assigned **Microsoft 365 E5 Developer SKU V2**.

### Step 3 — Verify AD Account and Group Membership

```powershell
# Confirm account exists and is enabled
Get-ADUser jchen -Properties Enabled, MemberOf | Select-Object Name, SamAccountName, Enabled

# Confirm group memberships
Get-ADPrincipalGroupMembership jchen | Select-Object Name
```

### Step 4 — Communicate Credentials to User

Temporary credentials communicated to user via secure channel:

| Field | Value |
|-------|-------|
| Username | jchen@ridgelinets.onmicrosoft.com |
| Temp Password | Welcome1!2 |
| First Login | User will be prompted to set a new password |

---

## Notes

The initial script run failed to enable the account because the default password `Welcome1!` (9 characters) did not meet the domain password policy minimum of 10 characters. The `New-ADUser` cmdlet created the account but left it disabled. The script default was updated to `Welcome1!2` (10 characters), the account was manually enabled with `Enable-ADAccount -Identity jchen`, and the password was reset with `Set-ADAccountPassword`. The script has been fixed for future runs.

---

## Lessons Learned

- Verify that default passwords in onboarding scripts meet the domain password policy **before** deploying the script in production. Use `Get-ADDefaultDomainPasswordPolicy` to retrieve minimum length, complexity, and history requirements, then validate the script default against them.
- For new employees, confirm that Azure AD Connect sync has completed (allow 2–3 minutes after triggering a delta sync) before attempting M365 license assignment — the user object must be visible in the admin portal first.

---

## Related

- `scripts/Invoke-RTSOnboarding.ps1`
- `docs/sops/new-user-onboarding.md`
- `docs/kb/KB-002-new-user-onboarding.md`
