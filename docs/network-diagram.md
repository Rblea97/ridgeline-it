# Ridgeline Technology Services — Network Diagram

## Topology Overview

```mermaid
graph TD
    subgraph Host["Hyper-V Host — Windows 11"]
        subgraph LAN["RTS-LAN Internal Switch · 192.168.1.0/24"]
            DC01["DC01 · WIN-DTBFF0R4BBQ
Windows Server 2022
IP: 192.168.1.10 static
Roles: AD DS · DNS · DHCP
Domain: ridgeline.local"]
            WRK01["WRK01 · DESKTOP-4PL0V3F
Windows 11 Pro
IP: 192.168.1.102 static
User: atorres"]
            WRK02["WRK02 · DESKTOP-BTK0BJ4
Windows 11 Pro
IP: 192.168.1.103 static
User: jreyes"]
        end
        NAT["Default Switch (NAT)
DC01 Eth2: 172.23.32.70"]
    end

    DC01 <-->|RTS-LAN| WRK01
    DC01 <-->|RTS-LAN| WRK02
    DC01 -->|"Default Switch (internet)"| NAT
    NAT --> Internet["Internet"]
    DC01 -->|"Azure AD Connect
Password Hash Sync"| EntraID

    subgraph M365["Microsoft 365 · <TENANT>.onmicrosoft.com"]
        EntraID["Azure AD / Entra ID
6 synced users
UPN: @<TENANT>.onmicrosoft.com"]
        Intune["Microsoft Intune
MDM Scope: All
WRK01 + WRK02 enrolled"]
        Exchange["Exchange Online
Teams · OneDrive · SharePoint"]
        EntraID --> Intune
        EntraID --> Exchange
    end
```

## Network Details

| Parameter | Value |
|---|---|
| Internal switch | RTS-LAN |
| Subnet | 192.168.1.0/24 |
| Domain controller IP | 192.168.1.10 (static) |
| DHCP scope | 192.168.1.100 – 192.168.1.200 |
| DHCP exclusions | 192.168.1.1 – 192.168.1.20 |
| DNS server (internal) | 192.168.1.10 (DC01) |
| DNS forwarder | 8.8.8.8 (Google) |
| Internet access | Hyper-V Default Switch (NAT), DC01 Ethernet 2 |

## Domain Information

| Parameter | Value |
|---|---|
| On-premises domain | ridgeline.local |
| NetBIOS name | RIDGELINE |
| Forest/domain functional level | Windows Server 2016 (WinThreshold) |
| Cloud tenant | <TENANT>.onmicrosoft.com |
| Sync method | Azure AD Connect (Entra Connect Sync) |
| Password sync | Password Hash Sync enabled |
| Sync interval | 30 minutes (delta sync) |
