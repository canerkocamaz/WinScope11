#requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$wrapper = Join-Path $root 'AuditCompat\WinScope.AuditCompat300.psm1'
$engine = Join-Path $root 'Core\WinScope.Engine.psm1'

Write-Host 'AuditCompat module-scope contract tests' -ForegroundColor Cyan

$compatModule = Import-Module -Name $wrapper -Force -PassThru -ErrorAction Stop
if($null -eq $compatModule) {
    throw 'AuditCompat wrapper import returned no module.'
}

$required = @(
    'Test-WSAuditCompatContract',
    'Clear-WSAuditCompatResults',
    'Get-WSAuditCompatResultCount',
    'Get-WSAuditCompatResultSlice',
    'Invoke-WSAuditCompatNumber'
)

foreach($name in $required) {
    if($null -eq $compatModule.ExportedCommands[$name]) {
        throw "Missing wrapper export: $name"
    }
}

$contract = & $compatModule.ExportedCommands['Test-WSAuditCompatContract']
if(-not $contract.DispatcherAvailable) { throw 'Internal Invoke-ModuleByNumber is not persistent in wrapper module scope.' }
if(-not $contract.ResultsAvailable) { throw 'Script:Results is not persistent in wrapper module scope.' }
if(-not $contract.BatchModeAvailable) { throw 'Script:BatchMode is not persistent in wrapper module scope.' }

& $compatModule.ExportedCommands['Clear-WSAuditCompatResults']
$count = [int](& $compatModule.ExportedCommands['Get-WSAuditCompatResultCount'])
if($count -ne 0) { throw "Expected empty Results after clear; count=$count" }

Write-Host 'PASS - AuditCompat wrapper exports' -ForegroundColor Green
Write-Host 'PASS - Internal dispatcher persists in module scope' -ForegroundColor Green
Write-Host 'PASS - Results state persists in module scope' -ForegroundColor Green
Write-Host 'PASS - BatchMode state persists in module scope' -ForegroundColor Green

Remove-Module $compatModule.Name -Force -ErrorAction SilentlyContinue

Import-Module -Name $engine -Force -ErrorAction Stop
Initialize-WSAuditCompatEngine -ProjectRoot $root
Clear-WSAuditCompatResults

Write-Host 'PASS - Engine imports and validates AuditCompat wrapper' -ForegroundColor Green
Write-Host 'PASS - Engine clear API works through wrapper command object' -ForegroundColor Green
