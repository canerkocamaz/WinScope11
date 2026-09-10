# Migration strategy

WinScope 11 v2.2 intentionally uses a compatibility adapter for modules 1–300.

Why:
1. The existing checks already encode a large amount of Windows-specific behavior.
2. A mechanical rewrite of 300 implementations would introduce unnecessary regressions.
3. The descriptor-per-module structure lets selection, reporting, grouping and future native modules be modular now.
4. Individual legacy modules can be migrated to native module files one at a time.

A native module should return finding objects only. UI and report writing belong to Core.


## v2.3 native executor

`Core\WinScope.Engine.psm1` now supports two adapters:

- `AuditCompat300`
- `Native`

Modules 301–350 use `Adapter = 'Native'` and contain an `Invoke` scriptblock.
The native context exposes `NewFinding`, which produces standardized finding records.


## v2.4
Modules 301–400 are now Native; 1–300 remain on AuditCompat300 compatibility.


## v2.5 native executor milestone

Modules **301–450** now execute through the Native adapter.
The project has **150 native modules** and 300 compatibility modules.


## v2.6 — 500-module milestone

Modules **301–500** use the Native adapter.
Modules **1–300** remain on the compatibility adapter pending gradual migration.
The product now has **200 native modules** and **500 active checks**.


## v3.0 Safe Audit

The compatibility layer was renamed to AuditCompat and mutation code paths were removed from the distributed source.
