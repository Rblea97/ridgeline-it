# TICKET-003: BitLocker Compliance Flag on Lab Workstations

**Ticket ID:** TICKET-003
**Date:** 2026-04-18
**Reported by:** Intune Compliance Policy
**Assigned to:** Richard Blea (Lab Admin)
**Status:** Closed — Accepted Risk (Lab Environment)
**Priority:** Low
**Category:** Compliance / Device Management

---

## Summary

After enrolling WRK01 and WRK02 in Microsoft Intune, both devices immediately appeared as **Noncompliant** in the Intune compliance dashboard. The compliance policy **RTS-Workstation-Compliance** flagged BitLocker Drive Encryption as not enabled on either workstation.

---

## Environment

| Field | Value |
|-------|-------|
| Affected Device 1 | WRK01 — DESKTOP-4PL0V3F, IP 192.168.1.102 |
| Affected User 1 | atorres (Alex Torres) — atorres@ridgeline-it.onmicrosoft.com |
| Affected Device 2 | WRK02 — DESKTOP-BTK0BJ4, IP 192.168.1.103 |
| Affected User 2 | jreyes (Jose Reyes) — jreyes@ridgeline-it.onmicrosoft.com |
| OS | Windows 11 Pro |
| VM Type | Hyper-V Generation 1 (no virtual TPM) |
| Compliance Policy | RTS-Workstation-Compliance |
| Compliance Status | Noncompliant — BitLocker not enabled |

---

## Root Cause

Both workstations are Hyper-V Generation 1 virtual machines. BitLocker Drive Encryption requires a **Trusted Platform Module (TPM) chip** version 1.2 or higher. Hyper-V Generation 1 VMs do not expose a virtual TPM by default — only Generation 2 VMs support the virtual TPM feature through the VM firmware settings.

Without TPM, BitLocker cannot be enabled in the standard configuration. The only alternative — storing a startup key on a USB drive — is not practical for VMs in an automated lab environment.

This is a **known and expected** non-compliance scenario in virtualized lab environments. In a production deployment on physical hardware, BitLocker would be enforced and this ticket would require remediation.

---

## Impact

- Devices are flagged **Noncompliant** in Intune
- No conditional access policies are currently configured, so users are not blocked
- All other compliance settings pass (OS version, password requirements)

---

## Resolution

**Accepted risk for lab environment.** No remediation action taken.

The following PowerShell was run on DC01 to confirm TPM status on each workstation and document the accepted state:

```powershell
# Run on WRK01 or WRK02 to confirm no TPM is present
Get-Tpm

# Confirm BitLocker status on the OS drive
Get-BitLockerVolume -MountPoint C: | Select-Object MountPoint, VolumeStatus, ProtectionStatus
```

Both workstations returned `TpmPresent: False` from `Get-Tpm` and `ProtectionStatus: Off` from `Get-BitLockerVolume`.

In a production environment, the resolution would be one of the following:

1. **Physical hardware**: Enable BitLocker via GPO or Intune configuration profile with TPM enforced
2. **Hyper-V Gen 2 VMs**: Enable virtual TPM in VM settings → Security → **Enable Trusted Platform Module**, then enable BitLocker
3. **Compliance policy exception**: Create a grace period or exclusion group in Intune for devices pending BitLocker enablement

---

## Lessons Learned

- When designing Intune compliance policies for environments that include VMs, create a separate compliance policy (or use Intune filters) for virtual machines that excludes the BitLocker requirement — physical devices and VMs have fundamentally different hardware capabilities.
- Hyper-V Generation 2 VMs support a virtual TPM; Generation 1 VMs do not. Always provision lab VMs as Generation 2 when BitLocker or Secure Boot compliance is required.

---

## Related

- `docs/sops/device-enrollment.md`
- Intune Compliance Policy: RTS-Workstation-Compliance
