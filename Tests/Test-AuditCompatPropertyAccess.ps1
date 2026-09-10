#requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'

$root=Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$wrapper=Join-Path $root 'AuditCompat\WinScope.AuditCompat300.psm1'

Write-Host 'AuditCompat optional-property contract tests' -ForegroundColor Cyan

$m=Import-Module -Name $wrapper -Force -PassThru -ErrorAction Stop
$cmd=$m.ExportedCommands['Test-WSAuditCompatPropertyContracts']
if($null -eq $cmd){throw 'Property contract export missing.'}
$r=& $cmd

if($r.MissingVersion -ne '<missing>'){throw 'Missing property default failed.'}
if($r.PresentVersion -ne '4.8.1'){throw 'Present Version failed.'}
if($r.MissingRelease -ne '<missing>'){throw 'Missing Release failed.'}
if($r.PresentInstall -ne 1){throw 'Install property failed.'}
if($r.NullVersion -ne '<null-default>'){throw 'Null property default failed.'}
if($r.NullObject -ne '<null-object>'){throw 'Null object default failed.'}

Write-Host 'PASS - Missing property default contract' -ForegroundColor Green
Write-Host 'PASS - Present property value contract' -ForegroundColor Green
Write-Host 'PASS - Null property/object contract' -ForegroundColor Green
