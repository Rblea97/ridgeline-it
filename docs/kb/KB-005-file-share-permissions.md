# KB-005: Granting and Revoking File Share Access

**Category:** File Share / Permissions  
**Applies To:** All RTS file shares on DC01  
**Last Updated:** 2026-04-18

---

## Overview

RTS file shares are secured using Active Directory security groups. Access is granted or revoked by adding or removing users from the appropriate group — not by modifying share or NTFS permissions directly.

## Current File Shares

| Share | Path on DC01 | Access Group |
|-------|-------------|--------------|
| `Finance$` | `C:\Shares\Finance` | RIDGELINE\Finance Users |

## Granting Access

Run on **DC01 as Administrator**:

```powershell
# Add user to the share's security group
Add-ADGroupMember -Identity '<GroupName>' -Members '<SamAccountName>'

# Verify
Get-ADGroupMember '<GroupName>' | Select-Object Name, SamAccountName
```

**Example — grant atorres access to Finance$:**
```powershell
Add-ADGroupMember -Identity 'Finance Users' -Members 'atorres'
```

The user must **log off and log back on** for the group membership change to take effect (Kerberos tickets are issued at logon).

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

```powershell
# Create folder
New-Item -Path 'C:\Shares\<DeptName>' -ItemType Directory -Force

# Set NTFS permissions
$acl = Get-Acl 'C:\Shares\<DeptName>'
$acl.SetAccessRuleProtection($true, $false)
$rule = New-Object Security.AccessControl.FileSystemAccessRule('RIDGELINE\<Group>','Modify','ContainerInherit,ObjectInherit','None','Allow')
$adminRule = New-Object Security.AccessControl.FileSystemAccessRule('BUILTIN\Administrators','FullControl','ContainerInherit,ObjectInherit','None','Allow')
$acl.AddAccessRule($rule)
$acl.AddAccessRule($adminRule)
Set-Acl 'C:\Shares\<DeptName>' $acl

# Create SMB share (no -NoAccess to avoid Deny ACEs)
New-SmbShare -Name '<DeptName>$' -Path 'C:\Shares\<DeptName>' -FullAccess 'RIDGELINE\<Group>','BUILTIN\Administrators'
```

## Related

- `tickets/TICKET-008.md`
