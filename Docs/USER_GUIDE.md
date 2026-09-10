# User Guide

## Start the interactive console

```powershell
.\WinScope11.ps1
```

The main menu supports:

| Key | Action |
|---|---|
| `S` | Browse groups using local numbers |
| `A` | Run all 500 modules |
| `M` | List all modules |
| `R` | Show report directory |
| `H` | Show help |
| `Q` | Quit |

You can also enter a module expression directly at the main menu:

```text
36
36,41,460
36-40
```

## Hierarchical selection

Press `S`. WinScope shows the 8 main groups. At each hierarchy level, use the **local number shown on screen**, not a canonical group code.

Example flow:

```text
S
  -> Main group: 1
  -> Subgroup: 3
  -> Category: 2
  -> Module ID: 36
```

Navigation keys inside selection:

- `1`, `2`, `3`, ...: choose the displayed branch
- `A`: run all modules in the current branch
- `M`: list modules in the current branch
- `B`: go back one level
- `Q`: leave selection

At the final module list, use real stable IDs `1-500`.

## Understanding results

A module can complete with findings even if the finding is informational, a feature is unavailable, or a protected area cannot be fully read. A module marked `Failed` means its execution contract failed and the error is shown below the progress line and recorded in the run metadata.

## Administrator mode

Running as Administrator can increase visibility for protected services, registry areas, event channels, and system paths. Lack of elevation should not cause WinScope to change the system; checks should report limited visibility where practical.

## Safe Audit behavior

WinScope provides findings and recommendations. It does not include a built-in cleanup/remediation workflow in this source baseline.
