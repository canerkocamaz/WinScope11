# Reporting

WinScope creates a unique report directory for each run under:

```text
%LOCALAPPDATA%\WinScope11\Reports\YYYYMMDD_HHMMSS_<runid>
```

## Per-module reports

For each selected module, WinScope can create:

```text
modules\NNN-module-name.json
modules\NNN-module-name.txt
```

A module report is created even when the module returns zero findings, allowing the run to show that the selected check executed.

## Combined run reports

Each run can create:

```text
results.csv
results.json
results.txt
results.html
run.json
selected-modules.json
```

## Hierarchy reports

The `hierarchy` directory contains aggregate reports for hierarchy branches touched by the run:

```text
hierarchy\
  maingroup\*.csv / *.json / *.txt / *.html
  subgroup\*.csv / *.json / *.txt / *.html
  leafgroup\*.csv / *.json / *.txt / *.html
  index.json
```

## Privacy

Reports are intentionally excluded from Git by `.gitignore`. They can contain machine-specific configuration and security posture. Review and sanitize any report before attaching it to a public issue or sharing it outside the intended environment.
