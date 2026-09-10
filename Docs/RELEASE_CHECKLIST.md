# Release Checklist

Use this checklist before publishing a WinScope source/release archive.

## Source integrity

- [ ] `WinScope11.ps1 validate` passes.
- [ ] `Tests\Run-WinScopeValidation.ps1` passes on Windows PowerShell 5.1.
- [ ] Module IDs are exactly `1-500` and unique.
- [ ] AuditCompat IDs are `1-300`; Native IDs are `301-500`.
- [ ] Module 460 remains the narrowed `MDM Device Management Posture` implementation.

## Runtime smoke tests

- [ ] Representative AuditCompat modules complete.
- [ ] Representative Native modules complete.
- [ ] Changed modules have direct runtime tests.
- [ ] Errors are reported as module failures rather than unhandled launcher exceptions.

## Safety and privacy

- [ ] No generated reports or host-specific output are included in the repository/archive.
- [ ] No credentials, API keys, signing keys, certificates with private keys, or `.env` secrets are present.
- [ ] No antivirus/EDR exclusions are documented as a requirement.
- [ ] Report-only safety contract remains intact.

## Documentation

- [ ] README version/status is current.
- [ ] CHANGELOG is updated.
- [ ] `VERSION` matches `Config/winscope.json`.
- [ ] Module catalog has 500 entries.
- [ ] Release notes mention known limitations honestly.

## Release artifacts

- [ ] ZIP integrity test passes.
- [ ] SHA-256 is generated from the exact uploaded ZIP.
- [ ] Git tag matches the release version.
