# README Revamp Design — Ridgeline IT Lab

**Date:** 2026-04-24
**Author:** Richard Blea
**Goal:** Revamp the root README.md to serve as a recruiter-facing IT portfolio piece, optimized for entry-level IT job applications (help desk, sysadmin, IT support). Accessible to non-technical hiring managers. Replaces formal work experience with documented hands-on lab evidence.

---

## Context

The repo already contains strong content: 8 resolved tickets, 5 KB articles, 3 SOPs, 5 PowerShell scripts, a working osTicket system, and screenshots of every major system. The current README organizes this content for a technical reader. The revamp reorders and reframes it for a recruiter or hiring manager who may have zero technical background.

**Audience:** Non-technical hiring managers and recruiters at companies hiring for Help Desk, IT Support, Sysadmin, and IT Operations roles.

**Candidate profile:** Richard Blea — B.S. Computer Science + Cybersecurity & Defense Certificate, University of Colorado Denver. No formal IT work history; this lab is the proof of skills.

**Constraint:** Do not signal cybersecurity career pivot or flight risk. Frame all work as practical IT competency, not a stepping stone.

---

## File Being Modified

`/home/richardb/repos/ridgeline-it/README.md` — full rewrite.

The `ticketing/README.md` is a sub-page; it stays as-is. The new TICKET-004 featured section in the root README links into it and uses its screenshots.

---

## Approved Section Structure

### 1. Header
- Title: `Ridgeline Technology Services — IT Support Lab`
- One-line pitch (plain English, no jargon)
- LinkedIn badge linking to `https://www.linkedin.com/in/richard-blea-748914159`
- GitHub badge linking to `https://github.com/Rblea97`
- Credentials line: *B.S. Computer Science · Cybersecurity & Defense Certificate — University of Colorado Denver*
- Existing tech stack badges (Windows Server, Intune, Entra ID, PowerShell, Hyper-V) kept

### 2. Skills Demonstrated
- Keep the existing two-column table (Skill | Proof)
- Add plain-English parentheticals after jargon terms so non-technical readers understand what each skill means
- Examples: "Active Directory (the system companies use to manage employee logins and computer access)", "SLA (response time commitments)", "MDM (mobile device management — controlling company devices remotely)"
- Keep all proof links intact

### 3. Hero Screenshots
- Move 2-3 of the strongest screenshots immediately after Skills
- Best candidates: `screenshots/01-aduc-ous.png` (AD structure), `screenshots/03-intune-devices.png` (device management), `ticketing/screenshots/04-ticket-queue.png` (ticket queue showing 8 real incidents)
- Each gets a plain-English caption explaining what the reader is looking at

### 4. What This Is (Intro Paragraph)
- Rewritten version of the existing intro paragraph
- Remove "Graduating: May 2026" — replace with credentials line in header instead
- Frame as: a simulated IT environment for a 20-person company, built and operated end-to-end
- No student language, no "learning" language — present tense, professional framing
- Keep the scope sentence: on-premises + cloud, AD + Intune + Entra ID + PowerShell

### 5. Lab Architecture
- Keep the Mermaid diagram exactly as-is (it's clear and professional)
- Keep the asset table (DC01, WRK01, WRK02) exactly as-is
- Add a one-sentence plain-English explanation above the diagram for non-technical readers

### 6. What Was Built
- Keep the existing numbered list exactly as-is — it's already well-written
- Minor jargon additions: parentheticals on "Password Hash Sync", "Win32 App Deployment", "OU"

### 7. Featured Incident: TICKET-004 — Account Lockout
- New section not in the current README
- Plain-English narrative of the full ticket lifecycle: submission → triage → investigation → resolution → closure
- Embed `ticketing/screenshots/05-ticket-004-detail.png` inline
- Embed `ticketing/screenshots/04-ticket-queue.png` if not already used above
- Show the PowerShell commands used (already documented in ticketing/docs/04-ticket-lifecycle.md)
- Show the Lessons Learned capture
- Frame this as: "here is what working a real help desk ticket looks like, documented to professional standard"
- Plain-English explanation of every step — no assumed knowledge

### 8. Scripts
- Keep the existing scripts table exactly as-is
- Add one plain-English sentence above the table explaining what automation scripts are and why they matter in IT

### 9. Documentation
- Keep the existing three sub-sections: SOPs, Knowledge Base, Support Tickets
- Add one-line plain-English descriptions to any items that currently only have filenames
- The support tickets table already has good descriptions — keep as-is

### 10. All Screenshots
- Distribute screenshots inline throughout relevant sections rather than dumping at the bottom
- Identity/Access screenshots go near the Lab Architecture section
- Device Management screenshots go near the What Was Built section (Intune items)
- Infrastructure screenshots go near the What Was Built section (GPO/DHCP items)
- Ticketing screenshots go in the Featured Incident section
- Remove the standalone "Screenshots" section heading — screenshots become part of the narrative

### Removed Sections
- **"What's Next"** — removed entirely. Signals incomplete work.
- **"Security Relevance"** — removed as a standalone section. The security practices (least privilege, audit logging, compliance enforcement, ACL troubleshooting) are folded into the Skills Demonstrated table and the What Was Built list as plain skills, not flagged as a career direction.

---

## Key Decisions

| Decision | Rationale |
|---|---|
| LinkedIn + GitHub at top | Recruiters act on interest when contact is one click away |
| Screenshots moved up | Visual proof is the fastest way to make the project real to a non-technical reader |
| No "What's Next" | Unfinished sections undermine the "proof of competence" framing |
| No explicit cybersecurity pivot language | Avoids flight risk signal — security practices are framed as good IT hygiene |
| TICKET-004 featured in root README | The documented incident lifecycle is the strongest proof of process; it was buried in a subdirectory |
| Jargon parentheticals | Non-technical hiring managers need to understand what they're reading without Googling |
| Credentials in header, not intro paragraph | CU Denver + certificate signals academic rigor immediately without leading with "student" framing |

---

## Files Touched

| File | Change |
|---|---|
| `README.md` | Full rewrite per this spec |
| `docs/superpowers/specs/2026-04-24-readme-revamp-design.md` | This file |

No other files are modified. The ticketing subdirectory, scripts, and docs are referenced but not changed.

---

## Success Criteria

- A non-technical hiring manager can read the README and understand what skills Richard demonstrated without prior IT knowledge
- LinkedIn and GitHub links are visible without scrolling
- At least 3 screenshots appear in the first half of the README
- The TICKET-004 walkthrough is present and readable as a plain-English story
- No "What's Next", no "Security Relevance" section heading, no "graduating" student language
- All existing proof links (scripts, tickets, SOPs, KB articles) are preserved
