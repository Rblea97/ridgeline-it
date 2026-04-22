# Changelog

All notable changes to this project are documented here.

## [1.0.0] — April 2026

### Added
- Active Directory domain `ridgeline.local` — 3 department OUs (Operations, Finance, IT), 6 users, 4 security groups
- DNS forwarder (8.8.8.8) and DHCP scope (192.168.1.100–200) on DC01
- Group Policy: RTS-Password-Policy (10-char min, lockout after 5 attempts) and RTS-Workstation-Policy
- Azure AD Connect with Password Hash Sync — all 6 users synced to Entra ID
- Microsoft Intune: RTS-Workstation-Compliance policy, RTS-Workstation-Config profile, Win32 app deployment (7-Zip 24.09, Notepad++ 8.7.4)
- PowerShell automation: New-RTSUser, Invoke-RTSOnboarding, Reset-RTSUserPassword, Get-RTSComplianceReport, New-RTSLabVMs
- 8 support tickets worked end-to-end across account management, cloud identity, MDM, and file share permissions
- 3 Standard Operating Procedures: new-user-onboarding, device-enrollment, software-deployment
- 5 Knowledge Base articles: account lockout, new user onboarding, software request, OneDrive sync error, file share permissions
- Asset register and network diagram
- Deployment screenshots (9 images)
