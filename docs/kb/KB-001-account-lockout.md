# KB-001: How to Unlock a Locked Active Directory Account

**Category:** Account Management  
**Applies To:** All RTS domain users  
**Last Updated:** 2026-04-22

---

## Symptoms

- User receives "Your account has been locked out" message at the Windows sign-in screen
- User cannot log in despite entering the correct password
- User reports being unable to access any domain resources

## Cause

The **RTS-Password-Policy** GPO enforces an account lockout after **5 consecutive failed login attempts**. The account remains locked until an administrator unlocks it manually.

## Resolution

Run the following on **DC01 as Administrator**:

```powershell
# Step 1 — Identify locked accounts
Search-ADAccount -LockedOut | Select-Object Name, SamAccountName, LockedOut

# Step 2 — Unlock the account
Unlock-ADAccount -Identity <SamAccountName>
```

The user can log in immediately after the account is unlocked — no restart or additional action required.

## Verification

Confirm the account is no longer locked:

```powershell
Get-ADUser <SamAccountName> -Properties LockedOut | Select-Object Name, LockedOut
```

Expected output: `LockedOut : False`

Ask the user to attempt login and confirm access is restored before closing the ticket.

## Prevention

- Users should wait and try again rather than repeatedly guessing a password
- For repeated lockouts, consider whether the user needs a password reset:
  ```powershell
  # Example: reset password for atorres
  .\Reset-RTSUserPassword.ps1 -SamAccountName atorres
  ```
- Review Event ID **4740** on DC01 for the source machine and timestamp of the lockout

## Related

- `scripts/Reset-RTSUserPassword.ps1`
- `tickets/TICKET-004.md`
- GPO: RTS-Password-Policy
