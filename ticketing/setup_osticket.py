#!/usr/bin/env python3
"""
osTicket ITSM configuration and ticket population script.
Logs in as admin and configures departments, SLAs, help topics, and creates all 8 tickets.
"""

import os
import requests
import sys
from bs4 import BeautifulSoup

BASE = os.getenv("OSTICKET_BASE_URL", "http://localhost:8080")
EMAIL = os.getenv("OSTICKET_ADMIN_EMAIL")
PASSWORD = os.getenv("OSTICKET_ADMIN_PASSWORD")

if not EMAIL or not PASSWORD:
    sys.exit(
        "Error: set OSTICKET_ADMIN_EMAIL and OSTICKET_ADMIN_PASSWORD "
        "environment variables before running. See ticketing/.env.example."
    )

s = requests.Session()
s.headers["User-Agent"] = "Mozilla/5.0"


def csrf(url):
    """GET a page and return its CSRF token."""
    r = s.get(url)
    soup = BeautifulSoup(r.text, "html.parser")
    tok = soup.find("input", {"name": "__CSRFToken__"})
    if not tok:
        print(f"  WARN: no CSRF token on {url}")
        return ""
    return tok["value"]


def login():
    print("Logging in...")
    token = csrf(f"{BASE}/scp/login.php")
    r = s.post(f"{BASE}/scp/login.php", data={
        "__CSRFToken__": token,
        "do": "scplogin",
        "userid": EMAIL,
        "passwd": PASSWORD,
        "submit": "Log In",
    }, allow_redirects=True)
    if "logout" in r.text.lower() or "dashboard" in r.text.lower() or "open tickets" in r.text.lower():
        print("  ✓ Logged in")
        return True
    # Check if we're on the staff panel
    if r.url and "/scp/" in r.url and "login" not in r.url:
        print("  ✓ Logged in (redirected to staff panel)")
        return True
    print(f"  ✗ Login may have failed — URL: {r.url}")
    return False


def create_department(name):
    print(f"  Creating department: {name}")
    token = csrf(f"{BASE}/scp/departments.php?a=add")
    r = s.post(f"{BASE}/scp/departments.php", data={
        "__CSRFToken__": token,
        "a": "add",
        "name": name,
        "ispublic": "1",
        "email_id": "0",
        "tpl_id": "0",
        "manager_id": "0",
        "signature": "",
        "autoresp_email_id": "0",
        "submit": "Create Dept",
    })
    if name.lower() in r.text.lower() or r.status_code == 200:
        print(f"    ✓ {name}")
        return True
    print(f"    ✗ Failed ({r.status_code})")
    return False


def create_sla(name, grace_period, schedule_id=2):
    """
    schedule_id: 1 = Mon-Fri 8am-5pm, 2 = 24/7, 3 = 24/5
    """
    print(f"  Creating SLA: {name} ({grace_period}h)")
    token = csrf(f"{BASE}/scp/slas.php?a=add")
    r = s.post(f"{BASE}/scp/slas.php", data={
        "__CSRFToken__": token,
        "do": "add",
        "a": "add",
        "name": name,
        "isactive": "1",
        "grace_period": str(grace_period),
        "schedule_id": str(schedule_id),
        "transient": "0",
        "disable_overdue_alerts": "0",
        "notes": "",
        "submit": "Add Plan",
    })
    if name.lower() in r.text.lower() or r.status_code == 200:
        print(f"    ✓ {name}")
        return True
    print(f"    ✗ Failed ({r.status_code})")
    return False


def create_help_topic(name, priority_id=2):
    """
    priority_id: 1=Low, 2=Normal, 3=High, 4=Critical
    """
    print(f"  Creating help topic: {name}")
    token = csrf(f"{BASE}/scp/helptopics.php?a=add")
    r = s.post(f"{BASE}/scp/helptopics.php", data={
        "__CSRFToken__": token,
        "a": "add",
        "isactive": "1",
        "ispublic": "1",
        "topic": name,
        "priority_id": str(priority_id),
        "dept_id": "0",
        "submit": "Add Topic",
    })
    if name.lower() in r.text.lower() or r.status_code == 200:
        print(f"    ✓ {name}")
        return True
    print(f"    ✗ Failed ({r.status_code})")
    return False


def get_ticket_form_id():
    """Get the form ID for Ticket Details form."""
    r = s.get(f"{BASE}/scp/forms.php")
    soup = BeautifulSoup(r.text, "html.parser")
    for link in soup.find_all("a", href=True):
        if "forms.php" in link["href"] and "id=" in link["href"] and "Ticket" in link.text:
            fid = link["href"].split("id=")[-1].split("&")[0]
            return fid
    # fallback: try id=1
    return "1"


def add_custom_field(form_id, label, var_name):
    print(f"  Adding custom field: {label}")
    token = csrf(f"{BASE}/scp/forms.php?id={form_id}")
    r = s.post(f"{BASE}/scp/forms.php?id={form_id}", data={
        "__CSRFToken__": token,
        "a": "add-field",
        "id": form_id,
        "label": label,
        "type": "text",
        "name": var_name,
        "required": "1",
        "private": "0",
        "edit_mask": "15",
        "submit": "Save Changes",
    })
    if label.lower() in r.text.lower() or r.status_code == 200:
        print(f"    ✓ {label}")
        return True
    print(f"    ✗ Failed ({r.status_code})")
    return False


def get_dept_id(name):
    r = s.get(f"{BASE}/scp/departments.php")
    soup = BeautifulSoup(r.text, "html.parser")
    for row in soup.find_all("tr"):
        cells = row.find_all("td")
        for cell in cells:
            if cell.get_text(strip=True).lower() == name.lower():
                link = row.find("a", href=True)
                if link and "id=" in link["href"]:
                    return link["href"].split("id=")[-1].split("&")[0]
    return "0"


def get_sla_id(name):
    r = s.get(f"{BASE}/scp/slas.php")
    soup = BeautifulSoup(r.text, "html.parser")
    for row in soup.find_all("tr"):
        cells = row.find_all("td")
        for cell in cells:
            if cell.get_text(strip=True).lower() == name.lower():
                link = row.find("a", href=True)
                if link and "id=" in link["href"]:
                    return link["href"].split("id=")[-1].split("&")[0]
    return "0"


def get_topic_id(name):
    r = s.get(f"{BASE}/scp/helptopics.php")
    soup = BeautifulSoup(r.text, "html.parser")
    for row in soup.find_all("tr"):
        for cell in row.find_all("td"):
            if name.lower() in cell.get_text(strip=True).lower():
                link = row.find("a", href=True)
                if link and "id=" in link["href"]:
                    return link["href"].split("id=")[-1].split("&")[0]
    return "0"


def create_ticket(subject, dept_id, sla_id, priority_id, topic_id,
                  issue_summary, environment, root_cause, resolution_steps, lessons_learned):
    print(f"  Creating ticket: {subject[:60]}...")
    token = csrf(f"{BASE}/scp/tickets.php?a=open")
    data = {
        "__CSRFToken__": token,
        "a": "open",
        "dept_id": dept_id,
        "sla_id": sla_id,
        "priority_id": str(priority_id),
        "topic_id": topic_id,
        "subject": subject,
        "message": issue_summary,
        "note": "",
        "status": "3",  # 3 = closed
        "source": "Web",
        "submit": "Open Ticket",
    }
    r = s.post(f"{BASE}/scp/tickets.php", data=data)
    if r.status_code in (200, 302):
        print(f"    ✓ Created")
        return True
    print(f"    ✗ Failed ({r.status_code})")
    return False


# ── MAIN ──────────────────────────────────────────────────────────────────────

if not login():
    sys.exit(1)

# Departments
print("\n── Departments ──")
for dept in ["IT Support", "Infrastructure", "Security"]:
    create_department(dept)

# SLA Tiers (schedule_id 2=24/7, 1=Mon-Fri 8am-5pm)
print("\n── SLA Tiers ──")
create_sla("Tier 1 — Critical", 4,  schedule_id=2)
create_sla("Tier 2 — High",     8,  schedule_id=2)
create_sla("Tier 3 — Medium",  24,  schedule_id=1)
create_sla("Tier 4 — Low",     72,  schedule_id=1)

# Help Topics (priority_id: 1=Low, 2=Normal, 3=High, 4=Critical)
print("\n── Help Topics ──")
create_help_topic("Account Management",          priority_id=2)
create_help_topic("Password Reset",              priority_id=2)
create_help_topic("New Employee Onboarding",     priority_id=2)
create_help_topic("Device Enrollment",           priority_id=2)
create_help_topic("Software Deployment",         priority_id=1)
create_help_topic("File Share Permissions",      priority_id=2)
create_help_topic("Cloud Identity / Azure Sync", priority_id=3)
create_help_topic("Device Compliance",           priority_id=2)
create_help_topic("Cloud Services / OneDrive",   priority_id=1)

# Custom fields
print("\n── Custom Fields ──")
form_id = get_ticket_form_id()
print(f"  Ticket Details form ID: {form_id}")
add_custom_field(form_id, "Environment",       "environment")
add_custom_field(form_id, "Root Cause",        "root_cause")
add_custom_field(form_id, "Resolution Steps",  "resolution_steps")
add_custom_field(form_id, "Lessons Learned",   "lessons_learned")

# Resolve IDs for ticket creation
print("\n── Resolving IDs ──")
it_support_id   = get_dept_id("IT Support")
infra_id        = get_dept_id("Infrastructure")
security_id     = get_dept_id("Security")
tier2_id        = get_sla_id("Tier 2 — High")
tier3_id        = get_sla_id("Tier 3 — Medium")
tier4_id        = get_sla_id("Tier 4 — Low")
acct_mgmt_id    = get_topic_id("Account Management")
onboarding_id   = get_topic_id("New Employee Onboarding")
software_id     = get_topic_id("Software Deployment")
onedrive_id     = get_topic_id("Cloud Services / OneDrive")
fileshare_id    = get_topic_id("File Share Permissions")

print(f"  IT Support dept ID : {it_support_id}")
print(f"  Infrastructure ID  : {infra_id}")
print(f"  Security ID        : {security_id}")
print(f"  Tier 2 SLA ID      : {tier2_id}")
print(f"  Tier 3 SLA ID      : {tier3_id}")
print(f"  Tier 4 SLA ID      : {tier4_id}")

# Tickets
print("\n── Tickets ──")

# TICKET 001
create_ticket(
    subject="DC Hostname Not Renamed — WIN-DTBFF0R4BBQ retained instead of RTS-DC01",
    dept_id=infra_id, sla_id=tier4_id, priority_id=1, topic_id="0",
    issue_summary="DC01 was promoted to domain controller while retaining auto-generated Hyper-V hostname WIN-DTBFF0R4BBQ. Planned hostname RTS-DC01 was not applied. Decision made to accept as-is after verification.",
    environment="DC01 — WIN-DTBFF0R4BBQ, IP 192.168.1.10 | ridgeline.local | Windows Server 2022",
    root_cause="Hostname renaming was deferred during initial VM setup. Post-promotion rename of a DC requires DNS SRV record updates and carries Kerberos availability risk. In a single-DC lab, risk is minimal and functional impact is zero.",
    resolution_steps="Ran Resolve-DnsName, dcdiag /test:Advertising, and nltest /dsgetdc:ridgeline.local — all healthy. Accepted existing hostname.",
    lessons_learned="Always rename servers immediately after OS install, before any role installation. Enforce naming conventions via a VM provisioning checklist, not post-setup.",
)

# TICKET 002
create_ticket(
    subject="Azure AD Cloud Sync agent Disconnected — blocked by network firewall",
    dept_id=infra_id, sla_id=tier2_id, priority_id=3, topic_id="0",
    issue_summary="Azure AD Cloud Sync agent installed on DC01 showed Disconnected in Azure portal. Multiple reinstalls failed. Replaced with Azure AD Connect.",
    environment="DC01 — WIN-DTBFF0R4BBQ | Windows Server 2022 | M365 tenant: ridgelinets.onmicrosoft.com | Blocked endpoint: servicebus.windows.net:443",
    root_cause="Home lab firewall blocked outbound TCP 443 to servicebus.windows.net. Cloud Sync uses Azure Service Bus as a relay; Azure AD Connect uses direct HTTPS to well-known endpoints and is not affected.",
    resolution_steps="1. Test-NetConnection confirmed blocked endpoint. 2. Stopped AADConnectProvisioningAgent. 3. Installed Azure AD Connect with Express Settings. 4. Start-ADSyncSyncCycle confirmed all 6 users synced.",
    lessons_learned="Run Test-NetConnection against required sync endpoints before installing any identity agent. Cloud Sync and Azure AD Connect cannot coexist on the same tenant.",
)

# TICKET 003
create_ticket(
    subject="Intune compliance flag — BitLocker not enabled on WRK01 and WRK02",
    dept_id=security_id, sla_id=tier4_id, priority_id=1, topic_id="0",
    issue_summary="Both workstations flagged Noncompliant in Intune dashboard after enrollment. BitLocker cannot be enabled — VMs are Hyper-V Generation 1 with no virtual TPM.",
    environment="WRK01 DESKTOP-4PL0V3F (atorres), WRK02 DESKTOP-BTK0BJ4 (jreyes) | Windows 11 Pro | Hyper-V Gen 1 | Compliance Policy: RTS-Workstation-Compliance",
    root_cause="Hyper-V Generation 1 VMs do not expose a virtual TPM. BitLocker requires TPM 1.2+. Hyper-V Generation 2 is needed for virtual TPM support.",
    resolution_steps="Ran Get-Tpm (TpmPresent: False) and Get-BitLockerVolume (ProtectionStatus: Off) on both workstations. Accepted risk — no conditional access policies block users.",
    lessons_learned="Provision lab VMs as Generation 2 when BitLocker compliance is required. Create a separate Intune compliance policy for VMs that excludes the BitLocker requirement.",
)

# TICKET 004
create_ticket(
    subject="Account lockout — atorres unable to log in to WRK01",
    dept_id=it_support_id, sla_id=tier2_id, priority_id=3, topic_id=acct_mgmt_id,
    issue_summary="User Alex Torres locked out after 5 failed password attempts. Could not log in; received lockout message on Windows sign-in screen.",
    environment="User: atorres (Alex Torres) | Device: WRK01 DESKTOP-4PL0V3F | Domain: RIDGELINE | GPO: RTS-Password-Policy (5 attempt threshold)",
    root_cause="User entered incorrect password 5 times, triggering the lockout threshold in RTS-Password-Policy GPO. Expected behavior — policy protects against brute-force attacks.",
    resolution_steps="1. Search-ADAccount -LockedOut confirmed atorres locked. 2. Unlock-ADAccount -Identity atorres. 3. Get-ADUser atorres confirmed LockedOut: False. User logged in successfully.",
    lessons_learned="Always investigate lockout events to rule out unauthorized access — check Event ID 4740 for originating machine. Consider SSPR via Azure AD to reduce admin overhead for routine lockouts.",
)

# TICKET 005
create_ticket(
    subject="New employee onboarding — Jamie Chen, Finance department",
    dept_id=it_support_id, sla_id=tier3_id, priority_id=2, topic_id=onboarding_id,
    issue_summary="Provisioned AD account, group memberships, and M365 license for new Financial Analyst Jamie Chen. Script defect: default temp password did not meet domain policy minimum length.",
    environment="New user: jchen (Jamie Chen) | OU: Finance,RTS Users | Domain: ridgeline.local | M365 tenant: ridgelinets.onmicrosoft.com",
    root_cause="Not an incident — provisioning request. Script defect: default temp password (9 chars) failed domain policy minimum of 10 chars, leaving account disabled on first run.",
    resolution_steps="1. Ran Invoke-RTSOnboarding.ps1 with corrected temporary password. 2. Verified account with Get-ADUser jchen. 3. Assigned M365 E5 license. 4. Triggered delta sync — jchen visible in Azure AD.",
    lessons_learned="Validate script default passwords against Get-ADDefaultDomainPasswordPolicy before deployment. Confirm Azure AD Connect sync completes before attempting M365 license assignment.",
)

# TICKET 006
create_ticket(
    subject="Software request — Notepad++ 8.7.4 deployment to all workstations via Intune",
    dept_id=it_support_id, sla_id=tier4_id, priority_id=1, topic_id=software_id,
    issue_summary="Operations team requested Notepad++ on all RTS workstations for editing scripts and config files. Packaged and deployed as Intune Win32 app.",
    environment="App: Notepad++ 8.7.4 | Targets: WRK01 DESKTOP-4PL0V3F, WRK02 DESKTOP-BTK0BJ4 | Deployment: Intune Win32 Required — All Devices",
    root_cause="Not an incident — software deployment request. No software deployment pipeline existed prior to this ticket.",
    resolution_steps="1. Downloaded installer to C:\\intune-staging\\notepadpp on DC01. 2. Packaged with IntuneWinAppUtil.exe. 3. Uploaded to Intune with silent install /S. 4. Assigned Required to All Devices. 5. Verified via registry query after 30 minutes.",
    lessons_learned="Test silent install command locally before uploading to Intune. Intune Win32 deployments take ~30 minutes — check Device install status report rather than polling the device.",
)

# TICKET 007
create_ticket(
    subject="OneDrive sync error — invalid filename characters in Budget file",
    dept_id=it_support_id, sla_id=tier4_id, priority_id=1, topic_id=onedrive_id,
    issue_summary="User Alex Torres reported red X sync error badge on OneDrive. File Budget<Final>.xlsx not syncing due to restricted characters in filename.",
    environment="User: atorres (Alex Torres) | Device: WRK01 DESKTOP-4PL0V3F | Service: OneDrive for Business | Problem file: Budget<Final>.xlsx",
    root_cause="Filename contained angle bracket characters (< and >) which are not permitted by OneDrive for Business, even though NTFS allows them via extended path prefix.",
    resolution_steps="1. Identified problem file from OneDrive sync error notification. 2. Renamed Budget<Final>.xlsx to Budget-Final.xlsx. 3. OneDrive retried upload — error badge cleared in 30-60 seconds.",
    lessons_learned="Educate users not to use special characters in filenames in OneDrive-synced folders. Consider OneDrive Known Folder Move via Intune to make sync errors visible immediately.",
)

# TICKET 008
create_ticket(
    subject="Access denied — atorres cannot connect to Finance$ file share",
    dept_id=it_support_id, sla_id=tier3_id, priority_id=2, topic_id=fileshare_id,
    issue_summary="User Alex Torres received Access Denied connecting to Finance$ share for a cross-department project. Access granted by adding user to Finance Users group. Secondary: share had explicit Deny ACE for Everyone.",
    environment="User: atorres (Alex Torres) | Device: WRK01 DESKTOP-4PL0V3F | Share: \\\\WIN-DTBFF0R4BBQ\\Finance$",
    root_cause="Finance$ restricts access to Finance Users group. atorres was not a member. Secondary: share created with -NoAccess Everyone adds explicit Deny ACE overriding Allow permissions.",
    resolution_steps="1. Get-SmbShareAccess confirmed Deny ACE. 2. Add-ADGroupMember added atorres to Finance Users. 3. Rebuilt share without Deny ACE. 4. User ran klist purge and re-logged on. Access confirmed.",
    lessons_learned="Deny ACEs always override Allow ACEs — avoid -NoAccess at share level when NTFS is already restrictive. Group membership changes require new logon session — klist purge clears cached Kerberos tickets.",
)

print("\n✓ All done. Visit http://localhost:8080/scp to verify.")
