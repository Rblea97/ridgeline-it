# LinkedIn Packaging & Post Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Professionally package the Ridgeline IT lab project and publish a LinkedIn post that signals hands-on IT experience to break into the field.

**Architecture:** Four sequential tasks — GitHub topics, LinkedIn Projects entry, LinkedIn post, LinkedIn Featured section. Each task is independent and can be verified before moving to the next.

**Tech Stack:** GitHub (repo topics), LinkedIn (Projects, Featured, post), screenshots already on disk at `ticketing/screenshots/` and `screenshots/`

---

## Task 1: Add GitHub Repository Topics

**Where:** https://github.com/Rblea97/ridgeline-it → About section (gear icon top-right of repo page)

- [ ] **Step 1: Open the repo settings panel**

  Navigate to https://github.com/Rblea97/ridgeline-it. On the right side of the page, click the gear icon next to "About."

- [ ] **Step 2: Add topics**

  In the "Topics" field, add each of the following one at a time:

  ```
  active-directory
  powershell
  microsoft-intune
  windows-server
  azure-ad
  help-desk
  home-lab
  it-support
  ```

- [ ] **Step 3: Save**

  Click "Save changes." The topics appear as blue tag bubbles below the repo description. Verify all 8 are visible.

---

## Task 2: Add LinkedIn Projects Entry

**Where:** LinkedIn profile → Add profile section → Recommended → Add projects

- [ ] **Step 1: Open the Add Projects form**

  Go to your LinkedIn profile. Click "Add profile section" → "Recommended" → "Add projects."

- [ ] **Step 2: Fill in the project fields**

  | Field | Value |
  |---|---|
  | Project name | Ridgeline Technology Services — IT Support Lab |
  | Start date | January 2026 |
  | End date | April 2026 (uncheck "I am currently working on this project") |
  | Project URL | https://github.com/Rblea97/ridgeline-it |

- [ ] **Step 3: Paste the description**

  Copy and paste the following exactly:

  ```
  Built and operated a simulated IT environment for a 20-person company
  end-to-end — on-premises Active Directory synced to Microsoft 365 via
  Entra ID, two Windows 11 workstations enrolled in Intune MDM, Group
  Policy enforcing password and workstation security policy, and a fully
  configured osTicket help desk. Resolved 8 support incidents documented
  to professional standard: triage, investigation, resolution, and lessons
  learned. Wrote 5 PowerShell automation scripts covering user provisioning,
  compliance reporting via Microsoft Graph, and password reset with audit
  logging. Produced 3 SOPs and 5 KB articles as a technical documentation
  library. Every component — user accounts, device management, cloud
  identity, file shares, and the help desk — was built from scratch to
  mirror what a technician manages at a small or mid-size company.
  ```

- [ ] **Step 4: Tag skills**

  In the Skills field, add:
  - Active Directory
  - Microsoft Intune
  - PowerShell
  - Windows Server
  - Microsoft Entra ID
  - IT Support

- [ ] **Step 5: Save and verify**

  Click Save. Visit your profile and confirm the project appears under the Projects section with the correct dates, URL, and description.

---

## Task 3: Publish the LinkedIn Post

**Where:** LinkedIn → Start a post

- [ ] **Step 1: Gather the three screenshots**

  Locate these files on disk:
  - `ticketing/screenshots/04-ticket-queue.png` — the ticket queue (8 closed tickets)
  - `ticketing/screenshots/05-ticket-004-detail.png` — TICKET-004 resolution detail
  - `screenshots/03-intune-devices.png` — both workstations enrolled in Intune

- [ ] **Step 2: Open a new LinkedIn post**

  Click "Start a post" on the LinkedIn home feed.

- [ ] **Step 3: Attach the screenshots first**

  Click the photo icon. Upload all three screenshots in this order:
  1. `04-ticket-queue.png`
  2. `05-ticket-004-detail.png`
  3. `03-intune-devices.png`

  Add alt text to each for accessibility:
  1. "osTicket help desk queue showing 8 resolved support tickets"
  2. "TICKET-004 detail view showing triage, investigation notes, and resolution"
  3. "Microsoft Intune showing both lab workstations enrolled in MDM"

- [ ] **Step 4: Paste the post text**

  Copy and paste the following into the post body. Do not change the line breaks — LinkedIn renders them as paragraph spacing.

  ---

  ```
  8 support tickets. 5 scripts. 3 VMs. 0 experience on my resume.

  I built the IT infrastructure a 20-person company runs on — from scratch,
  in a home lab. Active Directory, Microsoft Intune, Entra ID, Group Policy,
  PowerShell automation, and a fully configured help desk.

  One ticket stood out.

  A user got locked out after 5 failed login attempts. The instinct is to
  unlock the account and move on. But before touching anything, I pulled
  Event ID 4740 from the Windows Security log — the event that records which
  machine triggered the lockout and when.

  Five failed attempts from one workstation. Forgotten password, not a breach.

  Then I unlocked it, verified the fix, and closed the ticket within the SLA.

  That one step — checking the log before acting — is the difference between
  resolving an incident and accidentally clearing evidence of one.

  Here's what the lab runs:
  — Windows Server 2022 domain controller (AD DS, DNS, DHCP, Group Policy)
  — 2 Windows 11 workstations enrolled in Intune MDM
  — Entra ID sync via Azure AD Connect — same credentials on-prem and in M365
  — 5 PowerShell scripts: user provisioning, compliance reporting via Microsoft
    Graph, password reset with audit logging
  — osTicket help desk with SLA tiers, department routing, and a priority matrix
  — 8 tickets worked end-to-end. 3 SOPs. 5 KB articles.

  No employer gave me this environment. I built it because the work I want to
  do requires understanding the whole system — not just the tickets, but what's
  underneath them.

  Full lab on GitHub: https://github.com/Rblea97/ridgeline-it

  If you've built something similar, or you've hired someone who came in with
  lab experience — what made the difference for you?
  ```

  ---

- [ ] **Step 5: Review before posting**

  Read the post top to bottom once. Check:
  - Hook line is on its own line at the top
  - TICKET-004 story reads naturally (3 short paragraphs)
  - Proof block uses em-dashes (—), not hyphens
  - GitHub link is present at the bottom
  - CTA question is the last line

- [ ] **Step 6: Post**

  Click "Post." Do not schedule — post immediately for best early engagement signal.

- [ ] **Step 7: Comment on your own post within 5 minutes**

  Immediately after posting, add a first comment:

  ```
  If you want to see the ticket walkthroughs, SOPs, or PowerShell scripts
  in detail — everything is documented in the repo linked above.
  ```

  This gives LinkedIn's algorithm an early comment signal and gives readers a clear next step.

---

## Task 4: Set Up LinkedIn Featured Section

**Where:** LinkedIn profile → Add profile section → Recommended → Add featured

Do this immediately after the post goes live.

- [ ] **Step 1: Pin the post**

  Go to your profile. Click "Add profile section" → "Recommended" → "Featured."
  Select "Posts" and find the post you just published. Pin it.

- [ ] **Step 2: Add the GitHub link**

  In the same Featured section, click the + button → "Links."

  | Field | Value |
  |---|---|
  | URL | https://github.com/Rblea97/ridgeline-it |
  | Title | Ridgeline Technology Services — IT Support Lab |
  | Description | Simulated IT environment for a 20-person company — AD, Intune, Entra ID, PowerShell, and a fully configured help desk. |

- [ ] **Step 3: Order the items**

  Drag the GitHub link to appear first, the post second. The link gives a direct path to the repo without requiring someone to find the post first.

- [ ] **Step 4: Verify the full profile**

  Visit your profile as a logged-out user (or use LinkedIn's "View profile as" option). Confirm:
  - Featured section shows the GitHub link and the post
  - Projects section shows the Ridgeline entry with correct dates
  - Both link back to https://github.com/Rblea97/ridgeline-it

---

## Success Criteria

- [ ] GitHub repo has 8 topics visible on the repo page
- [ ] LinkedIn Projects entry live: Jan 2026 – Apr 2026, correct description, GitHub link, 6 skills tagged
- [ ] Post published with 3 screenshots attached in order
- [ ] Self-comment posted within 5 minutes of the post going live
- [ ] Featured section shows GitHub link (first) and post (second)
- [ ] Profile verified from a logged-out or "view as" perspective
