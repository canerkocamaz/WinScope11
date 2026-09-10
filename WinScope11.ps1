#requires -Version 5.1
<#
.SYNOPSIS
    WinScope 11
.DESCRIPTION
    Modular Windows Client Health, Security & Configuration Analyzer.
    v3.1 introduces a hierarchical user-facing group catalog while preserving
    module IDs 1-500 and the Safe Audit report-only execution model.
#>

param(
    [Parameter(Position=0)]
    [ValidateSet('menu','select','run','module','group','all','modules','groups','help','validate')]
    [string]$Command = 'menu',

    [Parameter(Position=1, ValueFromRemainingArguments=$true)]
    [string[]]$Target = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

function Invoke-WSSourceParserPreflight {
    param([Parameter(Mandatory)][string]$Root)

    $sourceFiles = @(
        Get-ChildItem -LiteralPath $Root -File -Recurse -ErrorAction Stop |
            Where-Object { $_.Extension -in @('.ps1','.psm1') } |
            Sort-Object FullName
    )

    [object[]]$allErrors = @()

    foreach($file in $sourceFiles) {
        $tokens = $null
        $parseErrors = $null

        [void][System.Management.Automation.Language.Parser]::ParseFile(
            $file.FullName,
            [ref]$tokens,
            [ref]$parseErrors
        )

        foreach($e in @($parseErrors)) {
            $allErrors += [pscustomobject]@{
                File    = $file.FullName
                Line    = $e.Extent.StartLineNumber
                Column  = $e.Extent.StartColumnNumber
                ErrorId = $e.ErrorId
                Message = $e.Message
            }
        }
    }

    if($allErrors.Count -gt 0) {
        Write-Host ''
        Write-Host 'WinScope source preflight: FAILED' -ForegroundColor Red
        Write-Host ("Parser errors: {0}" -f $allErrors.Count) -ForegroundColor Red
        Write-Host ''
        $allErrors | Format-Table File,Line,Column,ErrorId,Message -Wrap | Out-Host
        throw 'WinScope source parser preflight failed. No module was executed.'
    }

    return [pscustomobject]@{
        Files  = $sourceFiles.Count
        Errors = 0
        Status = 'PASS'
    }
}

$SourcePreflight = Invoke-WSSourceParserPreflight -Root $ProjectRoot

# PowerShell treats an unquoted comma-separated value such as:
#   run 1,20,36
# as an array. Normalize both array and quoted-string forms to one text value.
$TargetText = if($null -eq $Target -or @($Target).Count -eq 0) {
    ''
} else {
    (@($Target) -join ',').Trim()
}

Write-Host ("Source preflight: PASS ({0} PowerShell files)" -f $SourcePreflight.Files) -ForegroundColor DarkGreen

$CoreRoot = Join-Path $ProjectRoot 'Core'

Import-Module (Join-Path $CoreRoot 'WinScope.Catalog.psm1') -Force
Import-Module (Join-Path $CoreRoot 'WinScope.Reporting.psm1') -Force
Import-Module (Join-Path $CoreRoot 'WinScope.Engine.psm1') -Force
Import-Module (Join-Path $CoreRoot 'WinScope.Console.psm1') -Force

$ConfigPath = Join-Path $ProjectRoot 'Config\winscope.json'
$Config = Get-Content -LiteralPath $ConfigPath -Raw -Encoding UTF8 | ConvertFrom-Json

$Modules = @(Get-WSModuleCatalog -ProjectRoot $ProjectRoot)
$Groups  = @(Get-WSGroupCatalog -Modules $Modules)

$BaseReportDir = [Environment]::ExpandEnvironmentVariables([string]$Config.Reporting.BaseDirectory)
if(-not (Test-Path -LiteralPath $BaseReportDir)){
    New-Item -Path $BaseReportDir -ItemType Directory -Force | Out-Null
}

function Invoke-WSSelection {
    param(
        [Parameter(Mandatory)][int[]]$Ids,
        [string]$Mode='Selected'
    )

    $selected = @(
        foreach($id in $Ids){
            $m=$Modules | Where-Object Id -eq $id | Select-Object -First 1
            if($m){$m}
        }
    )

    if($selected.Count -eq 0){
        Write-Host 'No modules selected.' -ForegroundColor Yellow
        return
    }

    $session = New-WSRunSession -BaseReportDir $BaseReportDir -SelectedModules $selected -Mode $Mode
    Clear-WSAuditCompatResults

    Write-WSHeader -ModuleCount $Modules.Count -GroupCount $Groups.Count -Subtitle 'Running Selected Modules'
    Write-Host (" Run ID : {0}" -f $session.RunId) -ForegroundColor DarkGray
    Write-Host (" Reports: {0}" -f $session.Path) -ForegroundColor DarkGray
    Write-Host ' Mode   : REPORT-ONLY' -ForegroundColor Green
    Write-Host ''

    [object[]]$allRecords = @()
    [object[]]$executions = @()

    $current=0
    foreach($module in $selected){
        $current++
        Write-WSRunProgress -Current $current -Total $selected.Count -ModuleName $module.Name -State 'Running'

        $result = Invoke-WSModuleProbe -Module $module -ProjectRoot $ProjectRoot -RunId $session.RunId

        if($null -eq $result -or -not ($result.PSObject.Properties.Name -contains 'RawRecords')) {
            $result = New-WSProbeResult `
                -ExecutionStatus 'Failed' `
                -ErrorMessage 'Engine returned an invalid result contract.' `
                -Duration ([timespan]::Zero) `
                -RawRecords @()
        }

        [object[]]$rawRecords = @($result.RawRecords | Where-Object { $null -ne $_ })
        $normalized = @(
            foreach($raw in $rawRecords){
                ConvertTo-WSNormalizedRecord -Record $raw -Module $module -RunId $session.RunId
            }
        )
        if($normalized.Count -gt 0){ $allRecords += $normalized }

        [void](Save-WSModuleReport -Session $session -Module $module -Records $normalized `
            -ExecutionStatus $result.ExecutionStatus -ErrorMessage $result.ErrorMessage -Duration $result.Duration)

        $execution = [pscustomobject]@{
            ModuleId        = [int]$module.Id
            ModuleName      = [string]$module.Name
            Group           = [string]$module.Group
            MainGroupCode   = [string]$module.MainGroupCode
            MainGroupName   = [string]$module.MainGroupName
            SubGroupCode    = [string]$module.SubGroupCode
            SubGroupName    = [string]$module.SubGroupName
            LeafGroupCode   = [string]$module.LeafGroupCode
            LeafGroupName   = [string]$module.LeafGroupName
            ExecutionStatus = [string]$result.ExecutionStatus
            ErrorMessage    = [string]$result.ErrorMessage
            DurationMs      = [math]::Round($result.Duration.TotalMilliseconds,2)
            RecordCount     = [int]$normalized.Count
        }
        $executions += $execution

        Write-WSRunProgress -Current $current -Total $selected.Count -ModuleName $module.Name -State $result.ExecutionStatus

        if($result.ExecutionStatus -eq 'Failed') {
            Write-Host ("     Error: {0}" -f $result.ErrorMessage) -ForegroundColor Red
            Write-Host ''
        }
    }

    $combined = Save-WSCombinedReport -Session $session -Records $allRecords -ModuleExecutions $executions
    $hierarchyReports = Save-WSHierarchyReports -Session $session -Records $allRecords -ModuleExecutions $executions

    Write-Host ''
    Write-Host ('='*78) -ForegroundColor Green
    Write-Host ' WinScope run completed' -ForegroundColor Green
    Write-Host ('='*78) -ForegroundColor Green
    Write-Host (" Selected modules   : {0}" -f $selected.Count)
    Write-Host (" Failed modules     : {0}" -f @($executions | Where-Object ExecutionStatus -eq 'Failed').Count)
    Write-Host (" Result records     : {0}" -f $allRecords.Count)
    Write-Host (" Hierarchy reports  : {0}" -f $hierarchyReports.ReportCount)
    Write-Host (" Report directory   : {0}" -f $session.Path) -ForegroundColor Cyan
    Write-Host (" HTML report        : {0}" -f $combined.Html) -ForegroundColor Cyan
    Write-Host (" Hierarchy directory: {0}" -f $hierarchyReports.Root) -ForegroundColor Cyan
}

function Test-WSProjectIntegrity {
    [string[]]$issues = @()

    if($Modules.Count -ne 500) {
        $issues += ("Expected 500 modules, found {0}." -f $Modules.Count)
    }

    $ids = @($Modules | Select-Object -ExpandProperty Id | Sort-Object)
    if($ids.Count -ne 500 -or $ids[0] -ne 1 -or $ids[-1] -ne 500 -or @($ids | Select-Object -Unique).Count -ne 500) {
        $issues += 'Module IDs are not a unique contiguous 1-500 set.'
    }

    $audit = @($Modules | Where-Object Adapter -eq 'AuditCompat300')
    $native = @($Modules | Where-Object Adapter -eq 'Native')

    if($audit.Count -ne 300) {
        $issues += ("Expected 300 AuditCompat modules, found {0}." -f $audit.Count)
    }
    if($native.Count -ne 200) {
        $issues += ("Expected 200 Native modules, found {0}." -f $native.Count)
    }

    foreach($m in $audit) {
        if(-not ($m.PSObject.Properties.Name -contains 'CompatId') -or [int]$m.CompatId -ne [int]$m.Id) {
            $issues += ("AuditCompat descriptor mismatch at module {0}." -f $m.Id)
        }
    }

    foreach($m in $native) {
        if(-not ($m.PSObject.Properties.Name -contains 'Invoke') -or $m.Invoke -isnot [scriptblock]) {
            $issues += ("Native module {0} has no valid Invoke scriptblock." -f $m.Id)
        }
    }

    if($Groups.Count -ne 8) {
        $issues += ("Expected 8 main groups, found {0}." -f $Groups.Count)
    }

    $hierarchyPath = Join-Path $ProjectRoot 'Config\hierarchy.json'
    if(-not (Test-Path -LiteralPath $hierarchyPath)) {
        $issues += 'Hierarchy configuration is missing.'
    } else {
        $h = Get-Content -LiteralPath $hierarchyPath -Raw -Encoding UTF8 | ConvertFrom-Json
        if(@($h.Mappings).Count -ne 38) {
            $issues += ("Expected 38 hierarchy mappings, found {0}." -f @($h.Mappings).Count)
        }
    }

    $compatPath = Join-Path $ProjectRoot 'AuditCompat\WinScope.AuditCompat300.ps1'
    if(-not (Test-Path -LiteralPath $compatPath)) {
        $issues += 'AuditCompat engine source is missing.'
    }

    if($issues.Count -gt 0) {
        Write-Host ''
        Write-Host 'WinScope project validation: FAILED' -ForegroundColor Red
        foreach($i in $issues) {
            Write-Host (" - {0}" -f $i) -ForegroundColor Red
        }
        throw 'WinScope project integrity validation failed.'
    }

    Write-Host ''
    Write-Host 'WinScope project validation: PASS' -ForegroundColor Green
    Write-Host (" PowerShell parser files : {0}" -f $SourcePreflight.Files)
    Write-Host (" Modules                 : {0}" -f $Modules.Count)
    Write-Host (" AuditCompat             : {0}" -f $audit.Count)
    Write-Host (" Native                  : {0}" -f $native.Count)
    Write-Host (" Main groups             : {0}" -f $Groups.Count)
    Write-Host ' Module IDs              : 1-500 unique/contiguous'
    Write-Host ' Descriptor contracts    : PASS'
    Write-Host ' Hierarchy mappings      : PASS'
    Write-Host ''

    return $true
}

function Show-WSHelp {
    Write-WSHeader -ModuleCount $Modules.Count -GroupCount $Groups.Count -Subtitle 'Help'

    Write-Host 'Interactive menu:' -ForegroundColor White
    Write-Host '  S                  Browse groups using local numbers'
    Write-Host '  A                  Run all 500 modules'
    Write-Host '  M                  List all modules'
    Write-Host '  R                  Show report directory'
    Write-Host '  H                  Show this help'
    Write-Host '  Q                  Quit'
    Write-Host ''
    Write-Host 'Inside S:' -ForegroundColor White
    Write-Host '  1, 2, 3...         Choose the displayed group/subgroup/category'
    Write-Host '  A                  Run every module in the current branch'
    Write-Host '  M                  List modules in the current branch'
    Write-Host '  B                  Go back one level'
    Write-Host '  Q                  Leave module selection'
    Write-Host ''
    Write-Host 'At the final module list, enter the REAL module ID:' -ForegroundColor White
    Write-Host '  36                 Run module 36'
    Write-Host '  36,41,460          Run multiple IDs when they are in the displayed category'
    Write-Host '  36-40              Run an ID range when those IDs are in the displayed category'
    Write-Host ''
    Write-Host 'PowerShell CLI (kept for automation / future EXE wrapper):' -ForegroundColor White
    Write-Host '  .\WinScope11.ps1 help'
    Write-Host '  .\WinScope11.ps1 module 36'
    Write-Host '  .\WinScope11.ps1 run 36,41,460        # unquoted supported'
    Write-Host '  .\WinScope11.ps1 run "36,41,460"      # quoted also supported'
    Write-Host '  .\WinScope11.ps1 run 36-40'
    Write-Host '  .\WinScope11.ps1 group 3'
    Write-Host '  .\WinScope11.ps1 group 3.2'
    Write-Host '  .\WinScope11.ps1 group 3.2.1'
    Write-Host '  .\WinScope11.ps1 all'
    Write-Host '  .\WinScope11.ps1 modules'
    Write-Host '  .\WinScope11.ps1 groups'
    Write-Host '  .\WinScope11.ps1 validate'
    Write-Host ''
    Write-Host 'Reports: per-module + combined + main/sub/leaf hierarchy reports.' -ForegroundColor Green
}

function Show-WSAllGroups {
    Write-WSHeader -ModuleCount $Modules.Count -GroupCount $Groups.Count -Subtitle 'Group Reference'

    $orderedMain=@($Groups | Sort-Object Id)
    for($i=0; $i -lt $orderedMain.Count; $i++) {
        $g=$orderedMain[$i]
        Write-Host (" {0}. {1} ({2} modules)" -f ($i+1),$g.Name,$g.ModuleCount) -ForegroundColor White

        $subs=@(Get-WSSubGroupCatalog -Modules $Modules -MainGroupCode $g.Code)
        for($j=0; $j -lt $subs.Count; $j++) {
            $s=$subs[$j]
            Write-Host ("      {0}. {1} ({2} modules)" -f ($j+1),$s.Name,$s.ModuleCount) -ForegroundColor Gray

            $leafs=@(Get-WSLeafGroupCatalog -Modules $Modules -SubGroupCode $s.Code)
            for($k=0; $k -lt $leafs.Count; $k++) {
                $l=$leafs[$k]
                Write-Host ("           {0}. {1} ({2} modules)" -f ($k+1),$l.Name,$l.ModuleCount) -ForegroundColor DarkGray
            }
        }
        Write-Host ''
    }
}

function Show-WSMainMenu {
    while($true) {
        Write-WSHeader -ModuleCount $Modules.Count -GroupCount $Groups.Count

        Write-Host '   [S] Browse groups / select module(s)' -ForegroundColor White
        Write-Host '   [A] Run all 500 modules (report-only)'
        Write-Host '   [M] List modules'
        Write-Host '   [R] Reports location'
        Write-Host '   [H] Help'
        Write-Host '   [Q] Quit'
        Write-Host ''
        Write-Host ' Direct module execution is also available here:' -ForegroundColor DarkGray
        Write-Host '   36 | 36,41,460 | 36-40' -ForegroundColor Cyan
        Write-Host ''

        $choice = (Read-Host 'Selection').Trim()
        if([string]::IsNullOrWhiteSpace($choice)){continue}
        if($choice -match '^(?i:Q)$'){return}

        if($choice -match '^(?i:S)$') {
            $ids = @(Select-WSModulesInteractive -Modules $Modules -Groups $Groups)
            if($ids.Count -gt 0){Invoke-WSSelection -Ids $ids -Mode 'Selected'}
            Read-Host 'Press Enter to continue' | Out-Null
            continue
        }

        if($choice -match '^(?i:A)$') {
            Invoke-WSSelection -Ids @($Modules.Id) -Mode 'All'
            Read-Host 'Press Enter to continue' | Out-Null
            continue
        }

        if($choice -match '^(?i:M)$') {
            Write-WSHeader -ModuleCount $Modules.Count -GroupCount $Groups.Count -Subtitle 'Module Catalog'
            Show-WSCompactModuleList -Modules $Modules
            continue
        }

        if($choice -match '^(?i:R)$') {
            Write-Host ("Reports: {0}" -f $BaseReportDir) -ForegroundColor Cyan
            Read-Host 'Press Enter to continue' | Out-Null
            continue
        }

        if($choice -match '^(?i:H)$') {
            Show-WSHelp
            Read-Host 'Press Enter to continue' | Out-Null
            continue
        }

        $parsed = Resolve-WSModuleIds -Expression $choice -Modules $Modules
        if($parsed.Invalid.Count -gt 0) {
            Write-Host ("Invalid module ID(s): {0}" -f ($parsed.Invalid -join ', ')) -ForegroundColor Yellow
        }

        if($parsed.Ids.Count -gt 0) {
            Invoke-WSSelection -Ids @($parsed.Ids) -Mode 'Direct-ID'
        } else {
            Write-Host 'Unknown selection. Type H for help.' -ForegroundColor Yellow
        }

        Read-Host 'Press Enter to continue' | Out-Null
    }
}

switch($Command){
    'menu'   { Show-WSMainMenu }
    'select' {
        $ids=@(Select-WSModulesInteractive -Modules $Modules -Groups $Groups)
        if($ids.Count -gt 0){Invoke-WSSelection -Ids $ids -Mode 'Selected'}
    }
    'run' {
        if([string]::IsNullOrWhiteSpace($TargetText)){throw 'Target module IDs are required.'}
        $parsed=Resolve-WSModuleIds -Expression $TargetText -Modules $Modules
        if($parsed.Invalid.Count -gt 0){Write-Host ("Invalid module ID(s): {0}" -f ($parsed.Invalid -join ', ')) -ForegroundColor Yellow}
        Invoke-WSSelection -Ids @($parsed.Ids) -Mode 'CLI-Selected'
    }
    'module' {
        $n=0
        if(-not [int]::TryParse($TargetText,[ref]$n)){throw 'A numeric module ID is required.'}
        Invoke-WSSelection -Ids @($n) -Mode 'Single'
    }
    'group' {
        if([string]::IsNullOrWhiteSpace($TargetText)){throw 'Hierarchy group code required, e.g. 3, 3.2, or 3.2.1'}
        $node=@(Get-WSModulesByHierarchyTarget -Modules $Modules -Target $TargetText)
        Invoke-WSSelection -Ids @($node|Select-Object -ExpandProperty Id) -Mode ("Hierarchy:G{0}" -f $TargetText)
    }
    'all'     { Invoke-WSSelection -Ids @($Modules.Id) -Mode 'All' }
    'modules' { Show-WSCompactModuleList -Modules $Modules }
    'groups'  { Show-WSAllGroups }
    'help'     { Show-WSHelp }
    'validate' { [void](Test-WSProjectIntegrity) }
}
