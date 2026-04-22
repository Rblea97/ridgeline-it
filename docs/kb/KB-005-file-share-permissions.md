# KB-005: Granting and Revoking File Share Access

**Category:** File Share / Permissions  
**Applies To:** All RTS file shares on DC01  
**Last Updated:** 2026-04-22

---

## Symptoms

- User reports "Access is denied" or "You don't currently have permission to access this folder" when navigating to `\\WIN-DTBFF0R4BBQ\Finance$` or `\\WIN-DTBFF0R4BBQ\Operations$`
- User can reach the share path but cannot open, read, or write files
- A manager submits a ticket requesting that a specific user be granted or removed from a department file share

## Cause

RTS file shares are secured using Active Directory security groups mapped to NTFS and SMB permissions. A user who is not a member of the share's security group will be denied access at the SMB or NTFS layer. Access does not take effect immediately after a group membership change — the user must log off and log back on so that Windows issues a new Kerberos ticket that includes the updated group membership.

## Overview

RTS file shares are secured using Active Directory security groups. Access is granted or revoked by adding or removing users from the appropriate group — not by modifying share or NTFS permissions directly.

## Current File Shares

| Share | UNC Path | Path on DC01 | Access Group |
|-------|----------|-------------|--------------|
| `Finance$` | `\\WIN-DTBFF0R4BBQ\Finance$` | `C:\Shares\Finance` | RIDGELINE\Finance Users |
| `Operations$` | `\\WIN-DTBFF0R4BBQ\Operations$` | `C:\Shares\Operations` | RIDGELINE\Operations Users |

## Granting Access

Run on **DC01 as Administrator**:

```powershell
# Add user to the share's security group
Add-ADGroupMember -Identity '<GroupName>' -Members '<SamAccountName>'

# Verify group membership was updated
Get-ADGroupMember '<GroupName>' | Select-Object Name, SamAccountName
```

**Example — grant atorres access to Finance$:**
```powershell
Add-ADGroupMember -Identity 'Finance Users' -Members 'atorres'
```

The user must **log off and log back on** for the group membership change to take effect (Kerberos tickets are issued at logon).

## Verification

After granting or revoking access, confirm the change took effect:

```powershell
# Confirm user is (or is not) in the group
Get-ADGroupMember '<GroupName>' | Select-Object Name, SamAccountName
```

Then ask the user to log off and log back on, and confirm they can (or can no longer) access the share by navigating to the UNC path in File Explorer. The user should confirm access is restored (or denied) before the ticket is closed.

## Revoking Access

```powershell
Remove-ADGroupMember -Identity '<GroupName>' -Members '<SamAccountName>' -Confirm:$false
```

The user must log off and back on for access to be removed.

## Troubleshooting Access Denied

| Check | Command |
|-------|---------|
| Verify user is in the correct group | `Get-ADUser <sam> -Properties MemberOf \| Select-Object -ExpandProperty MemberOf` |
| Check SMB share permissions | `Get-SmbShareAccess -Name '<ShareName>'` |
| Check NTFS permissions | `(Get-Acl '<Path>').Access \| Select-Object IdentityReference, FileSystemRights, AccessControlType` |
| Clear Kerberos ticket cache | `klist purge` (run on workstation, then log off/on) |

**Important:** Deny ACEs always override Allow ACEs. If a Deny entry exists for Everyone or a group the user belongs to, it will block access even if an Allow entry also exists. Check for Deny entries in both SMB and NTFS permissions.

## Creating a New Share

The example below creates an `HR$` share secured by the `HR Users` AD group. Substitute the department name and group as needed.

```powershell
# Create folder
New-Item -Path 'C:\Shares\HR' -ItemType Directory -Force

# Set NTFS permissions
$acl = Get-Acl 'C:\Shares\HR'
$acl.SetAccessRuleProtection($true, $false)
$rule = New-Object Security.AccessControl.FileSystemAccessRule('RIDGELINE\HR Users','Modify','ContainerInherit,ObjectInherit','None','Allow')
$adminRule = New-Object Security.AccessControl.FileSystemAccessRule('BUILTIN\Administrators','FullControl','ContainerInherit,ObjectInherit','None','Allow')
$acl.AddAccessRule($rule)
$acl.AddAccessRule($adminRule)
Set-Acl 'C:\Shares\HR' $acl

# Create SMB share
New-SmbShare -Name 'HR$' -Path 'C:\Shares\HR' -FullAccess 'RIDGELINE\HR Users','BUILTIN\Administrators'
```

After creating the share, add it to the **Current File Shares** table above and update `tickets/` with the relevant ticket number.

## Related

- `tickets/TICKET-008.md`
