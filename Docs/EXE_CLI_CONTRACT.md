# WinScope EXE CLI Contract — Draft for v4

The PowerShell engine remains the reference implementation for v3.2.
The next step is a Windows executable launcher/front-end.

## Planned commands

```text
winscope.exe
winscope.exe --help
winscope.exe --version

winscope.exe --module 36
winscope.exe --modules 36,41,460
winscope.exe --range 36-40

winscope.exe --group 3
winscope.exe --group 3.2
winscope.exe --group 3.2.1
winscope.exe --all

winscope.exe --list-modules
winscope.exe --list-groups
winscope.exe --reports
winscope.exe --report-dir "C:\Reports\WinScope"
```

## Behavior

- No arguments: open the interactive local-number menu.
- `--help`: print usage, examples, report locations and exit codes.
- Module/group execution remains report-only.
- Console exit code 0: requested run completed without module execution failures.
- Console exit code 1: one or more modules failed.
- Console exit code 2: invalid arguments or invalid module/group selection.
- Console exit code 3: environment/bootstrap error.

The EXE should not use PS2EXE as the long-term architecture. The preferred design is a small signed .NET launcher
with a stable CLI contract and the WinScope audit engine kept modular.
