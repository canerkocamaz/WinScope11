# Contributing to WinScope 11

Thank you for helping improve WinScope 11.

## Principles

- Preserve the report-only Safe Audit model.
- Keep module IDs stable. Do not renumber existing modules.
- Do not introduce cleanup, destructive remediation, credential collection, secret dumping, payload download, or endpoint-security bypass behavior.
- Treat access-denied, missing-feature, and missing-property conditions as normal Windows states when appropriate; report them instead of crashing the run.
- Keep user-facing source comments and documentation in English.

## Before changing code

1. Create a branch from `main`.
2. Keep changes focused and explain the affected module IDs or core component.
3. For new native checks, use `Templates/NativeModule.Template.ps1` as a starting point.
4. Preserve the module result and reporting contracts.

## Validation

Run:

```powershell
.\WinScope11.ps1 validate
.\Tests\Run-WinScopeValidation.ps1
```

For changes to an audit module, also run that module directly and, where reasonable, a representative nearby range.

Example:

```powershell
.\WinScope11.ps1 module 460
.\WinScope11.ps1 run 451-460
```

## Pull requests

A pull request should include:

- what changed;
- why the change is needed;
- affected module IDs/components;
- validation output;
- runtime test output when applicable;
- security/privacy impact, if any.

Do not include generated WinScope reports containing real machine or user information unless they have been intentionally sanitized.
