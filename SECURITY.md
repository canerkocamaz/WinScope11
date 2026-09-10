# Security Policy

## Supported source baseline

The current repository baseline is WinScope 11 **v3.2.8**. Security fixes should target the latest source on the `main` branch unless a release note says otherwise.

## Safe Audit contract

WinScope is designed as a report-only Windows client analyzer. The distributed source is intended to:

- collect configuration and posture information;
- create findings and recommendations;
- generate per-module and combined reports;
- avoid built-in cleanup/remediation workflows;
- avoid system-configuration mutation as part of audit execution.

High-risk areas should remain report-only.

## Report privacy

Generated reports can contain machine-specific or security-relevant information, including host configuration, users/groups, installed software, policies, event metadata, service state, registry-derived posture, and file-system paths.

Before attaching a report to a public GitHub issue:

1. Review it locally.
2. Remove host names, user names, internal domains, addresses, identifiers, paths, and other sensitive context that is not required to reproduce the issue.
3. Prefer a minimal sanitized excerpt over a full report archive.

The repository `.gitignore` excludes the default WinScope report locations and common local secret/key formats, but contributors are responsible for reviewing staged files before committing.

## Antivirus / EDR classifications

Endpoint security products can classify scripts and archives using signatures, reputation, heuristics, and machine-learning models. Source review cannot guarantee a specific vendor verdict.

If an exact WinScope file is unexpectedly classified:

- do **not** create an antivirus/EDR exclusion merely to run WinScope;
- keep the exact sample and its hash;
- isolate the triggering file or module if practical;
- submit the exact sample to the security vendor for false-positive analysis.

Module 460 in this baseline uses the narrowed **MDM Device Management Posture** implementation and does not enumerate MDM enrollment identifiers or EnterpriseMgmt scheduled-task folders.

## Reporting a security issue

Please avoid opening a public issue for a vulnerability that could expose users. Use GitHub's private vulnerability reporting feature for the repository when available, or contact the repository owner through their GitHub profile.

Include:

- affected WinScope version/commit;
- Windows and PowerShell versions;
- affected module ID(s);
- reproduction steps;
- expected and observed behavior;
- sanitized logs or error text;
- impact assessment.
