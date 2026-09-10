# PowerShell CLI Reference

## Syntax

```text
.\WinScope11.ps1 <command> [target]
```

Supported commands in the current PowerShell launcher:

| Command | Example | Purpose |
|---|---|---|
| `menu` | `.\WinScope11.ps1` | Open interactive menu (default) |
| `select` | `.\WinScope11.ps1 select` | Open hierarchy selector |
| `help` | `.\WinScope11.ps1 help` | Show help |
| `validate` | `.\WinScope11.ps1 validate` | Validate parser/catalog/contracts without running audit modules |
| `module` | `.\WinScope11.ps1 module 36` | Run one real module ID |
| `run` | `.\WinScope11.ps1 run 36,41,460` | Run IDs and/or ranges |
| `group` | `.\WinScope11.ps1 group 3.2.1` | Run a canonical hierarchy branch |
| `all` | `.\WinScope11.ps1 all` | Run all 500 modules |
| `modules` | `.\WinScope11.ps1 modules` | List modules |
| `groups` | `.\WinScope11.ps1 groups` | List hierarchy |

## Multiple IDs

Both forms are accepted:

```powershell
.\WinScope11.ps1 run 36,41,460
.\WinScope11.ps1 run "36,41,460"
```

## Ranges

```powershell
.\WinScope11.ps1 run 36-40
```

## Hierarchy codes

The interactive UI uses local numbers. The CLI `group` command keeps canonical hierarchy codes for automation:

```powershell
.\WinScope11.ps1 group 3
.\WinScope11.ps1 group 3.2
.\WinScope11.ps1 group 3.2.1
```

## Planned v4 EXE

The executable CLI is a future milestone. Its draft contract is documented in `EXE_CLI_CONTRACT.md`. Do not assume every planned `winscope.exe --...` switch exists in the current PowerShell version.
