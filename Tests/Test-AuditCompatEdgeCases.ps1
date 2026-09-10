#requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$wrapper = Join-Path $root 'AuditCompat\WinScope.AuditCompat300.psm1'

Write-Host 'AuditCompat PowerShell 5.1 edge-case tests' -ForegroundColor Cyan

$m = Import-Module -Name $wrapper -Force -PassThru -ErrorAction Stop
$cmd = $m.ExportedCommands['Test-WSAuditCompatEdgeContracts']
if($null -eq $cmd) {
    throw 'AuditCompat edge-contract self-test export is missing.'
}

$result = & $cmd

if($result.EmptyTable -ne 'PASS') { throw 'Empty table contract failed.' }
if($result.EmptyFilter -ne 'PASS') { throw 'Empty filtered table contract failed.' }
if($result.EmptySum -ne 0) { throw "Empty sum expected 0, got $($result.EmptySum)." }
if($result.MultiSum -ne 30) { throw "Multi sum expected 30, got $($result.MultiSum)." }
if($result.EmptyCount -ne 0) { throw "Empty count expected 0, got $($result.EmptyCount)." }
if($result.SingleCount -ne 1) { throw "Single count expected 1, got $($result.SingleCount)." }
if($result.MissingPathSize -ne 0) { throw "Missing path size expected 0, got $($result.MissingPathSize)." }

Write-Host 'PASS - Empty Show-ResultTable contract' -ForegroundColor Green
Write-Host 'PASS - Empty filtered pipeline contract' -ForegroundColor Green
Write-Host 'PASS - Safe property sum contract' -ForegroundColor Green
Write-Host 'PASS - Safe count contract' -ForegroundColor Green
Write-Host 'PASS - Missing/inaccessible-style path contract' -ForegroundColor Green
