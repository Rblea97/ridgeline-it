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

| Device | Hostname | User | Compliance Status |
|--------|----------|------|-------------------|
| WRK01 | DESKTOP-4PL0V3F | atorres@<TENANT>.onmicrosoft.com | Noncompliant |
| WRK02 | DESKTOP-BTK0BJ4 | jreyes@<TENANT>.onmicrosoft.com | Noncompliant |

---

## Root Cause

Both workstations are Hyper-V Generation 1 virtual machines. BitLocker Drive Encryption requires a **Trusted Platform Module (TPM) chip** version 1.2 or higher. Hyper-V Generation 1 VMs do not expose a virtual TPM by default.

Without TPM, BitLocker cannot be enabled unless a startup key is stored on a USB drive — a configuration not practical for VMs in an automated lab environment.

This is a **known and expected** non-compliance scenario in virtualized lab environments. In a production deployment on physical hardware, BitLocker would be enforced and this ticket would require remediation.

---

## Impact

- Devices are flagged **Noncompliant** in Intune
- No conditional access policies are currently configured, so users are not blocked
- All other compliance settings pass (OS version, password requirements)

---

## Resolution

**Accepted risk for lab environment.** No remediation action taken.

In a production environment, the resolution would be one of the following:

1. **Physical hardware**: Enable BitLocker via GPO or Intune configuration profile with TPM enforced
2. **Hyper-V Gen 2 VMs**: Enable virtual TPM in VM settings → Security → Enable Trusted Platform Module, then enable BitLocker
3. **Compliance policy exception**: Create a grace period or exclusion group for devices pending BitLocker enablement

---

## Lessons Learned

When designing compliance policies for environments that include VMs, consider creating a separate compliance policy for virtual machines that excludes BitLocker, or use Intune filters to target policies to physical devices only.

---

## Related

- `docs/sops/device-enrollment.md`
- Intune Compliance Policy: RTS-Workstation-Compliance
