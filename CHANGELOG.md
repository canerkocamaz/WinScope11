# Changelog

This file summarizes the major source milestones that led to the current GitHub baseline. It is not an exhaustive history of every internal build.

## [3.2.8] - 2026-09

### Fixed
- Hardened `.NET Framework Inventory` against registry nodes that do not expose optional `Version`, `Release`, or `Install` values.
- Added guarded optional-property access for several registry-backed probes.

### QA
- Added optional-property source lint and runtime contract tests.
- Preserved parser, collection, module-scope, edge-case, CLI, and reporting validation gates.

## [3.2.7] - 2026-09

### Fixed
- Removed direct unsafe `Measure-Object ... .Sum` result access in AuditCompat paths.
- Hardened protected-path probing.
- Fixed empty filtered-pipeline argument shifting in result-table calls.

## [3.2.6] - 2026-09

### Changed
- Added `WinScope.AuditCompat300.psm1` wrapper so the AuditCompat dispatcher and script state persist in module scope.
- Removed direct Engine coupling to `Invoke-ModuleByNumber` and AuditCompat internal state.

## [3.2.5] - 2026-09

### Changed
- Removed production `System.Collections.Generic.List<T>` usage from the PowerShell source boundaries that had shown Windows PowerShell 5.1 runtime problems.
- Added immediate module failure error output.

## [3.2.4] - 2026-09

### Fixed
- Hardened empty-array result handling for Windows PowerShell 5.1 under `Set-StrictMode`.

## [3.2.3] - 2026-09

### Changed
- Stabilized the Engine result contract: `ExecutionStatus`, `ErrorMessage`, `Duration`, `RawRecords`, and `RecordCount`.

## [3.2.2] - 2026-09

### Fixed
- CLI now accepts both quoted and unquoted comma-separated module selections.

## [3.2.1] - 2026-09

### QA
- Rebuilt AuditCompat from a clean reference after parser/sanitization damage was identified.
- Added startup PowerShell parser preflight and `validate` command.

## [3.2.0] - 2026-09

### Changed
- Interactive hierarchy navigation changed to local ordinal numbers at group/subgroup/leaf levels while preserving real module IDs at the final selection level.

## [3.1.0] - 2026-09

### Added
- 8-main-group hierarchy with subgroup and leaf-group reporting.
- Stable mapping from the 38 source groups without changing module IDs.

## [3.0.0] - 2026-09

### Changed
- Safe Audit direction: distributed execution is report-only, with cleanup/remediation paths removed from the product workflow.

## [2.6] - 2026-09

### Added
- 500-module milestone.
- Modules 301-500 native; modules 1-300 behind the compatibility adapter.
