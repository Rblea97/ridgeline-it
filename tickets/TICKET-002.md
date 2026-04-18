# TICKET-002: Azure AD Cloud Sync Agent Blocked by Network

**Date:** April 2026
**Technician:** Richard Blea
**Category:** Cloud Identity / Azure AD Sync
**Priority:** Medium
**Status:** Closed — resolved by switching to Azure AD Connect

---

## Issue

Microsoft Azure AD Cloud Sync agent was installed on DC01 as the initial sync method but could not establish a connection. The agent showed **Disconnected** in the Azure AD portal and could not be brought online despite multiple reinstall attempts.

## Symptoms

- Cloud Sync agent installed and running as a Windows service on DC01
- Azure AD portal (Entra ID → Azure AD Connect) showed agent status: **Disconnected**
- Event Viewer on DC01 showed repeated outbound connection failures
- Target host: `servicebus.windows.net`

## Root Cause

Outbound HTTPS traffic to `servicebus.windows.net` (TCP 443) was blocked on the host network. Azure AD Cloud Sync uses Azure Service Bus as a relay for its agent-based communication model — unlike Azure AD Connect, which communicates directly with Azure AD endpoints (`login.microsoftonline.com`, `*.msappproxy.net`).

## Resolution

Installed **Azure AD Connect (Entra Connect Sync)** on DC01 as a replacement.

Steps taken:
1. Stopped and disabled the Cloud Sync agent Windows service on DC01
2. Downloaded Azure AD Connect from microsoft.com
3. Ran installer → Express Settings → authenticated with M365 admin account + RIDGELINE\Administrator
4. Initial sync completed successfully — all 6 users appeared in Azure AD within 10 minutes
5. Confirmed Password Hash Sync enabled

## Outcome

All 6 RTS users synced to Azure AD with UPN `@fx934y.onmicrosoft.com`. Azure AD Connect runs a scheduled delta sync every 30 minutes on DC01.

## Lesson Learned

Azure AD Cloud Sync requires outbound access to `servicebus.windows.net:443`. Environments with strict outbound firewall rules (corporate or home networks) should use Azure AD Connect instead. Check network requirements before choosing a sync method.

## Reference

- Required network endpoints for Azure AD Cloud Sync: `servicebus.windows.net`, `*.servicebus.windows.net`
- Required network endpoints for Azure AD Connect: `login.microsoftonline.com`, `*.msappproxy.net`, `*.aadsync.ms`
