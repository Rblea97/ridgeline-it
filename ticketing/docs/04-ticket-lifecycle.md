# Ticket Lifecycle Walkthrough — TICKET-004

This document walks through the complete lifecycle of TICKET-004 (Account Lockout — atorres) as it moves through the osTicket system from submission to closure.

TICKET-004 is used because it represents the most common Tier 1 help desk scenario and clearly demonstrates every stage of the workflow.

---

## Stage 1: Submission

**User submits ticket via the client portal.**

Alex Torres navigates to the IT Support portal and submits:

- **Help Topic:** Account Management
- **Subject:** Locked out — cannot log in to WRK01
- **Message:** "I've been locked out of my account. I tried logging in several times and now I just get a lockout message."

osTicket routes the ticket to the **IT Support** department based on the Account Management help topic.

---

## Stage 2: Triage

**Technician opens ticket, assesses impact and urgency, sets priority.**

![Ticket 004 detail](../screenshots/ticket-004-detail.png)

Triage assessment:
- **Impact:** Medium — single user affected
- **Urgency:** High — user cannot log in at all, no workaround
- **Matrix result:** P2 High → **Tier 2 SLA (4hr response, 8hr resolution clock starts)**

The technician sets Priority to **High** and SLA to **Tier 2 — High** at this stage, overriding the department default of Tier 3.

---

## Stage 3: Investigation

**Technician records investigation steps as an internal note.**

```powershell
# Confirm account is locked
Search-ADAccount -LockedOut | Select-Object Name, SamAccountName, LockedOut
```

Output confirms: `atorres — LockedOut: True`

Root cause identified: 5 failed logon attempts triggered the RTS-Password-Policy GPO lockout threshold. No unauthorized access indicators — this is a forgotten password event, not a brute-force attempt.

---

## Stage 4: Resolution

**Technician resolves the issue and records the fix.**

![Ticket 004 resolution](../screenshots/ticket-004-resolution.png)

```powershell
# Unlock the account
Unlock-ADAccount -Identity atorres

# Verify unlock
Get-ADUser atorres -Properties LockedOut | Select-Object Name, LockedOut
```

Output: `LockedOut: False` — account unlocked. User notified and confirmed successful login.

---

## Stage 5: Closure

**Ticket closed with lessons learned captured.**

| Field | Value |
|-------|-------|
| Status | Closed — Resolved |
| Resolution time | Under 8hr SLA window |
| Lessons Learned | Investigate lockout events to rule out unauthorized access (check Event ID 4740). Consider SSPR via Azure AD to reduce admin overhead for routine lockouts. |

SLA compliance: **Met** (Tier 2 — High, 8hr resolution window).

---

## Key Concepts Demonstrated

- **Help topic → department routing** — Account Management automatically routes to IT Support
- **Triage overrides default SLA** — technician escalates from Tier 3 to Tier 2 based on urgency
- **Internal notes** — investigation steps recorded without emailing the user
- **SLA tracking** — resolution time measured against the 8hr window
- **Lessons learned capture** — generalizable takeaway recorded for future incidents
