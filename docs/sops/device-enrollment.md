# SOP: Intune Device Enrollment

**Organization:** Ridgeline Technology Services  
**Version:** 1.0  
**Last Updated:** 2026-04-18

---

## Purpose

This SOP documents the procedure for enrolling Windows 11 domain-joined workstations in Microsoft Intune MDM for centralized device management, policy deployment, and application delivery.

## Scope

Applies to all RTS workstations running Windows 11 Pro joined to the `ridgeline.local` Active Directory domain.

## Prerequisites

Before enrolling a device:

- [ ] Device is joined to the `ridgeline.local` domain
- [ ] Device has internet access (Default Switch NIC connected in Hyper-V)
- [ ] User account exists in Active Directory with UPN suffix `@<TENANT>.onmicrosoft.com`
- [ ] User account is synced to Azure AD via Azure AD Connect
- [ ] User has an M365 E5 license assigned in the Microsoft 365 admin center
- [ ] MDM user scope is set to **All** in Intune (Devices → Enrollment → Automatic Enrollment)
- [ ] DNS CNAME records exist on DC01 (see Infrastructure Notes below)

## Infrastructure Notes

The following DNS CNAME records must exist in the `ridgeline.local` DNS zone to enable MDM discovery for domain-joined devices:

| Record | Points To |
|--------|-----------|
| `EnterpriseEnrollment.ridgeline.local` | `EnterpriseEnrollment-s.manage.microsoft.com` |
| `EnterpriseRegistration.ridgeline.local` | `EnterpriseRegistration.windows.net` |

The following registry keys must be set on each workstation before enrollment:

```
HKLM\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\MDM
  AutoEnrollMDM = 1 (DWORD)
  UseAADCredentialType = 0 (DWORD)

HKLM\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\TenantInfo\<TENANT-ID>
  MdmEnrollmentUrl = https://enrollment.manage.microsoft.com/enrollmentserver/discovery.svc
  MdmTermsOfUseUrl = https://portal.manage.microsoft.com/TermsofUse.aspx
  MdmComplianceUrl = https://portal.manage.microsoft.com/?portalAction=Compliance
```

These can be applied via the following PowerShell (run as Administrator on each workstation):

```powershell
# Set MDM auto-enrollment policy
$mdmPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\MDM'
if (-not (Test-Path $mdmPath)) { New-Item -Path $mdmPath -Force | Out-Null }
Set-ItemProperty -Path $mdmPath -Name 'AutoEnrollMDM' -Value 1 -Type DWord
Set-ItemProperty -Path $mdmPath -Name 'UseAADCredentialType' -Value 0 -Type DWord

# Set Intune enrollment URLs
$tenantId = '<TENANT-ID>'
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\TenantInfo\$tenantId"
New-Item -Path $regPath -Force | Out-Null
Set-ItemProperty -Path $regPath -Name 'MdmEnrollmentUrl' -Value 'https://enrollment.manage.microsoft.com/enrollmentserver/discovery.svc'
Set-ItemProperty -Path $regPath -Name 'MdmTermsOfUseUrl' -Value 'https://portal.manage.microsoft.com/TermsofUse.aspx'
Set-ItemProperty -Path $regPath -Name 'MdmComplianceUrl' -Value 'https://portal.manage.microsoft.com/?portalAction=Compliance'
```

---

## Enrollment Procedure

### Step 1 — Verify user license

1. Sign in to **admin.microsoft.com** as `admin@<TENANT>.onmicrosoft.com`
2. Go to **Users → Active users → [username]**
3. Click the **Licenses and apps** tab
4. Confirm **Microsoft 365 E5 Developer SKU V2** is checked
5. If not, check it and click **Save changes**

### Step 2 — Add user to local Administrators (temporary)

On the domain controller, run:

```powershell
Add-LocalGroupMember -Group 'Administrators' -Member 'RIDGELINE\<username>' -ComputerName <hostname>
```

> **Note:** Local admin rights are required for MDM enrollment on domain-joined devices. Rights can be removed after enrollment if needed.

### Step 3 — Log in as the user on the workstation

Sign in to the workstation using the user's domain credentials:  
`RIDGELINE\<username>` / `<password>`

### Step 4 — Run the enrollment shortcut

1. Open the **Enroll-in-Intune** shortcut from the desktop, or run the following from the Start menu (Run dialog):
   ```
   ms-device-enrollment:?mode=mdm&username=<upn>@<TENANT>.onmicrosoft.com&servername=https://enrollment.manage.microsoft.com/enrollmentserver/discovery.svc
   ```
2. The **Set up a work or school account** dialog appears
3. Confirm the username is pre-filled and click **Next**
4. Enter the user's M365 password when prompted
5. Complete any additional prompts
6. On success, the dialog closes automatically

### Step 5 — Verify enrollment

Run the following on the workstation (as Administrator):

```powershell
$omadm = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts' -ErrorAction SilentlyContinue
if ($omadm) { Write-Host "Enrolled: $($omadm[0].PSChildName)" }
```

Or verify in **intune.microsoft.com → Devices → All devices** — the device should appear within 5 minutes.

---

## Post-Enrollment

After successful enrollment:

- Device will appear in Intune within ~5 minutes
- Compliance policy **RTS-Workstation-Compliance** will be evaluated (BitLocker non-compliance is expected on lab VMs — see TICKET-003)
- Configuration profile **RTS-Workstation-Config** will apply within ~15 minutes
- Assigned applications (e.g., 7-Zip) will install within ~30 minutes

---

## Troubleshooting

| Error | Meaning | Resolution |
|-------|---------|------------|
| "Your device is already connected to your organization" | Standard WPJ flow blocked by domain join | Use `ms-device-enrollment:` URI instead |
| 0x80180031 | MDM discovery fails / MDM scope = None | Set MDM user scope to All; add DNS CNAMEs |
| 0x80180018 | User lacks Intune license | Assign M365 license in admin.microsoft.com |
| "You don't have enough privileges" | User is not local admin | Add user to local Administrators group |

---

## Related Resources

- [Intune Admin Center](https://intune.microsoft.com)
- [M365 Admin Center](https://admin.microsoft.com)
- `docs/sops/software-deployment.md`
- `tickets/TICKET-003.md`
