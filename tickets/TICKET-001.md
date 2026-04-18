# TICKET-001: Domain Controller Hostname Not Renamed

**Date:** April 2026
**Technician:** Richard Blea
**Category:** Infrastructure / Configuration
**Priority:** Low
**Status:** Closed — accepted as-is

---

## Issue

The domain controller (DC01) was promoted while retaining its auto-generated Hyper-V hostname `WIN-DTBFF0R4BBQ` rather than the planned hostname `RTS-DC01`. Workstations WRK01 (`DESKTOP-4PL0V3F`) and WRK02 (`DESKTOP-BTK0BJ4`) also retain their default names.

## Root Cause

Hostname renaming was deferred during initial VM setup. Once a server is promoted to a domain controller, renaming carries risk:

- DNS SRV records (`_ldap._tcp.ridgeline.local`, `_kerberos._tcp.ridgeline.local`) are registered under the existing name
- Renaming post-promotion requires a metadata cleanup and reboot, and can cause Kerberos failures in multi-DC environments
- In this single-DC lab, the risk is lower but the operational benefit is also minimal

## Resolution

**Decision: Accept existing hostnames.** All AD, DNS, Azure AD Connect, and Intune functionality works correctly regardless of the display hostname. The asset register documents both the actual hostname and the logical role name.

**Best practice for production:** Rename servers *before* promoting to any role. Recommended sequence: install OS → rename → join domain (if applicable) → install roles.

## Lesson Learned

Always rename servers immediately after OS installation, before any role or feature installation. In production, server naming conventions (e.g., `RTS-DC01`, `RTS-WRK01`) should be enforced during VM provisioning via a build checklist.
