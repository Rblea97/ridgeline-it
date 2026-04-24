# Department Configuration

Ridgeline IT Support uses three departments matching a standard enterprise IT org structure.

![Department list](../screenshots/departments-list.png)

## Departments

| Department | Tier | Scope |
|------------|------|-------|
| IT Support | Tier 1 | Account lockouts, password resets, software installs, onboarding |
| Infrastructure | Tier 2 | AD, DNS, DHCP, Azure sync, Hyper-V, server configuration |
| Security | Tier 2 | Compliance flags, ACL issues, access reviews |

## Why Three Departments?

Separating tickets by operational domain enables:

- **Correct SLA assignment** — Infrastructure tickets default to Tier 2 (High) because identity or server issues affect multiple users
- **Skill-based routing** — Tier 1 issues don't consume Tier 2 engineer time
- **Reporting by category** — ticket volume per department shows where the lab generated the most incidents

## Default SLA by Department

| Department | Default SLA | Rationale |
|------------|-------------|-----------|
| IT Support | Tier 3 — Medium | Most issues affect one user with a workaround |
| Infrastructure | Tier 2 — High | Server/identity issues affect multiple users |
| Security | Tier 2 — High | Compliance failures need fast resolution |
