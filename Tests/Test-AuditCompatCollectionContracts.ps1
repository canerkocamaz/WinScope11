#requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$compat = Join-Path $root 'AuditCompat\WinScope.AuditCompat300.ps1'

Write-Host 'AuditCompat collection contract tests' -ForegroundColor Cyan

. $compat

if($Script:Results -is [System.Collections.Generic.List[object]]) {
    throw 'AuditCompat Script:Results still uses Generic.List[object].'
}

$Script:Results.Clear()
if($Script:Results.Count -ne 0) {
    throw 'AuditCompat results did not clear.'
}

$r1 = Add-Result 999 'QA' 'One' 'Info' 'One record' 'No action.'
if($null -eq $r1){ throw 'Add-Result returned null.' }
if($Script:Results.Count -ne 1){ throw "Expected 1 result, got $($Script:Results.Count)." }

$r2 = Add-Result 999 'QA' 'Two' 'Info' 'Second record' 'No action.'
if($Script:Results.Count -ne 2){ throw "Expected 2 results, got $($Script:Results.Count)." }

$filtered = @($Script:Results | Where-Object Status -eq 'Info')
if($filtered.Count -ne 2){ throw "Array/pipeline enumeration expected 2 records, got $($filtered.Count)." }

$first = $Script:Results[0]
if($first.Item -ne 'One'){ throw 'Indexed collection access failed.' }

Write-Host 'PASS - Script:Results collection contract' -ForegroundColor Green
Write-Host 'PASS - Add-Result output contract' -ForegroundColor Green
Write-Host 'PASS - Collection pipeline/filter contract' -ForegroundColor Green
Write-Host 'PASS - Collection indexing contract' -ForegroundColor Green
