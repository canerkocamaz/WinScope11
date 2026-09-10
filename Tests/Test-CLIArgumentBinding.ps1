#requires -Version 5.1
<#
.SYNOPSIS
    Verifies WinScope CLI argument binding without running audit modules.
#>
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'

$root=Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$script=Join-Path $root 'WinScope11.ps1'

# Parser/integrity gate.
& $script validate

# Parameter metadata gate.
$ast=$null
$tokens=$null
$errors=$null
$ast=[System.Management.Automation.Language.Parser]::ParseFile($script,[ref]$tokens,[ref]$errors)
if(@($errors).Count -gt 0){ throw 'Launcher parser errors detected.' }

$text=Get-Content -LiteralPath $script -Raw -Encoding UTF8
if($text -notmatch '\[string\[\]\]\$Target'){ throw 'Target is not string[].' }
if($text -notmatch 'ValueFromRemainingArguments\s*=\s*\$true'){ throw 'Target does not accept remaining arguments.' }
if($text -notmatch '\(\@\(\$Target\)\s+-join\s+'',''\)'){ throw 'Target normalization is missing.' }

Write-Host 'PASS - CLI binding contract is configured for quoted and unquoted comma lists.' -ForegroundColor Green
