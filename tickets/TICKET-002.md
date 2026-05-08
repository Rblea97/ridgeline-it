# TICKET-002: Azure AD Cloud Sync Agent Blocked by Network

**Ticket ID:** TICKET-002
**Date:** 2026-04-18
**Technician:** Richard Blea
**Category:** Cloud Identity / Azure AD Sync
**Priority:** P2 High
**SLA:** Tier 2 — 4 hr response / 8 hr resolution
**Status:** Closed — Resolved by Switching to Azure AD Connect

---

## Summary

Microsoft Azure AD Cloud Sync agent was installed on DC01 as the initial sync method but could not establish a connection. The agent showed **Disconnected** in the Azure AD portal and could not be brought online despite multiple reinstall attempts. The issue was resolved by replacing Cloud Sync with Azure AD Connect (Entra Connect Sync).

---

## Triage / Priority Assessment

| Dimension | Assessment |
|---|---|
| Impact | High — sync infrastructure failure affects all 6 users' cloud identity |
| Urgency | Medium — on-prem authentication still works; cloud services blocked until sync restored |
| Calculated priority | P2 High |
| SLA tier | Tier 2 — 4 hr response / 8 hr resolution |

Reclassified from initial Medium label after applying the priority matrix objectively. See [`ticketing/docs/03-priority-matrix.md`](../ticketing/docs/03-priority-matrix.md) for the full matrix and the rationale behind reclassifications.

---

## Environment

| Field | Value |
|-------|-------|
| Server | DC01 — WIN-DTBFF0R4BBQ, IP 192.168.1.10 |
| OS | Windows Server 2022 |
| Domain | ridgeline.local |
| Failed Component | Azure AD Cloud Sync agent (Windows service: `AADConnectProvisioningAgent`) |
| Resolution Component | Azure AD Connect (Entra Connect Sync) |
| M365 Tenant | ridgelinets.onmicrosoft.com |
| Blocked Endpoint | `servicebus.windows.net:443` (outbound TCP) |

---

## Symptoms

- Cloud Sync agent installed and running as a Windows service on DC01
- Azure AD portal (Entra ID → Azure AD Connect) showed agent status: **Disconnected**
- Event Viewer on DC01 (Application log) showed repeated outbound connection failures to `servicebus.windows.net`
- Multiple reinstall attempts did not resolve the disconnected status

---

## Root Cause

Outbound HTTPS traffic to `servicebus.windows.net` (TCP 443) was blocked on the host network. Azure AD Cloud Sync uses Azure Service Bus as a relay for its agent-based communication model — unlike Azure AD Connect, which communicates directly with Azure AD endpoints (`login.microsoftonline.com`, `*.msappproxy.net`). Because the home lab network's firewall did not permit outbound connections to Service Bus, the Cloud Sync agent could never establish its relay tunnel and remained permanently disconnected.

---

## Resolution

### Step 1 — Confirm outbound connectivity failure on DC01

```powershell
# Test outbound HTTPS to the blocked endpoint
Test-NetConnection -ComputerName 'servicebus.windows.net' -Port 443

# View recent Cloud Sync agent errors in Event Viewer
Get-EventLog -LogName Application -Source 'AADConnectProvisioningAgent' -Newest 20 |
    Select-Object TimeGenerated, EntryType, Message
```

### Step 2 — Stop and disable the Cloud Sync agent

```powershell
Stop-Service -Name 'AADConnectProvisioningAgent'
Set-Service -Name 'AADConnectProvisioningAgent' -StartupType Disabled
Get-Service -Name 'AADConnectProvisioningAgent' | Select-Object Name, Status, StartType
```

### Step 3 — Install Azure AD Connect

1. Downloaded Azure AD Connect installer from: `https://www.microsoft.com/en-us/download/details.aspx?id=47594`
2. Ran installer on DC01 → selected **Express Settings**
3. Authenticated with M365 global admin account and `RIDGELINE\Administrator` domain credentials
4. Accepted default sync scope (all users in ridgeline.local)

### Step 4 — Verify sync completed

```powershell
# Trigger an immediate delta sync
Import-Module ADSync
Start-ADSyncSyncCycle -PolicyType Delta

# Check sync status
Get-ADSyncConnectorRunStatus
```

After the initial sync, all 6 users appeared in Azure AD (Entra ID) within 10 minutes. Password Hash Sync was confirmed enabled in the Azure AD Connect wizard.

---

## Outcome

All 6 RTS users synced to Azure AD with UPN suffix `@ridgelinets.onmicrosoft.com`. Azure AD Connect runs a scheduled delta sync every 30 minutes on DC01.

---

## Lessons Learned

- Azure AD Cloud Sync requires outbound access to `servicebus.windows.net:443`. Environments with strict outbound firewall rules (corporate proxy, home lab NAT) should use Azure AD Connect instead, which uses direct HTTPS to well-known Azure AD endpoints.
- Always run `Test-NetConnection` against required sync endpoints before installing an identity sync agent — a 2-minute connectivity check prevents hours of troubleshooting.
- Azure AD Connect and Cloud Sync cannot run simultaneously on the same tenant; disable one before enabling the other.

## Reference

- Required network endpoints for Azure AD Cloud Sync: `servicebus.windows.net`, `*.servicebus.windows.net`
- Required network endpoints for Azure AD Connect: `login.microsoftonline.com`, `*.msappproxy.net`, `*.aadsync.ms`
