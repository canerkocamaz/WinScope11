# WinScope 11 — Roadmap to 500 Active Modules

Current active modules: **500**

Target: **500**

The next 200 modules should be native modular checks rather than additions to the legacy monolith.

## Planned module families (301–500)

### 301–320 — Credential & Authentication ✅ Native in v2.3
Kerberos, NTLM restrictions, Credential Guard details, WDigest, delegation, cached logon policy, Windows Hello, Remote Credential Guard, RDP Restricted Admin, local security authority posture.

### 321–340 — TLS, Schannel & Crypto ✅ Native in v2.3
TLS protocol policy, cipher suites, Schannel events, certificate chain validation, FIPS policy, key storage providers, CNG/KSP inventory and cryptographic service diagnostics.

### 341–360 — Windows Update Deep Health
341–360 ✅ Native in v2.3/v2.4.
Update orchestration tasks, datastore footprint, servicing stack, update source conflicts, reboot coordinator, update policy conflicts and operational error trends.

### 361–380 — Advanced Boot, UEFI & Firmware Security ✅ Native in v2.4
Firmware type, Secure Launch, Kernel DMA Protection, TPM PCR banks, UEFI variables where safely readable, BCD recovery sequences and hypervisor launch configuration.

### 381–400 — Storage & File-System Internals ✅ Native in v2.4
Sector size, partition alignment, sparse files, integrity streams, deduplication, storage reliability counters, write cache, BitLocker metadata visibility, VHD/VHDX health and Storage Spaces resiliency.

### 401–420 — Application Control & Code Integrity ✅ Native in v2.5
AppLocker effective policy, WDAC policies, Smart App Control, CodeIntegrity events, MSI policy, script execution policy scopes and application reputation settings.

### 421–440 — Services & Scheduled Tasks Deep Analysis ✅ Native in v2.5
Service accounts, failure actions, triggers, privileges, service SID, svchost grouping, hidden tasks, SYSTEM/highest tasks, COM handlers and unsigned action targets.

### 441–460 — Accounts, Rights & Enterprise Identity
441–450 ✅ Native in v2.5; 451–460 ✅ Native in v2.6.
Local group memberships, Administrators/RDP Users, user-right assignments, profile SID anomalies, dormant accounts, password-never-expires and enterprise enrollment posture.

### 461–480 — Advanced Event Channels & Reliability ✅ Native in v2.6
PowerShell, WMI Activity, AppLocker, Code Integrity, RDP, Defender, Device Guard, Kernel Boot, Storage and security event-channel health.

### 481–500 — Windows UX, AI, Privacy & Platform Features ✅ Native in v2.6
Windows AI/Recall controls, widgets, Spotlight, search/indexing, notification permissions, app capability permissions, accessibility services and modern shell components.

## Rule

301–500 should be **report-only by default**. Any future remediation action must be a separate explicit action workflow with preview, confirmation and a rollback strategy.


## Milestone status

**500 / 500 active modules completed.**
