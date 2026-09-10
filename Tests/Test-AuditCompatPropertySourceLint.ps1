#requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'

$root=Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$audit=Join-Path $root 'AuditCompat\WinScope.AuditCompat300.ps1'
$text=Get-Content -LiteralPath $audit -Raw -Encoding UTF8

function Get-FunctionSource {
    param([string]$Name,[string]$NextName)
    $start=$text.IndexOf("function $Name")
    if($start -lt 0){throw "Function not found: $Name"}
    $end=if($NextName){$text.IndexOf("function $NextName",$start+1)}else{-1}
    if($end -lt 0){$end=$text.Length}
    return $text.Substring($start,$end-$start)
}

$issues=@()

$dotnet=Get-FunctionSource 'Invoke-ScanDotNetFramework' 'Invoke-ScanAppx'
foreach($bad in @('\$p\.Version','\$p\.Release','\$p\.Install')){
    if($dotnet -match $bad){$issues += "Unsafe .NET property access: $bad"}
}

$proxy=Get-FunctionSource 'Invoke-ScanVpnProxy' 'Invoke-ScanComponentStore'
foreach($bad in @('\$p\.ProxyEnable','\$p\.ProxyServer','\$p\.AutoConfigURL')){
    if($proxy -match $bad){$issues += "Unsafe proxy property access: $bad"}
}

$pending=Get-FunctionSource 'Invoke-ScanPendingReboot' 'Invoke-ScanWer'
if($pending -match '\$session\.PendingFileRenameOperations'){
    $issues += 'Unsafe PendingFileRenameOperations access.'
}

$rdp=Get-FunctionSource 'Invoke-ScanRemoteDesktop' 'Invoke-ScanWinRm'
if($rdp -match '\$ts\.fDenyTSConnections'){
    $issues += 'Unsafe fDenyTSConnections access.'
}

if($text -notmatch 'function\s+Get-SafePropertyValue'){
    $issues += 'Get-SafePropertyValue helper missing.'
}

if($issues.Count -gt 0){
    foreach($i in $issues){Write-Host ("FAIL - {0}" -f $i) -ForegroundColor Red}
    throw 'Optional-property source lint failed.'
}

Write-Host 'PASS - Optional registry property accesses are guarded.' -ForegroundColor Green
