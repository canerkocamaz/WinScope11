# Development Guide

## Module ID policy

Existing module IDs `1-500` are stable. Do not renumber them.

## Native modules

New native work should follow the shape in:

```text
Templates/NativeModule.Template.ps1
```

A module descriptor should keep the catalog metadata consistent and should return findings through the Engine's native context helpers.

## Safety requirements

New code must remain compatible with the report-only product contract. Do not add:

- cleanup or destructive file operations against user/system data;
- security-control bypass instructions or code;
- credential/secret collection;
- arbitrary remote payload download/execution;
- hidden persistence or configuration mutation.

A check that inspects a high-risk area should collect only what is necessary for posture reporting.

## PowerShell 5.1 compatibility

The project intentionally carries tests for Windows PowerShell 5.1 edge cases. Avoid assumptions that are only true in PowerShell 7, especially around:

- empty pipeline output;
- collection cardinality;
- optional object/registry properties under `Set-StrictMode`;
- generic collection conversion;
- function/module scope.

## Required validation

```powershell
.\WinScope11.ps1 validate
.\Tests\Run-WinScopeValidation.ps1
```

If you change a module, run the changed module on Windows and include sanitized test output in the pull request.
