# Module Catalog

This catalog is generated from the **500 module descriptor files** in the v3.2.8 source tree and the hierarchy mapping in `Config/hierarchy.json`.

Implementation split:

- IDs `001-300`: `AuditCompat300`
- IDs `301-500`: `Native`

Existing module IDs are stable and should not be renumbered.

## 1. System, Servicing & Enterprise

| ID | Module | Leaf group | Adapter | Admin hint |
|---:|---|---|---|:---:|
| 001 | Startup Registry Orphans | 1.3.1 Startup & Shell | AuditCompat300 | No |
| 002 | Context Menu Orphans | 1.3.1 Startup & Shell | AuditCompat300 | No |
| 009 | Windows Optional Features | 1.1.1 Windows Update & Servicing | AuditCompat300 | Yes |
| 013 | Failed Scheduled Tasks | 1.3.1 Startup & Shell | AuditCompat300 | No |
| 014 | Service Review | 1.3.1 Startup & Shell | AuditCompat300 | No |
| 015 | Invalid CLSID / COM Registrations | 1.3.1 Startup & Shell | AuditCompat300 | No |
| 027 | Startup Folder Analyzer | 1.3.1 Startup & Shell | AuditCompat300 | No |
| 029 | Component Store (WinSxS) Analyzer | 1.1.1 Windows Update & Servicing | AuditCompat300 | Yes |
| 030 | Restore Points and VSS Analyzer | 1.2.1 Boot & Recovery | AuditCompat300 | Yes |
| 032 | Delivery Optimization Cache | 1.1.1 Windows Update & Servicing | AuditCompat300 | Yes |
| 037 | Broken Shortcuts | 1.3.1 Startup & Shell | AuditCompat300 | No |
| 043 | Windows Update Download Cache | 1.1.1 Windows Update & Servicing | AuditCompat300 | Yes |
| 044 | Pending Reboot and Servicing State | 1.1.1 Windows Update & Servicing | AuditCompat300 | Yes |
| 048 | PATH Integrity Analyzer | 1.3.1 Startup & Shell | AuditCompat300 | No |
| 068 | Scheduled Task Orphan Actions | 1.3.1 Startup & Shell | AuditCompat300 | Yes |
| 069 | Orphaned Windows Services | 1.3.1 Startup & Shell | AuditCompat300 | Yes |
| 070 | Reserved Storage Analyzer | 1.1.1 Windows Update & Servicing | AuditCompat300 | Yes |
| 071 | Provisioned App Inventory | 1.1.1 Windows Update & Servicing | AuditCompat300 | Yes |
| 089 | DISM Component Health | 1.1.1 Windows Update & Servicing | AuditCompat300 | Yes |
| 090 | SFC VerifyOnly | 1.1.1 Windows Update & Servicing | AuditCompat300 | Yes |
| 091 | Windows Update History | 1.1.1 Windows Update & Servicing | AuditCompat300 | No |
| 092 | Windows Recovery Environment (WinRE) | 1.2.1 Boot & Recovery | AuditCompat300 | Yes |
| 093 | BCD Configuration Analyzer | 1.2.1 Boot & Recovery | AuditCompat300 | Yes |
| 117 | Windows Update Policy | 1.1.1 Windows Update & Servicing | AuditCompat300 | No |
| 118 | WSUS Configuration | 1.1.1 Windows Update & Servicing | AuditCompat300 | No |
| 119 | BITS Service Health | 1.1.1 Windows Update & Servicing | AuditCompat300 | No |
| 120 | Windows Update Service Health | 1.1.1 Windows Update & Servicing | AuditCompat300 | No |
| 121 | Update Orchestrator Service Health | 1.1.1 Windows Update & Servicing | AuditCompat300 | No |
| 122 | Windows Modules Installer Health | 1.1.1 Windows Update & Servicing | AuditCompat300 | No |
| 123 | Windows Update Medic Service Health | 1.1.1 Windows Update & Servicing | AuditCompat300 | No |
| 124 | Delivery Optimization Configuration | 1.1.1 Windows Update & Servicing | AuditCompat300 | No |
| 125 | Installed Windows Capabilities | 1.1.1 Windows Update & Servicing | AuditCompat300 | Yes |
| 126 | Language Pack Inventory | 1.1.1 Windows Update & Servicing | AuditCompat300 | No |
| 127 | Installed Update Inventory | 1.1.1 Windows Update & Servicing | AuditCompat300 | No |
| 128 | Failed Windows Update Event Summary | 1.1.1 Windows Update & Servicing | AuditCompat300 | Yes |
| 129 | Pending Servicing Files | 1.1.1 Windows Update & Servicing | AuditCompat300 | Yes |
| 130 | Optional Feature Payload State | 1.1.1 Windows Update & Servicing | AuditCompat300 | Yes |
| 131 | Recovery Partition Inventory | 1.2.1 Boot & Recovery | AuditCompat300 | Yes |
| 132 | Recovery Volume Capacity | 1.2.1 Boot & Recovery | AuditCompat300 | Yes |
| 133 | Boot Manager Timeout | 1.2.1 Boot & Recovery | AuditCompat300 | Yes |
| 134 | BCD Boot Entry Inventory | 1.2.1 Boot & Recovery | AuditCompat300 | Yes |
| 135 | SafeBoot Configuration | 1.2.1 Boot & Recovery | AuditCompat300 | Yes |
| 136 | Boot Logging State | 1.2.1 Boot & Recovery | AuditCompat300 | Yes |
| 137 | Task Manager StartupApproved Inventory | 1.2.1 Boot & Recovery | AuditCompat300 | Yes |
| 138 | Crash Dump Boot Configuration | 1.2.1 Boot & Recovery | AuditCompat300 | Yes |
| 139 | Automatic Memory Dump Policy | 1.2.1 Boot & Recovery | AuditCompat300 | Yes |
| 140 | Shutdown and Unexpected Restart Summary | 1.2.1 Boot & Recovery | AuditCompat300 | No |
| 231 | Applied Computer Group Policy Summary | 1.4.1 Group Policy & Enterprise Configuration | AuditCompat300 | No |
| 232 | Applied User Group Policy Summary | 1.4.1 Group Policy & Enterprise Configuration | AuditCompat300 | No |
| 233 | Windows Update for Business Policy | 1.4.1 Group Policy & Enterprise Configuration | AuditCompat300 | No |
| 234 | OneDrive Enterprise Policy | 1.4.1 Group Policy & Enterprise Configuration | AuditCompat300 | No |
| 235 | Microsoft Edge Policy Snapshot | 1.4.1 Group Policy & Enterprise Configuration | AuditCompat300 | No |
| 236 | Defender Policy Registry Snapshot | 1.4.1 Group Policy & Enterprise Configuration | AuditCompat300 | No |
| 237 | Windows Hello for Business Policy | 1.4.1 Group Policy & Enterprise Configuration | AuditCompat300 | No |
| 238 | Remote Desktop Group Policy | 1.4.1 Group Policy & Enterprise Configuration | AuditCompat300 | No |
| 239 | MDM Enrollment Registry Inventory | 1.4.1 Group Policy & Enterprise Configuration | AuditCompat300 | No |
| 240 | PolicyManager Device Policy Snapshot | 1.4.1 Group Policy & Enterprise Configuration | AuditCompat300 | No |
| 271 | Windows Management Instrumentation Health | 1.3.2 System Services & Management | AuditCompat300 | No |
| 272 | RPC and DCOM Core Service Health | 1.3.2 System Services & Management | AuditCompat300 | No |
| 273 | DCOM Security Configuration | 1.3.2 System Services & Management | AuditCompat300 | No |
| 274 | Task Scheduler Service Health | 1.3.2 System Services & Management | AuditCompat300 | No |
| 275 | BITS Service Health | 1.3.2 System Services & Management | AuditCompat300 | No |
| 276 | Windows Installer Service Health | 1.3.2 System Services & Management | AuditCompat300 | No |
| 277 | COM+ Event System Health | 1.3.2 System Services & Management | AuditCompat300 | No |
| 278 | User Profile Service Health | 1.3.2 System Services & Management | AuditCompat300 | No |
| 279 | Application Information Service Health | 1.3.2 System Services & Management | AuditCompat300 | No |
| 280 | Windows Licensing Service Health | 1.3.2 System Services & Management | AuditCompat300 | No |
| 341 | Update Orchestrator Task Inventory | 1.1.2 Windows Update Deep Health | Native | Yes |
| 342 | Windows Update Scheduled Task Health | 1.1.2 Windows Update Deep Health | Native | Yes |
| 343 | Windows Update DataStore Footprint | 1.1.2 Windows Update Deep Health | Native | No |
| 344 | SoftwareDistribution Total Footprint | 1.1.2 Windows Update Deep Health | Native | No |
| 345 | Catroot2 Footprint | 1.1.2 Windows Update Deep Health | Native | No |
| 346 | Update Reboot Coordinator Task Inventory | 1.1.2 Windows Update Deep Health | Native | Yes |
| 347 | Windows Update Reboot Policy | 1.1.2 Windows Update Deep Health | Native | No |
| 348 | Windows Update Active Hours Policy | 1.1.2 Windows Update Deep Health | Native | No |
| 349 | Windows Update Service Dependency Snapshot | 1.1.2 Windows Update Deep Health | Native | Yes |
| 350 | Windows Update Deep Error Channels | 1.1.2 Windows Update Deep Health | Native | Yes |
| 351 | Windows Update Source Policy | 1.1.2 Windows Update Deep Health | Native | Yes |
| 352 | Automatic Updates Policy | 1.1.2 Windows Update Deep Health | Native | Yes |
| 353 | Windows Update Medic Service Health | 1.1.2 Windows Update Deep Health | Native | Yes |
| 354 | Update Session Orchestrator Service Health | 1.1.2 Windows Update Deep Health | Native | Yes |
| 355 | Delivery Optimization Service Health | 1.1.2 Windows Update Deep Health | Native | Yes |
| 356 | Windows Update DataStore Footprint | 1.1.2 Windows Update Deep Health | Native | Yes |
| 357 | Catroot2 Footprint | 1.1.2 Windows Update Deep Health | Native | Yes |
| 358 | Windows Servicing Error Events | 1.1.2 Windows Update Deep Health | Native | Yes |
| 359 | Windows Update Client Error Events | 1.1.2 Windows Update Deep Health | Native | Yes |
| 360 | DISM Package State Inventory | 1.1.2 Windows Update Deep Health | Native | Yes |
| 361 | Firmware Type Detection | 1.2.2 UEFI, Firmware & Boot Security | Native | No |
| 362 | Secure Boot Native Verification | 1.2.2 UEFI, Firmware & Boot Security | Native | Yes |
| 363 | Device Guard Security Properties | 1.2.2 UEFI, Firmware & Boot Security | Native | Yes |
| 364 | Hypervisor Launch Configuration | 1.2.2 UEFI, Firmware & Boot Security | Native | Yes |
| 365 | TPM Provisioning State | 1.2.2 UEFI, Firmware & Boot Security | Native | Yes |
| 366 | TPM Device Information | 1.2.2 UEFI, Firmware & Boot Security | Native | Yes |
| 367 | BIOS and UEFI Firmware Inventory | 1.2.2 UEFI, Firmware & Boot Security | Native | No |
| 368 | Baseboard Identity | 1.2.2 UEFI, Firmware & Boot Security | Native | No |
| 369 | Boot Manager BCD Inventory | 1.2.2 UEFI, Firmware & Boot Security | Native | Yes |
| 370 | Firmware BCD Entry Inventory | 1.2.2 UEFI, Firmware & Boot Security | Native | Yes |
| 371 | BCD Recovery Configuration | 1.2.2 UEFI, Firmware & Boot Security | Native | Yes |
| 372 | Windows Recovery Environment Status | 1.2.2 UEFI, Firmware & Boot Security | Native | Yes |
| 373 | CPU Virtualization Firmware Capability | 1.2.2 UEFI, Firmware & Boot Security | Native | No |
| 374 | Hypervisor Presence Cross-Check | 1.2.2 UEFI, Firmware & Boot Security | Native | No |
| 375 | Kernel Boot Event Summary | 1.2.2 UEFI, Firmware & Boot Security | Native | Yes |
| 376 | Kernel General Event Summary | 1.2.2 UEFI, Firmware & Boot Security | Native | Yes |
| 377 | Boot Configuration Security Flags | 1.2.2 UEFI, Firmware & Boot Security | Native | Yes |
| 378 | Kernel DMA Policy Snapshot | 1.2.2 UEFI, Firmware & Boot Security | Native | Yes |
| 379 | System Guard Policy Snapshot | 1.2.2 UEFI, Firmware & Boot Security | Native | Yes |
| 380 | Boot Operational Channel Health | 1.2.2 UEFI, Firmware & Boot Security | Native | Yes |
| 421 | Services Running as LocalSystem | 1.3.3 Services & Scheduled Tasks Analysis | Native | Yes |
| 422 | Services Using Custom Accounts | 1.3.3 Services & Scheduled Tasks Analysis | Native | Yes |
| 423 | Automatic Services Currently Stopped | 1.3.3 Services & Scheduled Tasks Analysis | Native | Yes |
| 424 | Service Failure Action Configuration | 1.3.3 Services & Scheduled Tasks Analysis | Native | Yes |
| 425 | Service Trigger Configuration Inventory | 1.3.3 Services & Scheduled Tasks Analysis | Native | Yes |
| 426 | Service Dependency Inventory | 1.3.3 Services & Scheduled Tasks Analysis | Native | Yes |
| 427 | Svchost Group Configuration | 1.3.3 Services & Scheduled Tasks Analysis | Native | Yes |
| 428 | Per-User Service Template Inventory | 1.3.3 Services & Scheduled Tasks Analysis | Native | Yes |
| 429 | Unquoted Service Path Analyzer | 1.3.3 Services & Scheduled Tasks Analysis | Native | Yes |
| 430 | Third-Party Service Binary Signature Review | 1.3.3 Services & Scheduled Tasks Analysis | Native | Yes |
| 431 | Scheduled Tasks Running as SYSTEM | 1.3.3 Services & Scheduled Tasks Analysis | Native | Yes |
| 432 | Scheduled Tasks Using Highest Run Level | 1.3.3 Services & Scheduled Tasks Analysis | Native | Yes |
| 433 | Hidden Scheduled Task Inventory | 1.3.3 Services & Scheduled Tasks Analysis | Native | Yes |
| 434 | Disabled Scheduled Task Inventory | 1.3.3 Services & Scheduled Tasks Analysis | Native | Yes |
| 435 | PowerShell Scheduled Task Actions | 1.3.3 Services & Scheduled Tasks Analysis | Native | Yes |
| 436 | Scheduled Task Missing Executable Actions | 1.3.3 Services & Scheduled Tasks Analysis | Native | Yes |
| 437 | Scheduled Task COM Handler Actions | 1.3.3 Services & Scheduled Tasks Analysis | Native | Yes |
| 438 | Scheduled Task UNC Action Paths | 1.3.3 Services & Scheduled Tasks Analysis | Native | Yes |
| 439 | Scheduled Task Principal Inventory | 1.3.3 Services & Scheduled Tasks Analysis | Native | Yes |
| 440 | Scheduled Task Failure Result Summary | 1.3.3 Services & Scheduled Tasks Analysis | Native | Yes |

## 2. Storage & Data Protection

| ID | Module | Leaf group | Adapter | Admin hint |
|---:|---|---|---|:---:|
| 003 | File Explorer Recent Items | 2.1.1 Disk Usage, Capacity & Storage Health | AuditCompat300 | No |
| 004 | Temporary Files | 2.1.1 Disk Usage, Capacity & Storage Health | AuditCompat300 | No |
| 005 | Windows Cache Usage | 2.1.1 Disk Usage, Capacity & Storage Health | AuditCompat300 | No |
| 018 | Previous Windows Installation | 2.1.1 Disk Usage, Capacity & Storage Health | AuditCompat300 | No |
| 021 | Large Files Analyzer | 2.1.1 Disk Usage, Capacity & Storage Health | AuditCompat300 | No |
| 022 | Downloads Folder Cleanup | 2.1.1 Disk Usage, Capacity & Storage Health | AuditCompat300 | No |
| 023 | Recycle Bin Analyzer | 2.1.1 Disk Usage, Capacity & Storage Health | AuditCompat300 | No |
| 031 | Storage Sense Configuration | 2.1.1 Disk Usage, Capacity & Storage Health | AuditCompat300 | No |
| 046 | Volume Space and File System Health | 2.1.1 Disk Usage, Capacity & Storage Health | AuditCompat300 | No |
| 053 | Windows Installer Cache Analyzer | 2.1.1 Disk Usage, Capacity & Storage Health | AuditCompat300 | Yes |
| 075 | Large Duplicate Files Analyzer | 2.1.1 Disk Usage, Capacity & Storage Health | AuditCompat300 | No |
| 095 | TRIM / Delete Notification Status | 2.1.1 Disk Usage, Capacity & Storage Health | AuditCompat300 | Yes |
| 101 | NTFS Dirty Bit Status | 2.2.1 Storage Internals | AuditCompat300 | No |
| 102 | NTFS Compression State | 2.2.1 Storage Internals | AuditCompat300 | No |
| 103 | NTFS Reparse Point Inventory | 2.2.1 Storage Internals | AuditCompat300 | No |
| 104 | Volume Mount Points | 2.2.1 Storage Internals | AuditCompat300 | No |
| 105 | Disk Quota Configuration | 2.2.1 Storage Internals | AuditCompat300 | Yes |
| 106 | Storage Spaces Pool Health | 2.2.1 Storage Internals | AuditCompat300 | No |
| 107 | Storage Spaces Virtual Disks | 2.2.1 Storage Internals | AuditCompat300 | No |
| 108 | Storage Spaces Physical Disks | 2.2.1 Storage Internals | AuditCompat300 | No |
| 109 | Shadow Copy Providers | 2.2.1 Storage Internals | AuditCompat300 | Yes |
| 110 | Shadow Copy Inventory | 2.2.1 Storage Internals | AuditCompat300 | Yes |
| 111 | Encrypting File System (EFS) State | 2.2.1 Storage Internals | AuditCompat300 | No |
| 112 | CompactOS State | 2.2.1 Storage Internals | AuditCompat300 | No |
| 113 | USN Journal Status | 2.2.1 Storage Internals | AuditCompat300 | Yes |
| 114 | ReFS Volume Inventory | 2.2.1 Storage Internals | AuditCompat300 | No |
| 115 | Data Deduplication Feature Status | 2.2.1 Storage Internals | AuditCompat300 | No |
| 116 | Offline Files / CSC Status | 2.2.1 Storage Internals | AuditCompat300 | No |
| 241 | Win32 Long Path Support | 2.3.1 File System & Data Protection | AuditCompat300 | No |
| 242 | NTFS 8.3 Name Creation State | 2.3.1 File System & Data Protection | AuditCompat300 | No |
| 243 | NTFS Last Access Timestamp Policy | 2.3.1 File System & Data Protection | AuditCompat300 | No |
| 244 | NTFS Symlink Evaluation Policy | 2.3.1 File System & Data Protection | AuditCompat300 | No |
| 245 | EFS Current User Certificate Status | 2.3.1 File System & Data Protection | AuditCompat300 | No |
| 246 | File History Service Status | 2.3.1 File System & Data Protection | AuditCompat300 | No |
| 247 | Work Folders Service Status | 2.3.1 File System & Data Protection | AuditCompat300 | No |
| 248 | Offline Files Configuration | 2.3.1 File System & Data Protection | AuditCompat300 | No |
| 249 | System Restore Configuration | 2.3.1 File System & Data Protection | AuditCompat300 | No |
| 250 | Windows Backup Operational Events | 2.3.1 File System & Data Protection | AuditCompat300 | No |
| 381 | Physical Disk Media and Health Inventory | 2.2.2 File-System Internals & Storage Reliability | Native | Yes |
| 382 | Storage Reliability Counters | 2.2.2 File-System Internals & Storage Reliability | Native | Yes |
| 383 | Disk Sector Size and Geometry | 2.2.2 File-System Internals & Storage Reliability | Native | Yes |
| 384 | Partition Alignment Analyzer | 2.2.2 File-System Internals & Storage Reliability | Native | Yes |
| 385 | Volume Allocation Unit Inventory | 2.2.2 File-System Internals & Storage Reliability | Native | Yes |
| 386 | NTFS TRIM and Delete Notification | 2.2.2 File-System Internals & Storage Reliability | Native | Yes |
| 387 | NTFS Last Access Timestamp Policy | 2.2.2 File-System Internals & Storage Reliability | Native | Yes |
| 388 | NTFS 8dot3 Name Creation State | 2.2.2 File-System Internals & Storage Reliability | Native | Yes |
| 389 | NTFS Compression Behavior | 2.2.2 File-System Internals & Storage Reliability | Native | Yes |
| 390 | NTFS Symlink Evaluation Policy | 2.2.2 File-System Internals & Storage Reliability | Native | Yes |
| 391 | Mount Point and Access Path Inventory | 2.2.2 File-System Internals & Storage Reliability | Native | Yes |
| 392 | Storage Spaces Pool Health | 2.2.2 File-System Internals & Storage Reliability | Native | Yes |
| 393 | Storage Spaces Virtual Disk Health | 2.2.2 File-System Internals & Storage Reliability | Native | Yes |
| 394 | ReFS Volume Inventory | 2.2.2 File-System Internals & Storage Reliability | Native | Yes |
| 395 | Data Deduplication Status | 2.2.2 File-System Internals & Storage Reliability | Native | Yes |
| 396 | BitLocker Volume Metadata Snapshot | 2.2.2 File-System Internals & Storage Reliability | Native | Yes |
| 397 | VSS Shadow Copy Inventory | 2.2.2 File-System Internals & Storage Reliability | Native | Yes |
| 398 | VSS Shadow Storage Inventory | 2.2.2 File-System Internals & Storage Reliability | Native | Yes |
| 399 | File System Behavior Policy Snapshot | 2.2.2 File-System Internals & Storage Reliability | Native | Yes |
| 400 | Storage Posture Summary | 2.2.2 File-System Internals & Storage Reliability | Native | Yes |

## 3. Network & Remote Access

| ID | Module | Leaf group | Adapter | Admin hint |
|---:|---|---|---|:---:|
| 010 | Saved Wi-Fi Profiles | 3.1.1 Wi-Fi, Adapters & Connectivity | AuditCompat300 | No |
| 020 | Hosts File and DNS Cache | 3.1.1 Wi-Fi, Adapters & Connectivity | AuditCompat300 | No |
| 028 | VPN and Proxy Analyzer | 3.1.1 Wi-Fi, Adapters & Connectivity | AuditCompat300 | No |
| 038 | Persistent / Static Routes | 3.1.1 Wi-Fi, Adapters & Connectivity | AuditCompat300 | Yes |
| 039 | Network Adapter Inventory | 3.1.1 Wi-Fi, Adapters & Connectivity | AuditCompat300 | No |
| 049 | Mapped Network Drives | 3.1.1 Wi-Fi, Adapters & Connectivity | AuditCompat300 | No |
| 050 | SMB Shares Inventory | 3.1.1 Wi-Fi, Adapters & Connectivity | AuditCompat300 | Yes |
| 060 | Time Synchronization / NTP Health | 3.1.1 Wi-Fi, Adapters & Connectivity | AuditCompat300 | No |
| 076 | Network Adapter Hygiene | 3.1.1 Wi-Fi, Adapters & Connectivity | AuditCompat300 | No |
| 141 | DNS Server Configuration | 3.2.1 TCP/IP, DNS & Name Resolution | AuditCompat300 | No |
| 142 | DNS-over-HTTPS Configuration | 3.2.1 TCP/IP, DNS & Name Resolution | AuditCompat300 | No |
| 143 | Network Profile Categories | 3.2.1 TCP/IP, DNS & Name Resolution | AuditCompat300 | No |
| 144 | IPv6 Binding Status | 3.2.1 TCP/IP, DNS & Name Resolution | AuditCompat300 | No |
| 145 | Interface Metric Analyzer | 3.2.1 TCP/IP, DNS & Name Resolution | AuditCompat300 | No |
| 146 | DHCP vs Static IP Inventory | 3.2.1 TCP/IP, DNS & Name Resolution | AuditCompat300 | No |
| 147 | NRPT Rules | 3.2.1 TCP/IP, DNS & Name Resolution | AuditCompat300 | No |
| 148 | TCP Global Settings | 3.2.1 TCP/IP, DNS & Name Resolution | AuditCompat300 | Yes |
| 149 | TCP Auto-Tuning State | 3.2.1 TCP/IP, DNS & Name Resolution | AuditCompat300 | Yes |
| 150 | PortProxy Rules | 3.2.1 TCP/IP, DNS & Name Resolution | AuditCompat300 | Yes |
| 151 | Listening TCP Ports | 3.2.1 TCP/IP, DNS & Name Resolution | AuditCompat300 | No |
| 152 | Listening UDP Endpoints | 3.2.1 TCP/IP, DNS & Name Resolution | AuditCompat300 | No |
| 153 | SMB Client Configuration | 3.2.1 TCP/IP, DNS & Name Resolution | AuditCompat300 | Yes |
| 154 | SMB Server Configuration | 3.2.1 TCP/IP, DNS & Name Resolution | AuditCompat300 | Yes |
| 155 | LLMNR Policy | 3.2.1 TCP/IP, DNS & Name Resolution | AuditCompat300 | No |
| 156 | NetBIOS over TCP/IP State | 3.2.1 TCP/IP, DNS & Name Resolution | AuditCompat300 | No |
| 157 | Internet Connection Sharing Status | 3.2.1 TCP/IP, DNS & Name Resolution | AuditCompat300 | No |
| 158 | Mobile Hotspot Service Status | 3.2.1 TCP/IP, DNS & Name Resolution | AuditCompat300 | No |
| 159 | Network Location Awareness Health | 3.2.1 TCP/IP, DNS & Name Resolution | AuditCompat300 | No |
| 160 | Windows Connection Manager Policy | 3.2.1 TCP/IP, DNS & Name Resolution | AuditCompat300 | No |
| 251 | Windows Firewall Logging Configuration | 3.3.1 Firewall, IPsec, WinRM & RDP | AuditCompat300 | No |
| 252 | IPsec Rule Inventory | 3.3.1 Firewall, IPsec, WinRM & RDP | AuditCompat300 | No |
| 253 | IPsec Main Mode Rule Inventory | 3.3.1 Firewall, IPsec, WinRM & RDP | AuditCompat300 | No |
| 254 | DNS Client Service Health | 3.3.1 Firewall, IPsec, WinRM & RDP | AuditCompat300 | No |
| 255 | WPAD and Proxy Auto-Discovery Policy | 3.3.1 Firewall, IPsec, WinRM & RDP | AuditCompat300 | No |
| 256 | HTTP.sys URL Reservations | 3.3.1 Firewall, IPsec, WinRM & RDP | AuditCompat300 | No |
| 257 | HTTP.sys SSL Certificate Bindings | 3.3.1 Firewall, IPsec, WinRM & RDP | AuditCompat300 | No |
| 258 | WinRM Listener Inventory | 3.3.1 Firewall, IPsec, WinRM & RDP | AuditCompat300 | No |
| 259 | Remote Desktop Firewall Rules | 3.3.1 Firewall, IPsec, WinRM & RDP | AuditCompat300 | No |
| 260 | Terminal Session Inventory | 3.3.1 Firewall, IPsec, WinRM & RDP | AuditCompat300 | No |

## 4. Security, Identity & Trust

| ID | Module | Leaf group | Adapter | Admin hint |
|---:|---|---|---|:---:|
| 012 | Defender Exclusion Orphans | 4.1.1 Windows Security Baseline | AuditCompat300 | Yes |
| 054 | User Profile Inventory | 4.2.1 Local Accounts & Profiles | AuditCompat300 | Yes |
| 056 | BitLocker and Device Encryption Status | 4.1.1 Windows Security Baseline | AuditCompat300 | Yes |
| 057 | Windows Firewall Profile Health | 4.1.1 Windows Security Baseline | AuditCompat300 | No |
| 058 | Orphaned Firewall Application Rules | 4.1.1 Windows Security Baseline | AuditCompat300 | Yes |
| 059 | Microsoft Defender Health | 4.1.1 Windows Security Baseline | AuditCompat300 | No |
| 072 | Local Account Hygiene | 4.2.1 Local Accounts & Profiles | AuditCompat300 | Yes |
| 077 | Secure Boot Status | 4.1.1 Windows Security Baseline | AuditCompat300 | Yes |
| 078 | TPM 2.0 Status | 4.1.1 Windows Security Baseline | AuditCompat300 | Yes |
| 079 | Virtualization-Based Security (VBS) | 4.1.1 Windows Security Baseline | AuditCompat300 | No |
| 080 | Memory Integrity / HVCI | 4.1.1 Windows Security Baseline | AuditCompat300 | No |
| 081 | Credential Guard | 4.1.1 Windows Security Baseline | AuditCompat300 | No |
| 082 | LSA Protection | 4.1.1 Windows Security Baseline | AuditCompat300 | Yes |
| 083 | Microsoft Defender SmartScreen | 4.1.1 Windows Security Baseline | AuditCompat300 | No |
| 084 | Attack Surface Reduction (ASR) Rules | 4.1.1 Windows Security Baseline | AuditCompat300 | Yes |
| 085 | Controlled Folder Access | 4.1.1 Windows Security Baseline | AuditCompat300 | Yes |
| 086 | Remote Desktop / NLA | 4.1.1 Windows Security Baseline | AuditCompat300 | Yes |
| 087 | WinRM / PowerShell Remoting | 4.1.1 Windows Security Baseline | AuditCompat300 | Yes |
| 088 | SMB1 and SMB Signing | 4.1.1 Windows Security Baseline | AuditCompat300 | Yes |
| 161 | User Account Control (UAC) Configuration | 4.3.1 Local Security Policy & Audit | AuditCompat300 | No |
| 162 | Windows Hello Policy | 4.3.1 Local Security Policy & Audit | AuditCompat300 | No |
| 163 | Local Password Policy | 4.3.1 Local Security Policy & Audit | AuditCompat300 | No |
| 164 | Account Lockout Policy | 4.3.1 Local Security Policy & Audit | AuditCompat300 | No |
| 165 | Built-in Guest Account Status | 4.3.1 Local Security Policy & Audit | AuditCompat300 | No |
| 166 | Built-in Administrator Account Status | 4.3.1 Local Security Policy & Audit | AuditCompat300 | No |
| 167 | AutoLogon Configuration | 4.3.1 Local Security Policy & Audit | AuditCompat300 | No |
| 168 | Cached Interactive Logons Policy | 4.3.1 Local Security Policy & Audit | AuditCompat300 | No |
| 169 | Advanced Audit Policy Summary | 4.3.1 Local Security Policy & Audit | AuditCompat300 | Yes |
| 170 | PowerShell Script Block Logging | 4.3.1 Local Security Policy & Audit | AuditCompat300 | No |
| 171 | PowerShell Transcription Logging | 4.3.1 Local Security Policy & Audit | AuditCompat300 | No |
| 172 | PowerShell Module Logging | 4.3.1 Local Security Policy & Audit | AuditCompat300 | No |
| 173 | AppLocker Policy Status | 4.3.1 Local Security Policy & Audit | AuditCompat300 | Yes |
| 174 | WDAC / Code Integrity Policy State | 4.3.1 Local Security Policy & Audit | AuditCompat300 | Yes |
| 175 | Windows Sandbox Feature | 4.3.1 Local Security Policy & Audit | AuditCompat300 | No |
| 176 | Microsoft Defender Application Guard | 4.3.1 Local Security Policy & Audit | AuditCompat300 | Yes |
| 177 | Remote Assistance Status | 4.3.1 Local Security Policy & Audit | AuditCompat300 | No |
| 178 | OpenSSH Server Status | 4.3.1 Local Security Policy & Audit | AuditCompat300 | No |
| 179 | Remote Registry Status | 4.3.1 Local Security Policy & Audit | AuditCompat300 | No |
| 180 | Credential Manager Target Count | 4.3.1 Local Security Policy & Audit | AuditCompat300 | No |
| 181 | NTLM Restriction Policy | 4.3.1 Local Security Policy & Audit | AuditCompat300 | No |
| 182 | LAN Manager Authentication Level | 4.3.1 Local Security Policy & Audit | AuditCompat300 | No |
| 183 | SMB Guest Logon Policy | 4.3.1 Local Security Policy & Audit | AuditCompat300 | No |
| 184 | Anonymous Access Restrictions | 4.3.1 Local Security Policy & Audit | AuditCompat300 | No |
| 185 | AutoRun / AutoPlay Policy | 4.3.1 Local Security Policy & Audit | AuditCompat300 | No |
| 186 | Removable Storage Policy | 4.3.1 Local Security Policy & Audit | AuditCompat300 | No |
| 187 | Device Installation Restriction Policy | 4.3.1 Local Security Policy & Audit | AuditCompat300 | No |
| 188 | Windows Security Options Snapshot | 4.3.1 Local Security Policy & Audit | AuditCompat300 | No |
| 189 | Local Privileged Group Membership Review | 4.3.1 Local Security Policy & Audit | AuditCompat300 | Yes |
| 190 | User Rights Assignment Snapshot | 4.3.1 Local Security Policy & Audit | AuditCompat300 | Yes |
| 201 | Local Machine Root CA Store | 4.4.1 Certificates & Trust Stores | AuditCompat300 | No |
| 202 | Local Machine Personal Certificates | 4.4.1 Certificates & Trust Stores | AuditCompat300 | No |
| 203 | Current User Personal Certificates | 4.4.1 Certificates & Trust Stores | AuditCompat300 | No |
| 204 | Expired Machine Certificates | 4.4.1 Certificates & Trust Stores | AuditCompat300 | No |
| 205 | Untrusted Certificate Store | 4.4.1 Certificates & Trust Stores | AuditCompat300 | No |
| 206 | Code Signing Certificate Inventory | 4.4.1 Certificates & Trust Stores | AuditCompat300 | No |
| 207 | Trusted Publishers Store | 4.4.1 Certificates & Trust Stores | AuditCompat300 | No |
| 208 | Enterprise Trust Store | 4.4.1 Certificates & Trust Stores | AuditCompat300 | No |
| 209 | Certificate Auto-Enrollment Policy | 4.4.1 Certificates & Trust Stores | AuditCompat300 | No |
| 210 | Cryptographic Services Health | 4.4.1 Certificates & Trust Stores | AuditCompat300 | No |
| 211 | Defender Network Protection | 4.1.2 Microsoft Defender Advanced | AuditCompat300 | No |
| 212 | Defender PUA Protection | 4.1.2 Microsoft Defender Advanced | AuditCompat300 | No |
| 213 | Defender Cloud Protection | 4.1.2 Microsoft Defender Advanced | AuditCompat300 | No |
| 214 | Defender Sample Submission Policy | 4.1.2 Microsoft Defender Advanced | AuditCompat300 | No |
| 215 | Defender Scan Schedule | 4.1.2 Microsoft Defender Advanced | AuditCompat300 | No |
| 216 | Defender Scan CPU Limit | 4.1.2 Microsoft Defender Advanced | AuditCompat300 | No |
| 217 | Defender Exclusion Extensions | 4.1.2 Microsoft Defender Advanced | AuditCompat300 | No |
| 218 | Defender Exclusion Processes | 4.1.2 Microsoft Defender Advanced | AuditCompat300 | No |
| 219 | CFA Protected Folders | 4.1.2 Microsoft Defender Advanced | AuditCompat300 | No |
| 220 | Defender Quarantine Retention | 4.1.2 Microsoft Defender Advanced | AuditCompat300 | No |
| 221 | Boot Integrity Flags | 4.1.3 Device Security & Driver Integrity | AuditCompat300 | No |
| 222 | Kernel Driver Blocklist Policy | 4.1.3 Device Security & Driver Integrity | AuditCompat300 | No |
| 223 | Device Guard Security Properties | 4.1.3 Device Security & Driver Integrity | AuditCompat300 | No |
| 224 | Unsigned PnP Driver Inventory | 4.1.3 Device Security & Driver Integrity | AuditCompat300 | No |
| 225 | Problem PnP Devices | 4.1.3 Device Security & Driver Integrity | AuditCompat300 | No |
| 226 | Driver Verifier Configuration | 4.1.3 Device Security & Driver Integrity | AuditCompat300 | No |
| 227 | Third-Party Driver Package Inventory | 4.1.3 Device Security & Driver Integrity | AuditCompat300 | No |
| 228 | Driver Search and Update Policy | 4.1.3 Device Security & Driver Integrity | AuditCompat300 | No |
| 229 | Kernel PnP Error Events | 4.1.3 Device Security & Driver Integrity | AuditCompat300 | No |
| 230 | Device Metadata Retrieval Policy | 4.1.3 Device Security & Driver Integrity | AuditCompat300 | No |
| 301 | Kerberos Ticket Cache Inventory | 4.2.2 Credentials & Authentication | Native | No |
| 302 | Kerberos Session List | 4.2.2 Credentials & Authentication | Native | No |
| 303 | Kerberos Policy Registry Snapshot | 4.2.2 Credentials & Authentication | Native | No |
| 304 | NTLM Restriction Policy | 4.2.2 Credentials & Authentication | Native | No |
| 305 | LAN Manager Compatibility Level | 4.2.2 Credentials & Authentication | Native | No |
| 306 | WDigest Credential Caching Policy | 4.2.2 Credentials & Authentication | Native | No |
| 307 | Cached Interactive Logons Policy | 4.2.2 Credentials & Authentication | Native | No |
| 308 | Credential Delegation Policy | 4.2.2 Credentials & Authentication | Native | No |
| 309 | Remote Credential Guard Policy | 4.2.2 Credentials & Authentication | Native | No |
| 310 | RDP Restricted Admin State | 4.2.2 Credentials & Authentication | Native | No |
| 311 | Logon UI Privacy Policy | 4.2.2 Credentials & Authentication | Native | No |
| 312 | Windows Hello Provisioning Policy | 4.2.2 Credentials & Authentication | Native | No |
| 313 | Smart Card Service Health | 4.2.2 Credentials & Authentication | Native | No |
| 314 | Secondary Logon Service Health | 4.2.2 Credentials & Authentication | Native | No |
| 315 | Credential Manager Service Health | 4.2.2 Credentials & Authentication | Native | No |
| 316 | DPAPI User Store Footprint | 4.2.2 Credentials & Authentication | Native | No |
| 317 | Credential Manager Safe Audit | 4.2.2 Credentials & Authentication | Native | No |
| 318 | LSA Security Packages | 4.2.2 Credentials & Authentication | Native | No |
| 319 | LSA Authentication Packages | 4.2.2 Credentials & Authentication | Native | No |
| 320 | Winlogon Notification Packages | 4.2.2 Credentials & Authentication | Native | No |
| 321 | TLS 1.0 Client Policy | 4.4.2 TLS, Schannel & Cryptography | Native | No |
| 322 | TLS 1.0 Server Policy | 4.4.2 TLS, Schannel & Cryptography | Native | No |
| 323 | TLS 1.1 Client Policy | 4.4.2 TLS, Schannel & Cryptography | Native | No |
| 324 | TLS 1.1 Server Policy | 4.4.2 TLS, Schannel & Cryptography | Native | No |
| 325 | TLS 1.2 Client Policy | 4.4.2 TLS, Schannel & Cryptography | Native | No |
| 326 | TLS 1.2 Server Policy | 4.4.2 TLS, Schannel & Cryptography | Native | No |
| 327 | TLS 1.3 Client Policy | 4.4.2 TLS, Schannel & Cryptography | Native | No |
| 328 | TLS 1.3 Server Policy | 4.4.2 TLS, Schannel & Cryptography | Native | No |
| 329 | TLS Cipher Suite Inventory | 4.4.2 TLS, Schannel & Cryptography | Native | No |
| 330 | TLS Cipher Suite Order Policy | 4.4.2 TLS, Schannel & Cryptography | Native | No |
| 331 | Windows FIPS Algorithm Policy | 4.4.2 TLS, Schannel & Cryptography | Native | No |
| 332 | Schannel Event Logging Policy | 4.4.2 TLS, Schannel & Cryptography | Native | No |
| 333 | SSL 3.0 Client Policy | 4.4.2 TLS, Schannel & Cryptography | Native | No |
| 334 | SSL 3.0 Server Policy | 4.4.2 TLS, Schannel & Cryptography | Native | No |
| 335 | Trusted Root Auto Update Policy | 4.4.2 TLS, Schannel & Cryptography | Native | No |
| 336 | Cryptographic Service Provider Inventory | 4.4.2 TLS, Schannel & Cryptography | Native | No |
| 337 | CNG Key Storage Provider Inventory | 4.4.2 TLS, Schannel & Cryptography | Native | No |
| 338 | Current User RSA Key Store Footprint | 4.4.2 TLS, Schannel & Cryptography | Native | No |
| 339 | Schannel Event Summary | 4.4.2 TLS, Schannel & Cryptography | Native | No |
| 340 | CAPI2 Operational Error Summary | 4.4.2 TLS, Schannel & Cryptography | Native | No |
| 401 | Application Identity Service Health | 4.1.4 Application Control & Code Integrity | Native | Yes |
| 402 | AppLocker Effective Policy Summary | 4.1.4 Application Control & Code Integrity | Native | Yes |
| 403 | AppLocker Executable Rules | 4.1.4 Application Control & Code Integrity | Native | Yes |
| 404 | AppLocker Windows Installer Rules | 4.1.4 Application Control & Code Integrity | Native | Yes |
| 405 | AppLocker Script Rules | 4.1.4 Application Control & Code Integrity | Native | Yes |
| 406 | AppLocker DLL Rules | 4.1.4 Application Control & Code Integrity | Native | Yes |
| 407 | AppLocker Packaged App Rules | 4.1.4 Application Control & Code Integrity | Native | Yes |
| 408 | WDAC Active Policy File Inventory | 4.1.4 Application Control & Code Integrity | Native | Yes |
| 409 | WDAC Legacy SIPolicy File State | 4.1.4 Application Control & Code Integrity | Native | Yes |
| 410 | Code Integrity Operational Error Summary | 4.1.4 Application Control & Code Integrity | Native | Yes |
| 411 | Device Guard Code Integrity Enforcement State | 4.1.4 Application Control & Code Integrity | Native | Yes |
| 412 | Smart App Control Policy Indicators | 4.1.4 Application Control & Code Integrity | Native | Yes |
| 413 | PowerShell Execution Policy Scopes | 4.1.4 Application Control & Code Integrity | Native | No |
| 414 | PowerShell Language Mode | 4.1.4 Application Control & Code Integrity | Native | No |
| 415 | PowerShell Script Block Logging Policy | 4.1.4 Application Control & Code Integrity | Native | Yes |
| 416 | PowerShell Module Logging Policy | 4.1.4 Application Control & Code Integrity | Native | Yes |
| 417 | PowerShell Transcription Policy | 4.1.4 Application Control & Code Integrity | Native | Yes |
| 418 | AlwaysInstallElevated Policy | 4.1.4 Application Control & Code Integrity | Native | Yes |
| 419 | Windows Installer DisableMSI Policy | 4.1.4 Application Control & Code Integrity | Native | Yes |
| 420 | Windows Script Host Policy | 4.1.4 Application Control & Code Integrity | Native | Yes |
| 441 | Local Administrators Group Membership | 4.2.3 Accounts, Rights & Enterprise Identity | Native | Yes |
| 442 | Remote Desktop Users Group Membership | 4.2.3 Accounts, Rights & Enterprise Identity | Native | Yes |
| 443 | Local Users Group Membership | 4.2.3 Accounts, Rights & Enterprise Identity | Native | Yes |
| 444 | Disabled Local Account Inventory | 4.2.3 Accounts, Rights & Enterprise Identity | Native | Yes |
| 445 | Password Never Expires Local Accounts | 4.2.3 Accounts, Rights & Enterprise Identity | Native | Yes |
| 446 | Password Not Required Local Accounts | 4.2.3 Accounts, Rights & Enterprise Identity | Native | Yes |
| 447 | Dormant Local Account Review | 4.2.3 Accounts, Rights & Enterprise Identity | Native | Yes |
| 448 | Orphaned User Profile SID Cross-Check | 4.2.3 Accounts, Rights & Enterprise Identity | Native | Yes |
| 449 | Current Token Privilege Snapshot | 4.2.3 Accounts, Rights & Enterprise Identity | Native | Yes |
| 450 | Local Password and Lockout Policy Summary | 4.2.3 Accounts, Rights & Enterprise Identity | Native | Yes |
| 451 | Local Guests Group Membership | 4.2.3 Accounts, Rights & Enterprise Identity | Native | Yes |
| 452 | Hyper-V Administrators Group Membership | 4.2.3 Accounts, Rights & Enterprise Identity | Native | Yes |
| 453 | Backup Operators Group Membership | 4.2.3 Accounts, Rights & Enterprise Identity | Native | Yes |
| 454 | Event Log Readers Group Membership | 4.2.3 Accounts, Rights & Enterprise Identity | Native | Yes |
| 455 | Performance Log Users Group Membership | 4.2.3 Accounts, Rights & Enterprise Identity | Native | Yes |
| 456 | Remote Management Users Group Membership | 4.2.3 Accounts, Rights & Enterprise Identity | Native | Yes |
| 457 | Local Account Lockout State | 4.2.3 Accounts, Rights & Enterprise Identity | Native | Yes |
| 458 | Local Account Password Age Snapshot | 4.2.3 Accounts, Rights & Enterprise Identity | Native | Yes |
| 459 | Microsoft Entra Join and Registration Status | 4.2.3 Accounts, Rights & Enterprise Identity | Native | Yes |
| 460 | MDM Device Management Posture | 4.2.3 Accounts, Rights & Enterprise Identity | Native | Yes |

## 5. Applications, Runtime & Developer

| ID | Module | Leaf group | Adapter | Admin hint |
|---:|---|---|---|:---:|
| 016 | .NET Framework Inventory | 5.1.1 Application Caches & Local Data | AuditCompat300 | No |
| 017 | Appx Package Health | 5.1.1 Application Caches & Local Data | AuditCompat300 | Yes |
| 026 | Browser Cache Analyzer | 5.1.1 Application Caches & Local Data | AuditCompat300 | No |
| 034 | OneDrive Local Storage | 5.1.1 Application Caches & Local Data | AuditCompat300 | No |
| 035 | Microsoft Office Document Cache | 5.1.1 Application Caches & Local Data | AuditCompat300 | No |
| 036 | Microsoft Store Cache | 5.1.1 Application Caches & Local Data | AuditCompat300 | No |
| 051 | Xbox Game Bar and Capture Storage | 5.1.1 Application Caches & Local Data | AuditCompat300 | No |
| 052 | PowerShell Module Footprint | 5.3.1 Developer & Virtualization | AuditCompat300 | No |
| 061 | WSL Distribution and VHDX Footprint | 5.3.1 Developer & Virtualization | AuditCompat300 | No |
| 062 | Hyper-V Virtual Disk Footprint | 5.3.1 Developer & Virtualization | AuditCompat300 | Yes |
| 063 | Outlook OST/PST Analyzer | 5.1.1 Application Caches & Local Data | AuditCompat300 | No |
| 064 | Microsoft Teams Cache Analyzer | 5.1.1 Application Caches & Local Data | AuditCompat300 | No |
| 065 | Browser Profile Analyzer | 5.1.1 Application Caches & Local Data | AuditCompat300 | No |
| 066 | Environment Variable Integrity | 5.3.1 Developer & Virtualization | AuditCompat300 | No |
| 073 | Icon & Thumbnail Database Cache | 5.1.1 Application Caches & Local Data | AuditCompat300 | No |
| 261 | Installed .NET Runtimes | 5.2.1 Windows Apps & Runtime | AuditCompat300 | No |
| 262 | Installed .NET SDKs | 5.2.1 Windows Apps & Runtime | AuditCompat300 | No |
| 263 | Visual C++ Redistributable Inventory | 5.2.1 Windows Apps & Runtime | AuditCompat300 | No |
| 264 | Edge WebView2 Runtime Inventory | 5.2.1 Windows Apps & Runtime | AuditCompat300 | No |
| 265 | Installed PowerShell Editions | 5.2.1 Windows Apps & Runtime | AuditCompat300 | No |
| 266 | Windows Terminal Package Status | 5.2.1 Windows Apps & Runtime | AuditCompat300 | No |
| 267 | Windows Package Manager Version | 5.2.1 Windows Apps & Runtime | AuditCompat300 | No |
| 268 | OpenSSH Client Capability | 5.2.1 Windows Apps & Runtime | AuditCompat300 | No |
| 269 | OpenSSH Server Capability | 5.2.1 Windows Apps & Runtime | AuditCompat300 | No |
| 270 | App Installer Package Health | 5.2.1 Windows Apps & Runtime | AuditCompat300 | No |

## 6. Hardware, Performance & Power

| ID | Module | Leaf group | Adapter | Admin hint |
|---:|---|---|---|:---:|
| 006 | Hibernation / hiberfil.sys | 6.3.1 Power, Sleep & Battery | AuditCompat300 | Yes |
| 007 | Pagefile Size and Usage | 6.2.1 Performance, Memory & Search | AuditCompat300 | No |
| 008 | DriverStore / OEM Drivers | 6.1.1 Devices & Drivers | AuditCompat300 | Yes |
| 011 | Bluetooth Device Inventory | 6.1.1 Devices & Drivers | AuditCompat300 | No |
| 033 | Windows Search Index | 6.2.1 Performance, Memory & Search | AuditCompat300 | No |
| 040 | Print Queue and Spooler | 6.1.1 Devices & Drivers | AuditCompat300 | Yes |
| 047 | Power Plan and Sleep Configuration | 6.3.1 Power, Sleep & Battery | AuditCompat300 | No |
| 055 | Battery Health and Capacity Analyzer | 6.3.1 Power, Sleep & Battery | AuditCompat300 | No |
| 067 | Ghost USB / Storage Device Inventory | 6.1.1 Devices & Drivers | AuditCompat300 | Yes |
| 096 | Physical Disk Health | 6.1.1 Devices & Drivers | AuditCompat300 | Yes |
| 099 | Modern Standby Support | 6.3.1 Power, Sleep & Battery | AuditCompat300 | No |
| 100 | Power Requests | 6.3.1 Power, Sleep & Battery | AuditCompat300 | Yes |
| 291 | Processor Topology Inventory | 6.2.2 Advanced Performance & System Snapshot | AuditCompat300 | No |
| 292 | Hypervisor Presence | 6.2.2 Advanced Performance & System Snapshot | AuditCompat300 | No |
| 293 | System Uptime and Last Boot | 6.2.2 Advanced Performance & System Snapshot | AuditCompat300 | No |
| 294 | Memory Device Inventory | 6.2.2 Advanced Performance & System Snapshot | AuditCompat300 | No |
| 295 | Disk Performance Snapshot | 6.2.2 Advanced Performance & System Snapshot | AuditCompat300 | No |
| 296 | Top Memory Processes Snapshot | 6.2.2 Advanced Performance & System Snapshot | AuditCompat300 | No |
| 297 | Top CPU Processes Snapshot | 6.2.2 Advanced Performance & System Snapshot | AuditCompat300 | No |
| 298 | System Error Event Summary | 6.2.2 Advanced Performance & System Snapshot | AuditCompat300 | No |
| 299 | Application Error Event Summary | 6.2.2 Advanced Performance & System Snapshot | AuditCompat300 | No |
| 300 | Device Setup Manager Event Summary | 6.2.2 Advanced Performance & System Snapshot | AuditCompat300 | No |

## 7. Diagnostics & Reliability

| ID | Module | Leaf group | Adapter | Admin hint |
|---:|---|---|---|:---:|
| 019 | Large Event Logs | 7.1.1 General Diagnostics & Reliability | AuditCompat300 | Yes |
| 024 | Crash Dump Analyzer | 7.1.1 General Diagnostics & Reliability | AuditCompat300 | No |
| 025 | Windows Error Reporting | 7.1.1 General Diagnostics & Reliability | AuditCompat300 | Yes |
| 045 | Windows Maintenance Logs | 7.1.1 General Diagnostics & Reliability | AuditCompat300 | Yes |
| 094 | Boot Performance Analyzer | 7.1.1 General Diagnostics & Reliability | AuditCompat300 | No |
| 097 | WHEA Hardware Error Analyzer | 7.1.1 General Diagnostics & Reliability | AuditCompat300 | Yes |
| 098 | Reliability Monitor Analyzer | 7.1.1 General Diagnostics & Reliability | AuditCompat300 | No |
| 191 | Windows Event Log Service Health | 7.2.1 System Event Channels | AuditCompat300 | No |
| 192 | Windows Error Reporting Policy | 7.2.1 System Event Channels | AuditCompat300 | No |
| 193 | Kernel Crash Dump Configuration | 7.2.1 System Event Channels | AuditCompat300 | No |
| 194 | Windows Memory Diagnostic Results | 7.2.1 System Event Channels | AuditCompat300 | Yes |
| 195 | LiveKernelReports Footprint | 7.2.1 System Event Channels | AuditCompat300 | No |
| 196 | Reliability Critical Event Summary | 7.2.1 System Event Channels | AuditCompat300 | No |
| 197 | Last Disk Check Results | 7.2.1 System Event Channels | AuditCompat300 | No |
| 198 | Microsoft Defender Operational Event Summary | 7.2.1 System Event Channels | AuditCompat300 | Yes |
| 199 | Windows Firewall Operational Event Summary | 7.2.1 System Event Channels | AuditCompat300 | Yes |
| 200 | Windows Update Operational Event Summary | 7.2.1 System Event Channels | AuditCompat300 | Yes |
| 461 | PowerShell Operational Error Summary | 7.2.2 Advanced Event Channels & Reliability | Native | Yes |
| 462 | WMI Activity Operational Error Summary | 7.2.2 Advanced Event Channels & Reliability | Native | Yes |
| 463 | Task Scheduler Operational Error Summary | 7.2.2 Advanced Event Channels & Reliability | Native | Yes |
| 464 | AppLocker EXE and DLL Event Summary | 7.2.2 Advanced Event Channels & Reliability | Native | Yes |
| 465 | AppLocker MSI and Script Event Summary | 7.2.2 Advanced Event Channels & Reliability | Native | Yes |
| 466 | AppLocker Packaged App Event Summary | 7.2.2 Advanced Event Channels & Reliability | Native | Yes |
| 467 | Code Integrity Operational Event Summary | 7.2.2 Advanced Event Channels & Reliability | Native | Yes |
| 468 | Device Guard Operational Event Summary | 7.2.2 Advanced Event Channels & Reliability | Native | Yes |
| 469 | Defender Operational Error Summary | 7.2.2 Advanced Event Channels & Reliability | Native | Yes |
| 470 | Windows Firewall Operational Event Summary | 7.2.2 Advanced Event Channels & Reliability | Native | Yes |
| 471 | RDP Local Session Manager Events | 7.2.2 Advanced Event Channels & Reliability | Native | Yes |
| 472 | RDP Remote Connection Manager Events | 7.2.2 Advanced Event Channels & Reliability | Native | Yes |
| 473 | RDP Client ActiveXCore Events | 7.2.2 Advanced Event Channels & Reliability | Native | Yes |
| 474 | Kernel Power Critical Event Summary | 7.2.2 Advanced Event Channels & Reliability | Native | Yes |
| 475 | Disk Provider Error Summary | 7.2.2 Advanced Event Channels & Reliability | Native | Yes |
| 476 | NTFS Error Event Summary | 7.2.2 Advanced Event Channels & Reliability | Native | Yes |
| 477 | Storage Stack Error Event Summary | 7.2.2 Advanced Event Channels & Reliability | Native | Yes |
| 478 | WHEA Hardware Error Event Summary | 7.2.2 Advanced Event Channels & Reliability | Native | Yes |
| 479 | Reliability Monitor Failure Records | 7.2.2 Advanced Event Channels & Reliability | Native | Yes |
| 480 | Event Log Capacity and Retention Summary | 7.2.2 Advanced Event Channels & Reliability | Native | Yes |

## 8. User Experience, Privacy & AI

| ID | Module | Leaf group | Adapter | Admin hint |
|---:|---|---|---|:---:|
| 041 | Advertising ID and Diagnostic Data | 8.1.1 Privacy & Telemetry Basics | AuditCompat300 | No |
| 042 | Clipboard and Activity History | 8.1.1 Privacy & Telemetry Basics | AuditCompat300 | No |
| 074 | Telemetry & Diagnostic Log Storage | 8.1.1 Privacy & Telemetry Basics | AuditCompat300 | Yes |
| 281 | File Explorer Search History Policy | 8.2.1 User Experience & Privacy Controls | AuditCompat300 | No |
| 282 | Recent Documents Policy | 8.2.1 User Experience & Privacy Controls | AuditCompat300 | No |
| 283 | Windows Location Service Status | 8.2.1 User Experience & Privacy Controls | AuditCompat300 | No |
| 284 | Camera Consent Configuration | 8.2.1 User Experience & Privacy Controls | AuditCompat300 | No |
| 285 | Microphone Consent Configuration | 8.2.1 User Experience & Privacy Controls | AuditCompat300 | No |
| 286 | Windows Notification Configuration | 8.2.1 User Experience & Privacy Controls | AuditCompat300 | No |
| 287 | Windows Web Experience Pack Status | 8.2.1 User Experience & Privacy Controls | AuditCompat300 | No |
| 288 | Windows Copilot Policy | 8.2.1 User Experience & Privacy Controls | AuditCompat300 | No |
| 289 | Windows AI / Recall Policy Snapshot | 8.2.1 User Experience & Privacy Controls | AuditCompat300 | No |
| 290 | Consumer Experiences and Suggested Content | 8.2.1 User Experience & Privacy Controls | AuditCompat300 | No |
| 481 | Windows Recall Policy Snapshot | 8.3.1 Windows UX, AI & Platform Features | Native | Yes |
| 482 | Windows Copilot Policy Snapshot | 8.3.1 Windows UX, AI & Platform Features | Native | Yes |
| 483 | Widgets and Web Experience Package Status | 8.3.1 Windows UX, AI & Platform Features | Native | No |
| 484 | Windows Spotlight and Cloud Content Policy | 8.3.1 Windows UX, AI & Platform Features | Native | Yes |
| 485 | Windows Search Service and Index State | 8.3.1 Windows UX, AI & Platform Features | Native | Yes |
| 486 | Search and Cloud Suggestions Policy | 8.3.1 Windows UX, AI & Platform Features | Native | Yes |
| 487 | Notification and Action Center Policy | 8.3.1 Windows UX, AI & Platform Features | Native | No |
| 488 | Clipboard History and Cloud Sync Policy | 8.3.1 Windows UX, AI & Platform Features | Native | Yes |
| 489 | Activity History Policy | 8.3.1 Windows UX, AI & Platform Features | Native | Yes |
| 490 | Location Service and Policy Summary | 8.3.1 Windows UX, AI & Platform Features | Native | Yes |
| 491 | Camera Capability Consent Summary | 8.3.1 Windows UX, AI & Platform Features | Native | No |
| 492 | Microphone Capability Consent Summary | 8.3.1 Windows UX, AI & Platform Features | Native | No |
| 493 | Contacts Capability Consent Summary | 8.3.1 Windows UX, AI & Platform Features | Native | No |
| 494 | Background Application Policy | 8.3.1 Windows UX, AI & Platform Features | Native | Yes |
| 495 | Diagnostic Data and Telemetry Policy | 8.3.1 Windows UX, AI & Platform Features | Native | Yes |
| 496 | Advertising ID Policy and User State | 8.3.1 Windows UX, AI & Platform Features | Native | Yes |
| 497 | Tailored Experiences and Feedback Policy | 8.3.1 Windows UX, AI & Platform Features | Native | Yes |
| 498 | Windows Hello and Sign-in Policy Summary | 8.3.1 Windows UX, AI & Platform Features | Native | Yes |
| 499 | Accessibility Feature State Snapshot | 8.3.1 Windows UX, AI & Platform Features | Native | No |
| 500 | Modern Windows Platform Feature Summary | 8.3.1 Windows UX, AI & Platform Features | Native | Yes |

