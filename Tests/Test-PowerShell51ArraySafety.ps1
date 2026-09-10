#requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'

$root=Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$files=@(
    Get-ChildItem -LiteralPath $root -Recurse -File |
        Where-Object {$_.Extension -in @('.ps1','.psm1')}
)

$hits=@()
$pattern='\[(?:object|string|int|long)\[\]\]\s*\$\w+\s*=\s*if\s*\('

foreach($file in $files){
    $lineNo=0
    foreach($line in Get-Content -LiteralPath $file.FullName){
        $lineNo++
        if($line -match $pattern){
            $hits += [pscustomobject]@{
                File=$file.FullName
                Line=$lineNo
                Text=$line.Trim()
            }
        }
    }
}

if($hits.Count -gt 0){
    $hits | Format-Table -AutoSize -Wrap | Out-Host
    throw 'Unsafe typed-array if-expression assignment detected.'
}

Write-Host 'PASS - No unsafe typed-array if-expression assignments found.' -ForegroundColor Green
