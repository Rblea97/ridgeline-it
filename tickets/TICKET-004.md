# TICKET-004: Account Lockout — atorres on WRK01

**Ticket ID:** TICKET-004  
**Date:** 2026-04-18  
**Reported by:** Alex Torres (atorres)  
**Assigned to:** Richard Blea (Lab Admin)  
**Status:** Closed — Resolved  
**Priority:** P2 High  
**SLA:** Tier 2 — 4 hr response / 8 hr resolution
**Category:** Account Management / Active Directory

---

## Summary

User Alex Torres (atorres) was locked out of their account on WRK01 after entering an incorrect password multiple times. The user could not log in and received a lockout message on the Windows sign-in screen.

---

## Triage / Priority Assessment

| Dimension | Assessment |
|---|---|
| Impact | Medium — single user affected |
| Urgency | High — user cannot log in, no workaround available |
| Calculated priority | P2 High |
| SLA tier | Tier 2 — 4 hr response / 8 hr resolution |

Escalated from department default (Tier 3) based on urgency. Decision documented at triage. See [`ticketing/docs/03-priority-matrix.md`](../ticketing/docs/03-priority-matrix.md) for the full matrix.

---

## Environment

| Field | Value |
|-------|-------|
| Affected User | atorres (Alex Torres) |
| Device | WRK01 (DESKTOP-4PL0V3F) |
| Domain | RIDGELINE |
| Lockout Policy | RTS-Password-Policy GPO — 5 invalid attempts |

---

## Root Cause

The user entered an incorrect password 5 times in succession, triggering the account lockout threshold defined in the **RTS-Password-Policy** Group Policy Object:

- **Lockout threshold:** 5 invalid logon attempts
- **Lockout duration:** Until manually unlocked by an administrator
- **Observation window:** 30 minutes

This is expected behavior — the lockout policy protects against brute-force password attacks.

---

## Impact

- User unable to log in to WRK01
- No data loss or security breach
- Work interrupted until admin unlocked the account

---

## Resolution

Resolved via PowerShell on DC01 (run as Administrator):

```powershell
# Step 1 — Confirm account is locked
Search-ADAccount -LockedOut | Select-Object Name, SamAccountName, LockedOut

# Step 2 — Unlock the account
Unlock-ADAccount -Identity atorres

# Step 3 — Verify unlock
Get-ADUser atorres -Properties LockedOut | Select-Object Name, LockedOut
```

**Result:**
- `Search-ADAccount -LockedOut` confirmed atorres was locked (LockedOut: True)
- `Unlock-ADAccount` succeeded
- Verification confirmed LockedOut: False

User was able to log in successfully after the unlock.

---

## Lessons Learned

- Account lockout events should be investigated to rule out unauthorized access attempts. In this case the cause was a forgotten password, not an attack.
- In production, Event ID 4740 (Account Locked Out) on the domain controller provides the originating machine and timestamp.
- Consider implementing a self-service password reset portal (SSPR) via Azure AD to reduce admin overhead for routine lockouts.

---

## Related

- `docs/kb/KB-001-account-lockout.md`
- `scripts/Reset-RTSUserPassword.ps1`
- GPO: RTS-Password-Policy
