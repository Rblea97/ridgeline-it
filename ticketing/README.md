# Ridgeline Technology Services — Ticketing System

This directory contains a fully configured osTicket instance that mirrors the incident management workflow used in the Ridgeline home lab.

## How This Fits Into The Lab

This ticketing system is the operations-side counterpart to the rest of the lab. The 8 support incidents documented in [`../tickets/`](../tickets/) were intaken, triaged, and worked through this osTicket instance. The root [README](../README.md#the-service-desk) summarizes the service desk; this directory is the configuration and infrastructure detail.

## What's Here

| Path | Contents |
|------|----------|
| `docker-compose.yml` | osTicket + MySQL — spin up in one command |
| `.env.example` | Credentials template |
| `docs/01-departments.md` | Department configuration walkthrough |
| `docs/02-sla-tiers.md` | SLA tier configuration |
| `docs/03-priority-matrix.md` | Priority/Impact matrix reference |
| `docs/04-ticket-lifecycle.md` | End-to-end ticket lifecycle (TICKET-004) |

## Quick Start

```bash
# 1. Copy and fill in credentials
cp .env.example .env

# 2. Start containers
docker compose up -d

# 3. Open the staff panel
# http://localhost:8080/scp
```

First-time setup: if you see a setup wizard, complete it using the credentials from your `.env` file.

## Configuration Automation

The osTicket instance was configured programmatically by [`setup_osticket.py`](setup_osticket.py) — a Python script that logs in via the staff panel, handles CSRF tokens, and creates departments, SLAs, help topics, custom fields, and all 8 sample tickets. The screenshots in `screenshots/` were captured against the state this script produces.

To rebuild the instance from scratch:

```bash
# 1. Bring up the containers
cp .env.example .env  # then fill in real values
docker compose up -d

# 2. Install Python dependencies
python -m venv venv
source venv/bin/activate  # or `venv\Scripts\activate` on Windows
pip install -r requirements.txt

# 3. Set credentials and run the script
export OSTICKET_ADMIN_EMAIL="$ADMIN_EMAIL"
export OSTICKET_ADMIN_PASSWORD="$ADMIN_PASS"
python setup_osticket.py
```

The script is idempotent on re-run for departments and SLAs (skips existing) but ticket creation will produce duplicates if run twice.

## What's Configured

### Departments
- **IT Support** (Tier 1) — account lockouts, password resets, software installs, onboarding
- **Infrastructure** (Tier 2) — AD, DNS, Azure sync, Hyper-V
- **Security** (Tier 2) — compliance flags, ACL issues

### SLA Tiers
| Tier | Response | Resolution |
|------|----------|------------|
| Tier 1 Critical | 1 hr | 4 hr |
| Tier 2 High | 4 hr | 8 hr |
| Tier 3 Medium | 8 hr | 24 hr |
| Tier 4 Low | 24 hr | 72 hr |

### Tickets
All 8 incidents from the home lab are entered with full ITSM classification:

| ID | Subject | Priority | SLA |
|----|---------|----------|-----|
| 001 | DC Hostname Not Renamed | P4 Low | Tier 4 |
| 002 | Azure AD Sync Agent Down | P2 High | Tier 2 |
| 003 | BitLocker Compliance Flag | P4 Low | Tier 4 |
| 004 | Account Lockout — atorres | P2 High | Tier 2 |
| 005 | New Employee Onboarding — jchen | P3 Medium | Tier 3 |
| 006 | Notepad++ Deployment via Intune | P4 Low | Tier 4 |
| 007 | OneDrive Sync Error | P4 Low | Tier 4 |
| 008 | Finance$ Share Access Denied | P3 Medium | Tier 3 |

See `docs/03-priority-matrix.md` for how priorities were assigned.

## Sample Tickets Worked Through This System

All 8 ticket files: [`../tickets/`](../tickets/) (or see the [tickets index](../tickets/README.md) for a quick-reference table).

Three featured walkthroughs in the root README: account lockout, new employee onboarding, file share access denied. These are the most pedagogically rich examples of priority matrix application, account management, and Windows access control depth.
