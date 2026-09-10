# Installation

## Option 1: clone with Git

```powershell
git clone https://github.com/canerkocamaz/WinScope11.git
cd WinScope11
```

## Option 2: download a GitHub release

Download the source/release archive from the repository's **Releases** page, extract it to a normal local folder, and open Windows PowerShell in that folder.

## Requirements

- Windows 11
- Windows PowerShell 5.1 or later
- Administrator privileges recommended for checks that read protected system areas

WinScope can start without elevation. Individual checks may have reduced visibility when Windows denies access.

## Validate before use

```powershell
.\WinScope11.ps1 validate
```

For the broader non-audit QA suite:

```powershell
.\Tests\Run-WinScopeValidation.ps1
```

## Start WinScope

```powershell
.\WinScope11.ps1
```

## Script execution policy

WinScope does not modify the Windows PowerShell execution policy. If your organization blocks unsigned scripts, follow your organization's approved process for running or signing PowerShell code. Do not weaken endpoint security controls solely to run WinScope.

## Reports

The default report root is:

```text
%LOCALAPPDATA%\WinScope11\Reports
```

See `REPORTING.md` for the full report structure.
