# Help

```text
WinScope 11
Help

Interactive menu:
  S                  Browse groups using local numbers
  A                  Run all 500 modules
  M                  List all modules
  R                  Show report directory
  H                  Show this help
  Q                  Quit

Inside S:
  1, 2, 3...         Choose the displayed group/subgroup/category
  A                  Run every module in the current branch
  M                  List modules in the current branch
  B                  Go back one level
  Q                  Leave module selection

At the final module list, enter the REAL module ID:
  36                 Run module 36
  36,41,460          Run multiple IDs when they are in the displayed category
  36-40              Run an ID range when those IDs are in the displayed category

PowerShell CLI:
  .\WinScope11.ps1 help
  .\WinScope11.ps1 module 36
  .\WinScope11.ps1 run 36,41,460
  .\WinScope11.ps1 run "36,41,460"
  .\WinScope11.ps1 run 36-40
  .\WinScope11.ps1 group 3
  .\WinScope11.ps1 group 3.2
  .\WinScope11.ps1 group 3.2.1
  .\WinScope11.ps1 all
  .\WinScope11.ps1 modules
  .\WinScope11.ps1 groups
  .\WinScope11.ps1 validate

Reports:
  Per-module JSON/TXT
  Combined CSV/JSON/TXT/HTML
  Main/sub/leaf hierarchy reports
```
