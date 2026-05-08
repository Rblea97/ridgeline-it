# TICKET-001: Domain Controller Hostname Not Renamed

**Ticket ID:** TICKET-001
**Date:** 2026-04-18
**Technician:** Richard Blea
**Category:** Infrastructure / Configuration
**Priority:** P4 Low
**SLA:** Tier 4 — 24 hr response / 72 hr resolution
**Status:** Closed — Accepted As-Is

---

## Summary

The domain controller (DC01) was promoted while retaining its auto-generated Hyper-V hostname `WIN-DTBFF0R4BBQ` rather than the planned hostname `RTS-DC01`. Workstations WRK01 (`DESKTOP-4PL0V3F`) and WRK02 (`DESKTOP-BTK0BJ4`) also retain their default names. After assessing risk, the decision was made to accept the existing hostnames for this single-DC lab environment.

---

## Environment

| Field | Value |
|-------|-------|
| Domain Controller | DC01 — actual hostname `WIN-DTBFF0R4BBQ`, IP 192.168.1.10 |
| Planned Hostname | RTS-DC01 (not applied) |
| Domain | ridgeline.local |
| Workstation 1 | WRK01 — `DESKTOP-4PL0V3F`, IP 192.168.1.102, user atorres |
| Workstation 2 | WRK02 — `DESKTOP-BTK0BJ4`, IP 192.168.1.103, user jreyes |
| OS | Windows Server 2022 (DC01), Windows 11 Pro (WRK01/WRK02) |

---

## Root Cause

Hostname renaming was deferred during initial VM setup. Once a server is promoted to a domain controller, renaming carries significant risk:

- DNS SRV records (`_ldap._tcp.ridgeline.local`, `_kerberos._tcp.ridgeline.local`) are registered under the existing hostname. Renaming requires those records to be updated and replicated.
- Renaming post-promotion requires an `netdom computername` operation, metadata cleanup, and a reboot, and can cause Kerberos authentication failures in multi-DC environments during the transition window.
- In this single-DC lab the risk is lower, but the operational benefit is also minimal since all services function correctly under the current name.

---

## Resolution

**Decision: Accept existing hostnames.** All AD, DNS, and Intune functionality works correctly regardless of the display hostname. The asset register documents both the actual hostname and the logical role name.

The following commands were run on DC01 to verify that DNS, LDAP, and Kerberos records are correctly registered under the existing hostname before closing the ticket:

```powershell
# Verify DC registration in DNS
Resolve-DnsName -Name 'WIN-DTBFF0R4BBQ.ridgeline.local' -Type A

# Verify SRV records are registered
Resolve-DnsName -Name '_ldap._tcp.ridgeline.local' -Type SRV
Resolve-DnsName -Name '_kerberos._tcp.ridgeline.local' -Type SRV

# Confirm the DC is healthy and advertising correctly
dcdiag /test:Advertising /s:WIN-DTBFF0R4BBQ

# Confirm workstations can reach the DC
nltest /dsgetdc:ridgeline.local
```

All checks returned healthy results. No functional impact from the hostname mismatch was found.

**Best practice for production:** Rename servers *before* promoting to any role. Recommended sequence: install OS → rename → join domain (if applicable) → install roles.

---

## Lessons Learned

- Always rename servers immediately after OS installation, before any role or feature installation. Post-promotion renaming of a domain controller requires DNS and Kerberos record cleanup and carries availability risk.
- In production, server naming conventions (e.g., `RTS-DC01`, `RTS-WRK01`) should be enforced during VM provisioning via a build checklist, not left as a post-setup task.
- When accepting a known deviation from standards, document the verification steps that confirmed no functional impact — this distinguishes an informed decision from an oversight.
