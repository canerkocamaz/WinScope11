#requires -Version 5.1
<#
.SYNOPSIS
    Runs WinScope parser and catalog/integrity gates without executing audit modules.
#>
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$launcher = Join-Path $root 'WinScope11.ps1'

if(-not (Test-Path -LiteralPath $launcher)) {
    throw "WinScope launcher not found: $launcher"
}

Write-Host 'WinScope validation suite' -ForegroundColor Cyan
Write-Host ("Root: {0}" -f $root) -ForegroundColor DarkGray
Write-Host ''

& $launcher validate

Write-Host ''
Write-Host ''
$genericLint = Join-Path $root 'Tests\Test-NoGenericListProduction.ps1'
& $genericLint

Write-Host ''
$compatCollections = Join-Path $root 'Tests\Test-AuditCompatCollectionContracts.ps1'
& $compatCollections

$arraySafety = Join-Path $root 'Tests\Test-PowerShell51ArraySafety.ps1'
& $arraySafety

Write-Host ''
$propertyLint = Join-Path $root 'Tests\Test-AuditCompatPropertySourceLint.ps1'
& $propertyLint

Write-Host ''
$propertyContracts = Join-Path $root 'Tests\Test-AuditCompatPropertyAccess.ps1'
& $propertyContracts

Write-Host ''
$edgeLint = Join-Path $root 'Tests\Test-AuditCompatEdgeSourceLint.ps1'
& $edgeLint

Write-Host ''
$edgeCases = Join-Path $root 'Tests\Test-AuditCompatEdgeCases.ps1'
& $edgeCases

Write-Host ''
$scopeContract = Join-Path $root 'Tests\Test-AuditCompatModuleScope.ps1'
& $scopeContract

Write-Host ''
$contract = Join-Path $root 'Tests\Test-CoreRuntimeContracts.ps1'
& $contract

Write-Host ''
Write-Host 'Validation suite completed successfully.' -ForegroundColor Green
