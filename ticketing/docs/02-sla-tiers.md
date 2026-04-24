# SLA Tier Configuration

Four SLA tiers based on a standard enterprise ITSM model. Each tier defines the maximum time to first response and to resolution.

![SLA tiers](../screenshots/sla-tiers.png)

## Tiers

| Tier | Name | Response | Resolution | Schedule |
|------|------|----------|------------|----------|
| 1 | Critical | 1 hr | 4 hr | 24/7 |
| 2 | High | 4 hr | 8 hr | 24/7 |
| 3 | Medium | 8 hr | 24 hr | Mon–Fri 8am–5pm |
| 4 | Low | 24 hr | 72 hr | Mon–Fri 8am–5pm |

## How SLA Tier Is Assigned

SLA tier is determined by the Priority/Impact Matrix (see `03-priority-matrix.md`):

- P1 Critical → Tier 1
- P2 High → Tier 2
- P3 Medium → Tier 3
- P4 Low → Tier 4

The ticket's Help Topic determines the department, and the department's default SLA applies unless the technician overrides it based on the impact/urgency assessment at triage.

## Why Not Just One SLA?

A single SLA treats a Notepad++ install request the same as a user locked out of their account. Tiered SLAs ensure technician time goes to highest-impact work first, and that low-priority requests don't artificially inflate SLA compliance numbers.
