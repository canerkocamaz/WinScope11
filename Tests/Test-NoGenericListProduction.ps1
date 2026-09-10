#requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

$files = @(
    Get-ChildItem -LiteralPath $root -Recurse -File |
        Where-Object {
            $_.Extension -in @('.ps1','.psm1') -and
            $_.FullName -notlike (Join-Path $root 'Tests\*')
        }
)

$hits = @()
foreach($file in $files) {
    $lineNo=0
    foreach($line in Get-Content -LiteralPath $file.FullName) {
        $lineNo++
        if($line -match 'System\.Collections\.Generic\.List') {
            $hits += [pscustomobject]@{
                File=$file.FullName
                Line=$lineNo
                Text=$line.Trim()
            }
        }
    }
}

if(@($hits).Count -gt 0) {
    $hits | Format-Table -AutoSize -Wrap | Out-Host
    throw 'Generic.List usage remains in production PowerShell source.'
}

Write-Host 'PASS - No Generic.List<T> remains in production PowerShell source.' -ForegroundColor Green
