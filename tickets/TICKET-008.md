# TICKET-008: File Share Access Denied — Finance$ Share

**Ticket ID:** TICKET-008  
**Date:** 2026-04-18  
**Reported by:** Alex Torres (atorres)  
**Assigned to:** Richard Blea (Lab Admin)  
**Status:** Closed — Resolved  
**Priority:** P3 Medium  
**SLA:** Tier 3 — 8 hr response / 24 hr resolution
**Category:** File Share / Permissions

---

## Summary

User Alex Torres (Operations) requested access to the Finance department file share `\\WIN-DTBFF0R4BBQ\Finance$` for a cross-department project. The user received an "Access Denied" error when attempting to connect. Access was granted by adding the user to the Finance Users security group.

---

## Triage / Priority Assessment

| Dimension | Assessment |
|---|---|
| Impact | Low — single user blocked from a single share |
| Urgency | Medium — cross-department project work blocked |
| Calculated priority | P3 Medium |
| SLA tier | Tier 3 — 8 hr response / 24 hr resolution |

Routed to IT Support per department default.

---

## Environment

| Field | Value |
|-------|-------|
| Affected User | atorres (Alex Torres) |
| Device | WRK01 (DESKTOP-4PL0V3F) |
| Share | `\\WIN-DTBFF0R4BBQ\Finance$` |
| Share Path | `C:\Shares\Finance` on DC01 |

---

## Root Cause

The Finance$ share restricts access to members of the **Finance Users** security group. Alex Torres is in the **Operations Users** group and was not a member of Finance Users, so access was denied.

A secondary issue was encountered during setup: the share was initially created with `-NoAccess 'Everyone'`, which added an explicit **Deny** ACE for Everyone at the share level. Because Deny permissions take precedence over Allow, this blocked access even after atorres was added to Finance Users. The share was rebuilt without the Deny ACE to resolve this.

---

## Impact

- User could not access the Finance$ file share
- Cross-department project work was blocked until access was granted

---

## Resolution

### Step 1 — Verify share and NTFS permissions (on DC01)

```powershell
Get-SmbShareAccess -Name 'Finance$'
(Get-Acl 'C:\Shares\Finance').Access | Select-Object IdentityReference, FileSystemRights, AccessControlType
```

### Step 2 — Add atorres to Finance Users

```powershell
Add-ADGroupMember -Identity 'Finance Users' -Members 'atorres'
Get-ADGroupMember 'Finance Users' | Select-Object Name, SamAccountName
```

### Step 3 — Remove Deny ACE (share rebuild required)

The initial share configuration included an explicit Deny for Everyone. Rebuilt without it:

```powershell
Remove-SmbShare -Name 'Finance$' -Force
New-SmbShare -Name 'Finance$' -Path 'C:\Shares\Finance' -FullAccess 'RIDGELINE\Finance Users','BUILTIN\Administrators'
```

### Step 4 — Verification (user re-authenticates and access confirmed)

User ran `klist purge` to clear the cached Kerberos ticket, then logged off and back on to obtain a new token reflecting the Finance Users group membership. Access to `\\WIN-DTBFF0R4BBQ\Finance$` confirmed successful.

---

## Lessons Learned

- **Deny ACEs always override Allow ACEs** in Windows access control. Avoid using `-NoAccess` (Deny) at the share level when NTFS permissions are already restrictive enough.
- Group membership changes require a new logon session to take effect — `gpupdate /force` alone is not sufficient because Kerberos tickets are issued at logon.
- In production, use a ticketing/approval workflow before adding users to department security groups that grant access to sensitive file shares.

---

## Related

- `docs/kb/KB-005-file-share-permissions.md`
