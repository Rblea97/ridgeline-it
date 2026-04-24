# Priority / Impact Matrix

Every ticket is classified by two dimensions — **Impact** (how many users or systems are affected) and **Urgency** (how time-sensitive the issue is). The intersection produces the priority level.

## Matrix

|  | High Urgency | Med Urgency | Low Urgency |
|--|---|---|---|
| **High Impact** | P1 Critical | P2 High | P3 Medium |
| **Med Impact** | P2 High | P3 Medium | P4 Low |
| **Low Impact** | P3 Medium | P4 Low | P4 Low |

## Definitions

**Impact:**
- **High** — Multiple users or a shared service affected (e.g., Azure AD sync broken for all 6 users)
- **Med** — Single user completely blocked from working
- **Low** — Single user affected with a known workaround, or cosmetic/advisory issue

**Urgency:**
- **High** — No workaround; user or system cannot function
- **Med** — User can partially work or a workaround exists
- **Low** — Issue can wait; no immediate work impact

## Tickets in This Portfolio

| ID | Subject | Impact | Urgency | Priority |
|----|---------|--------|---------|----------|
| 001 | DC Hostname Not Renamed | Low | Low | P4 Low |
| 002 | Azure AD Sync Agent Down | High | Med | **P2 High** |
| 003 | BitLocker Compliance Flag | Low | Low | P4 Low |
| 004 | Account Lockout — atorres | Med | High | **P2 High** |
| 005 | New Employee Onboarding — jchen | Med | Med | P3 Medium |
| 006 | Notepad++ Deployment | Low | Low | P4 Low |
| 007 | OneDrive Sync Error | Low | Low | P4 Low |
| 008 | Finance$ Share Access Denied | Med | Med | P3 Medium |

## Reclassifications

TICKET-002 and TICKET-004 were originally labeled **Medium** in the markdown documentation. Applying the matrix objectively reveals both warrant **P2 High**:

- **TICKET-002:** Azure AD sync failure affects all 6 users' cloud identity — High Impact.
- **TICKET-004:** User is completely unable to log in — High Urgency.

This demonstrates why a matrix matters: subjective labeling underestimates severity. In a production environment, a misclassified P2 ticket sitting in a low-priority queue could violate an SLA.
