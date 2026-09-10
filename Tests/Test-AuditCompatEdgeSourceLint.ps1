#requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'

$root=Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$audit=Join-Path $root 'AuditCompat\WinScope.AuditCompat300.ps1'
$text=Get-Content -LiteralPath $audit -Raw -Encoding UTF8

$issues=@()

if($text -match 'Measure-Object[^\r\n]*-Sum\)\.Sum') {
    $issues += 'Direct Measure-Object -Sum .Sum access remains.'
}

if($text -match '\$measure\.Sum|\$totalMeasure\.Sum') {
    $issues += 'Unsafe aggregate .Sum variable access remains.'
}

if($text -match 'Show-ResultTable\s+\([^\r\n]*\|') {
    $issues += 'Show-ResultTable still receives a positional pipeline expression.'
}

if($issues.Count -gt 0) {
    foreach($i in $issues){Write-Host ("FAIL - {0}" -f $i) -ForegroundColor Red}
    throw 'AuditCompat edge-case source lint failed.'
}

Write-Host 'PASS - No unsafe Measure-Object .Sum access remains.' -ForegroundColor Green
Write-Host 'PASS - No positional filtered Show-ResultTable call remains.' -ForegroundColor Green
