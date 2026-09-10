# Publishing WinScope 11 to GitHub

Repository target:

```text
https://github.com/canerkocamaz/WinScope11
```

## 1. Create the repository

On GitHub, create a new repository named `WinScope11`. For the cleanest first push, create it empty (do not pre-generate README, `.gitignore`, or license files because this package already contains them).

## 2. Open PowerShell in the repository folder

After extracting this GitHub-ready package, the folder containing `WinScope11.ps1` is the repository root.

```powershell
cd C:\path\to\WinScope11
```

## 3. Review files before committing

```powershell
git status
```

Confirm that generated reports, secrets, signing files, and private machine data are not present.

## 4. Initialize Git

```powershell
git init
git branch -M main
git add .
git status
git commit -m "Initial WinScope 11 v3.2.8 source release"
```

## 5. Add the GitHub remote

```powershell
git remote add origin https://github.com/canerkocamaz/WinScope11.git
```

## 6. Push

```powershell
git push -u origin main
```

GitHub may ask you to authenticate through the browser, Git Credential Manager, a personal access token, or GitHub CLI depending on your local setup.

## 7. Verify GitHub Actions

After the push, open **Actions** and check the `WinScope Validation` workflow. It runs the project's validation suite on a Windows runner using Windows PowerShell.

## 8. Create a release

Use a tag such as:

```text
v3.2.8
```

Suggested release title:

```text
WinScope 11 v3.2.8 - Safe Property Access
```

Attach the normal end-user release ZIP and its SHA-256 file to the GitHub Release. Do not commit release ZIP files to the source tree.

## Recommended repository settings

- Enable Issues.
- Enable private vulnerability reporting if available.
- Keep branch protection optional initially; after the first clean validation run, consider requiring the validation workflow before merging to `main`.
- Add repository topics such as: `windows`, `powershell`, `windows-11`, `security-audit`, `system-health`, `configuration`, `diagnostics`.
