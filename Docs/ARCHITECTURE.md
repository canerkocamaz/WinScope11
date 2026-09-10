# Architecture

## Overview

WinScope 11 separates catalog, execution, console navigation, reporting, compatibility logic, and native modules.

```text
WinScope11.ps1
  |
  +-- Core/WinScope.Catalog.psm1
  +-- Core/WinScope.Console.psm1
  +-- Core/WinScope.Engine.psm1
  +-- Core/WinScope.Reporting.psm1
  |
  +-- AuditCompat/WinScope.AuditCompat300.psm1
  |       `-- dot-sources WinScope.AuditCompat300.ps1 at module scope
  |
  +-- Modules/
          001-300  AuditCompat300 descriptors
          301-500  Native descriptors/implementations
```

## Catalog

The catalog loads the 500 module descriptor files and enriches them with the user-facing hierarchy from `Config/hierarchy.json`. Module IDs are stable and must not be renumbered.

## Engine

The Engine executes two adapter families:

- `AuditCompat300` for IDs 1-300
- `Native` for IDs 301-500

Every probe returns the same result contract:

```text
ExecutionStatus
ErrorMessage
Duration
RawRecords
RecordCount
```

## AuditCompat wrapper

`WinScope.AuditCompat300.psm1` exists to keep the internal compatibility dispatcher and script state in persistent module scope. The Core Engine interacts with the wrapper through exported commands rather than directly reading internal `$Script:` state.

## Reporting

The reporting module normalizes findings and emits per-module, combined, and hierarchy outputs.

## Startup parser gate

Before importing and executing audit modules, the launcher uses the Windows PowerShell parser against every `.ps1` and `.psm1` source file. Parser errors stop execution before an audit module runs.

## Future v4 executable

The preferred v4 direction is a small .NET launcher with a stable CLI contract while retaining the modular audit engine. The current draft is in `EXE_CLI_CONTRACT.md`.
