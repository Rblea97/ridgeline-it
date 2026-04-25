# LinkedIn Packaging & Post Design
**Date:** 2026-04-25
**Project:** Ridgeline Technology Services — IT Support Lab
**Goal:** Professionally package the project and publish a LinkedIn post that signals hands-on IT experience to break into the field.

---

## Context

- **Target:** Entry-level IT — foot in the door, not role-specific
- **LinkedIn today:** Education + certifications only; this lab is the primary proof of hands-on experience
- **GitHub:** Public at https://github.com/Rblea97/ridgeline-it (already polished)
- **Constraint:** Signal depth and coherence — not "stretched too thin"

---

## Section 1: GitHub Repo Topics

Add the following repository topics to improve discoverability by recruiters and technical hiring managers browsing GitHub:

```
active-directory  powershell  microsoft-intune  windows-server
azure-ad  help-desk  home-lab  it-support
```

**Where:** GitHub repo → About (gear icon) → Topics

---

## Section 2: LinkedIn Projects Section

**Title:** Ridgeline Technology Services — IT Support Lab
**Dates:** Jan 2026 – Apr 2026
**URL:** https://github.com/Rblea97/ridgeline-it
**Skills to tag:** Active Directory, Microsoft Intune, PowerShell, Windows Server, Microsoft Entra ID, IT Support

**Description:**
> Built and operated a simulated IT environment for a 20-person company end-to-end — on-premises Active Directory synced to Microsoft 365 via Entra ID, two Windows 11 workstations enrolled in Intune MDM, Group Policy enforcing password and workstation security policy, and a fully configured osTicket help desk. Resolved 8 support incidents documented to professional standard: triage, investigation, resolution, and lessons learned. Wrote 5 PowerShell automation scripts covering user provisioning, compliance reporting via Microsoft Graph, and password reset with audit logging. Produced 3 SOPs and 5 KB articles as a technical documentation library. Every component — user accounts, device management, cloud identity, file shares, and the help desk — was built from scratch to mirror what a technician manages at a small or mid-size company.

---

## Section 3: LinkedIn Featured Section

After the post goes live, pin two items:

1. **The LinkedIn post** — pin immediately after publishing
2. **Manual link** — Title: "Ridgeline Technology Services — IT Support Lab" / Description: "Simulated IT environment for a 20-person company — AD, Intune, Entra ID, PowerShell, and a fully configured help desk." / URL: https://github.com/Rblea97/ridgeline-it

**Why:** Featured section sits directly below the About section — first thing a recruiter sees before scrolling. Both items reinforce each other.

---

## Section 4: LinkedIn Post

### Format
- Text post with 3 screenshots attached
- Target length: ~350 words
- Post the screenshots in order: ticket queue → TICKET-004 detail → Intune devices

### Screenshots
| Order | File | Purpose |
|---|---|---|
| 1 | `ticketing/screenshots/04-ticket-queue.png` | Proves a real queue was worked (8 closed tickets) |
| 2 | `ticketing/screenshots/05-ticket-004-detail.png` | Proves depth — real ticket with triage, investigation, resolution |
| 3 | `screenshots/03-intune-devices.png` | Proves infrastructure scope beyond just ticketing |

### Hook
```
8 support tickets. 5 scripts. 3 VMs. 0 experience on my resume.
```

### Post Structure

1. **Hook** — the line above
2. **Setup** — one sentence: what the lab is and why it exists
3. **Story beat: TICKET-004** — account lockout incident; the key detail is checking Event ID 4740 to rule out unauthorized access *before* unlocking — shows professional thinking, not just tool usage
4. **Proof block** — short list of what was built: AD, Intune, Entra ID, Group Policy, PowerShell automation, osTicket help desk with SLAs, SOPs, KB articles
5. **Honest anchor line** — acknowledges no employer gave this experience; built it independently
6. **CTA** — question directed at the audience to drive comments

### Tone
- Direct and factual, not apologetic about being a lab
- Let the proof speak; avoid over-explaining
- One personal/honest line is fine — it's relatable and drives engagement

---

## Success Criteria

- [ ] GitHub topics added
- [ ] LinkedIn Projects entry live with correct dates, description, skills, and link
- [ ] LinkedIn post published with 3 screenshots attached
- [ ] Post pinned to Featured section
- [ ] GitHub repo link added to Featured section
