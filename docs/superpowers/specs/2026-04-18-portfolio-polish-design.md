# Portfolio Polish Design — Ridgeline IT Home Lab

**Date:** 2026-04-18  
**Author:** Richard Blea  
**Goal:** Optimize the ridgeline-it GitHub repo as a hiring-manager-ready portfolio piece targeting Systems Administrator / IT Support roles with a cybersecurity growth path.

---

## Approach

Option B — Full Portfolio Optimization. No new features or scripts beyond the existing setup script. All changes are presentation, security hygiene, and keyword optimization.

---

## Section 1: README Overhaul

Restructure the README into a hiring-manager-first document. New order:

1. **Hero** — one bold sentence describing the lab + technology badges (Windows Server 2022, Microsoft Intune, Azure AD / Entra ID, PowerShell, Hyper-V)
2. **What This Demonstrates** — skills table with each skill mapped to concrete proof (link to script, ticket, or screenshot)
3. **Security Relevance** — new section mapping existing lab work to security concepts:
   - Least privilege: security groups + NTFS ACLs (TICKET-008)
   - Audit logging: password reset log (Reset-RTSUserPassword.ps1)
   - Compliance enforcement: Intune compliance policy (TICKET-003)
   - Identity lifecycle management: AD → Entra ID sync (TICKET-002)
   - GPO security baseline: password complexity + lockout policy (TICKET-004)
   - OAuth2 / Graph API: device code auth in Get-RTSComplianceReport.ps1
4. **Lab Architecture** — keep existing table, add inline Mermaid network diagram
5. **What Was Built** — keep, remove passive/internal-doc tone, write in active confident voice
6. **Scripts / SOPs / KB / Tickets** — keep as reference tables, add setup script entry
7. **Screenshots** — keep

---

## Section 2: Credential & Privacy Scrubbing

Replace all real identifiers with named placeholders across every file (scripts, SOPs, tickets, asset register, README):

| Real Value | Placeholder |
|---|---|
| `a9566324-fd0d-49ef-aa14-7ec036854bca` | `<TENANT-ID>` |
| `14d82eec-204b-4c2f-b7e8-296a70dab67e` | `<CLIENT-ID>` |
| `fx934y.onmicrosoft.com` | `<TENANT>.onmicrosoft.com` |
| `admin@fx934y.onmicrosoft.com` | `admin@<TENANT>.onmicrosoft.com` |
| `C:\Users\Richie\...` (local paths) | `<STAGING-PATH>\...` |
| `"...then return to Claude."` | `"...then install OSes on each VM."` |

Files to update: `scripts/Get-RTSComplianceReport.ps1`, `scripts/New-RTSUser.ps1`, `scripts/Invoke-RTSOnboarding.ps1`, `scripts/Reset-RTSUserPassword.ps1`, `scripts/setup/New-RTSLabVMs.ps1`, `docs/sops/device-enrollment.md`, `docs/sops/new-user-onboarding.md`, `docs/sops/software-deployment.md`, `docs/asset-register.md`, all 8 ticket files, `README.md`.

---

## Section 3: Setup Script

Include `scripts/setup/New-RTSLabVMs.ps1` in the repo with the following changes:

- Add a full `.SYNOPSIS` / `.DESCRIPTION` / `.PARAMETER` / `.EXAMPLE` / `.NOTES` header block matching the style of the other scripts
- Convert hardcoded `$ISOPath = "C:\Users\Richie\..."` to a `-ISOPath` parameter with a default of `"C:\ISOs"` and a `[Parameter()]` block
- Fix the "return to Claude" comment to `"Next: install OSes on each VM, then run the AD configuration scripts."`
- Add to README scripts table: *"Provisions Hyper-V virtual switch and 3 VMs (DC, WRK01, WRK02) with Gen 2, Secure Boot, and virtual TPM"*

---

## Section 4: Mermaid Network Diagram

Add an inline Mermaid `graph TD` diagram to the README Architecture section. Topology to represent:

- Hyper-V Host containing RTS-LAN internal switch
- DC01 (192.168.1.10) connected to RTS-LAN and Default Switch (internet)
- WRK01 (192.168.1.102) and WRK02 (192.168.1.103) on RTS-LAN only
- M365 tenant cloud box containing Entra ID, Intune, Exchange Online / OneDrive
- Arrow from DC01 → M365 (Azure AD Connect sync)

---

## Section 5: Housekeeping

- Rename branch `master` → `main`
- Add `*.iso` and `*.img` to `.gitignore`
- Stage and commit `scripts/setup/New-RTSLabVMs.ps1`

---

## Out of Scope

- No new scripts beyond the setup script already present
- No new tickets or KB articles
- No structural changes to folder layout
- No CI/CD or GitHub Actions

---

## Success Criteria

- A hiring manager can open the README and within 90 seconds understand: what was built, what skills it proves, and where to look for evidence
- No real tenant IDs, client IDs, or personal paths appear anywhere in the public repo
- The security relevance section creates a clear narrative for a cybersecurity growth path
- All 4 scripts share a consistent header/documentation style
- `main` is the default branch on GitHub
