#requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$compatScript = Join-Path $PSScriptRoot 'WinScope.AuditCompat300.ps1'
if(-not (Test-Path -LiteralPath $compatScript)) {
    throw "AuditCompat implementation source was not found: $compatScript"
}

# Dot-source at MODULE SCRIPT SCOPE. Functions and $Script:* state from the
# compatibility implementation therefore persist for the lifetime of this module.
. $compatScript

function Test-WSAuditCompatContract {
    $dispatcher = Get-Command Invoke-ModuleByNumber -CommandType Function -ErrorAction SilentlyContinue

    [pscustomobject]@{
        DispatcherAvailable = ($null -ne $dispatcher)
        ResultsAvailable    = ($null -ne $Script:Results)
        ResultsCount        = if($null -ne $Script:Results) { [int]$Script:Results.Count } else { -1 }
        BatchModeAvailable  = ($null -ne (Get-Variable -Name BatchMode -Scope Script -ErrorAction SilentlyContinue))
    }
}

function Clear-WSAuditCompatResults {
    if($null -eq $Script:Results) {
        throw 'AuditCompat Results collection is unavailable.'
    }

    $Script:Results.Clear()
}

function Get-WSAuditCompatResultCount {
    if($null -eq $Script:Results) {
        throw 'AuditCompat Results collection is unavailable.'
    }

    return [int]$Script:Results.Count
}

function Get-WSAuditCompatResultSlice {
    param(
        [Parameter(Mandatory)][ValidateRange(0,2147483647)][int]$StartIndex
    )

    if($null -eq $Script:Results) {
        throw 'AuditCompat Results collection is unavailable.'
    }

    $count = [int]$Script:Results.Count
    if($StartIndex -ge $count) {
        return
    }

    for($i=$StartIndex; $i -lt $count; $i++) {
        $Script:Results[$i]
    }
}

function Test-WSAuditCompatPropertyContracts {
    $empty = [pscustomobject]@{}
    $partial = [pscustomobject]@{Version='4.8.1';Install=1}
    $nullValue = [pscustomobject]@{Version=$null}

    [pscustomobject]@{
        MissingVersion = [string](Get-SafePropertyValue -InputObject $empty -Name 'Version' -Default '<missing>')
        PresentVersion = [string](Get-SafePropertyValue -InputObject $partial -Name 'Version' -Default '<missing>')
        MissingRelease = [string](Get-SafePropertyValue -InputObject $partial -Name 'Release' -Default '<missing>')
        PresentInstall = [int](Get-SafePropertyValue -InputObject $partial -Name 'Install' -Default -1)
        NullVersion    = [string](Get-SafePropertyValue -InputObject $nullValue -Name 'Version' -Default '<null-default>')
        NullObject     = [string](Get-SafePropertyValue -InputObject $null -Name 'Anything' -Default '<null-object>')
    }
}

function Test-WSAuditCompatEdgeContracts {
    $oldBatchMode = $Script:BatchMode
    $Script:BatchMode = $true

    try {
        # Empty result table must not throw or shift positional arguments.
        Show-ResultTable -Data @() -Title 'Synthetic empty table'

        $emptyFiltered = @(
            @([pscustomobject]@{Status='Info'}) |
                Where-Object Status -eq 'Never'
        )
        Show-ResultTable -Data $emptyFiltered -Title 'Synthetic empty filtered table'

        $sum0 = Get-SafePropertySum -InputObject @() -Property 'Length'
        $sum1 = Get-SafePropertySum -InputObject @(
            [pscustomobject]@{Length=10},
            [pscustomobject]@{Length=20},
            [pscustomobject]@{Other=999}
        ) -Property 'Length'

        $count0 = Get-SafeCount -InputObject @()
        $count1 = Get-SafeCount -InputObject @([pscustomobject]@{A=1})

        $missingPath = Join-Path $env:TEMP ('WinScopeMissing_' + [guid]::NewGuid().ToString('N'))
        $missingSize = Get-FolderSizeSafe -Path $missingPath

        [pscustomobject]@{
            EmptyTable      = 'PASS'
            EmptyFilter     = 'PASS'
            EmptySum        = [long]$sum0
            MultiSum        = [long]$sum1
            EmptyCount      = [int]$count0
            SingleCount     = [int]$count1
            MissingPathSize = [long]$missingSize
        }
    }
    finally {
        $Script:BatchMode = $oldBatchMode
    }
}

function Invoke-WSAuditCompatNumber {
    param(
        [Parameter(Mandatory)][ValidateRange(1,300)][int]$Number
    )

    $dispatcher = Get-Command Invoke-ModuleByNumber -CommandType Function -ErrorAction SilentlyContinue
    if($null -eq $dispatcher) {
        throw 'AuditCompat internal dispatcher Invoke-ModuleByNumber is unavailable in module scope.'
    }

    $Script:BatchMode = $true
    try {
        # The internal dispatcher is always forced to report-only by the Safe Audit build.
        Invoke-ModuleByNumber -Number $Number -ReportOnly 6>$null | Out-Null
    }
    finally {
        $Script:BatchMode = $false
    }
}

Export-ModuleMember -Function `
    Test-WSAuditCompatContract,
    Clear-WSAuditCompatResults,
    Get-WSAuditCompatResultCount,
    Get-WSAuditCompatResultSlice,
    Invoke-WSAuditCompatNumber,
    Test-WSAuditCompatEdgeContracts,
    Test-WSAuditCompatPropertyContracts
