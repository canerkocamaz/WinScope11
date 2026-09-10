Set-StrictMode -Version Latest

function ConvertTo-WSSafeFileName {
    param([Parameter(Mandatory)][string]$Text)
    $name = $Text -replace '[^A-Za-z0-9._-]+','-'
    return $name.Trim('-')
}

function New-WSRunSession {
    param(
        [Parameter(Mandatory)][string]$BaseReportDir,
        [Parameter(Mandatory)][object[]]$SelectedModules,
        [string]$Mode = 'Selected'
    )

    $stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $runId = [guid]::NewGuid().ToString('N').Substring(0,8)
    $path = Join-Path $BaseReportDir ("{0}_{1}" -f $stamp,$runId)
    $modulePath = Join-Path $path 'modules'

    New-Item -Path $path -ItemType Directory -Force | Out-Null
    New-Item -Path $modulePath -ItemType Directory -Force | Out-Null

    $session = [pscustomobject]@{
        RunId           = $runId
        Started         = Get-Date
        Completed       = $null
        Mode            = $Mode
        Path            = $path
        ModuleReportDir = $modulePath
        SelectedModules = @($SelectedModules | Select-Object Id,Name,Group,SourceGroupName,MainGroupCode,MainGroupName,SubGroupCode,SubGroupName,LeafGroupCode,LeafGroupName,Flags,Risk)
    }

    $session.SelectedModules |
        ConvertTo-Json -Depth 5 |
        Set-Content -LiteralPath (Join-Path $path 'selected-modules.json') -Encoding UTF8

    return $session
}

function ConvertTo-WSNormalizedRecord {
    param(
        [Parameter(Mandatory)][object]$Record,
        [Parameter(Mandatory)][object]$Module,
        [Parameter(Mandatory)][string]$RunId
    )

    function Get-WSPropValue {
        param([object]$Object,[string]$Name,[object]$Default=$null)
        if ($null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name) {
            return $Object.$Name
        }
        return $Default
    }

    $sizeBytes = Get-WSPropValue -Object $Record -Name 'SizeBytes' -Default $null
    $timestamp = Get-WSPropValue -Object $Record -Name 'Timestamp' -Default (Get-Date)

    [pscustomobject]@{
        RunId          = $RunId
        Timestamp      = $timestamp
        ModuleId       = [int]$Module.Id
        ModuleName     = [string]$Module.Name
        Group          = [string]$Module.Group
        MainGroupCode  = [string]$Module.MainGroupCode
        MainGroupName  = [string]$Module.MainGroupName
        SubGroupCode   = [string]$Module.SubGroupCode
        SubGroupName   = [string]$Module.SubGroupName
        LeafGroupCode  = [string]$Module.LeafGroupCode
        LeafGroupName  = [string]$Module.LeafGroupName
        Category       = [string](Get-WSPropValue -Object $Record -Name 'Category' -Default '')
        Item           = [string](Get-WSPropValue -Object $Record -Name 'Item' -Default '')
        Status         = [string](Get-WSPropValue -Object $Record -Name 'Status' -Default 'Info')
        SizeBytes      = $sizeBytes
        Size           = [string](Get-WSPropValue -Object $Record -Name 'Size' -Default '')
        Details        = [string](Get-WSPropValue -Object $Record -Name 'Details' -Default '')
        Recommendation = [string](Get-WSPropValue -Object $Record -Name 'Recommendation' -Default '')
    }
}


function Save-WSModuleReport {
    param(
        [Parameter(Mandatory)][object]$Session,
        [Parameter(Mandatory)][object]$Module,
        [AllowNull()][AllowEmptyCollection()][object[]]$Records = @(),
        [string]$ExecutionStatus = 'Completed',
        [string]$ErrorMessage = '',
        [timespan]$Duration = ([timespan]::Zero)
    )

    $safeName = ConvertTo-WSSafeFileName -Text $Module.Name
    $baseName = "{0:D3}-{1}" -f [int]$Module.Id,$safeName
    $jsonPath = Join-Path $Session.ModuleReportDir ($baseName + '.json')
    $txtPath  = Join-Path $Session.ModuleReportDir ($baseName + '.txt')

    $payload = [ordered]@{
        RunId           = $Session.RunId
        ModuleId        = [int]$Module.Id
        ModuleName      = [string]$Module.Name
        Group           = [string]$Module.Group
        MainGroupCode   = [string]$Module.MainGroupCode
        MainGroupName   = [string]$Module.MainGroupName
        SubGroupCode    = [string]$Module.SubGroupCode
        SubGroupName    = [string]$Module.SubGroupName
        LeafGroupCode   = [string]$Module.LeafGroupCode
        LeafGroupName   = [string]$Module.LeafGroupName
        Flags           = [string]$Module.Flags
        Risk            = [string]$Module.Risk
        ExecutionStatus = $ExecutionStatus
        ErrorMessage    = $ErrorMessage
        DurationMs      = [math]::Round($Duration.TotalMilliseconds,2)
        RecordCount     = @($Records).Count
        Generated       = Get-Date
        Records         = @($Records)
    }

    $payload |
        ConvertTo-Json -Depth 8 |
        Set-Content -LiteralPath $jsonPath -Encoding UTF8

    $lines = New-Object System.Collections.ArrayList
    [void]$lines.Add('WinScope 11 - Per Module Report')
    [void]$lines.Add(('=' * 78))
    [void]$lines.Add(("Run ID      : {0}" -f $Session.RunId))
    [void]$lines.Add(("Module      : {0:D3} - {1}" -f [int]$Module.Id,$Module.Name))
    [void]$lines.Add(("Hierarchy   : G{0} {1} > G{2} {3} > G{4} {5}" -f $Module.MainGroupCode,$Module.MainGroupName,$Module.SubGroupCode,$Module.SubGroupName,$Module.LeafGroupCode,$Module.LeafGroupName))
    [void]$lines.Add(("Status      : {0}" -f $ExecutionStatus))
    [void]$lines.Add(("Duration    : {0:N0} ms" -f $Duration.TotalMilliseconds))
    [void]$lines.Add(("Record count: {0}" -f @($Records).Count))
    if ($ErrorMessage) { [void]$lines.Add(("Error       : {0}" -f $ErrorMessage)) }
    [void]$lines.Add('')

    if (@($Records).Count -eq 0) {
        [void]$lines.Add('No finding records were returned by this module.')
    } else {
        foreach ($r in @($Records)) {
            [void]$lines.Add(('-' * 78))
            [void]$lines.Add(("Status : {0}" -f $r.Status))
            [void]$lines.Add(("Item   : {0}" -f $r.Item))
            if ($r.Size) { [void]$lines.Add(("Size   : {0}" -f $r.Size)) }
            if ($r.Details) { [void]$lines.Add(("Details: {0}" -f $r.Details)) }
            if ($r.Recommendation) { [void]$lines.Add(("Advice : {0}" -f $r.Recommendation)) }
        }
    }

    $lines | Set-Content -LiteralPath $txtPath -Encoding UTF8

    return [pscustomobject]@{
        Json = $jsonPath
        Text = $txtPath
    }
}

function Save-WSCombinedReport {
    param(
        [Parameter(Mandatory)][object]$Session,
        [AllowNull()][AllowEmptyCollection()][object[]]$Records = @(),
        [Parameter(Mandatory)][object[]]$ModuleExecutions
    )

    $Session.Completed = Get-Date
    $records = @($Records)

    $csvPath  = Join-Path $Session.Path 'results.csv'
    $jsonPath = Join-Path $Session.Path 'results.json'
    $txtPath  = Join-Path $Session.Path 'results.txt'
    $htmlPath = Join-Path $Session.Path 'results.html'
    $runPath  = Join-Path $Session.Path 'run.json'

    if($records.Count -gt 0){
        $records | Export-Csv -LiteralPath $csvPath -NoTypeInformation -Encoding UTF8
    } else {
        'RunId,Timestamp,ModuleId,ModuleName,Group,MainGroupCode,MainGroupName,SubGroupCode,SubGroupName,LeafGroupCode,LeafGroupName,Category,Item,Status,SizeBytes,Size,Details,Recommendation' | Set-Content -LiteralPath $csvPath -Encoding UTF8
    }
    ConvertTo-Json -InputObject @($records) -Depth 8 | Set-Content -LiteralPath $jsonPath -Encoding UTF8

    $summary = [ordered]@{
        RunId           = $Session.RunId
        Started         = $Session.Started
        Completed       = $Session.Completed
        DurationSeconds = [math]::Round(($Session.Completed-$Session.Started).TotalSeconds,2)
        Mode            = $Session.Mode
        SelectedCount   = @($Session.SelectedModules).Count
        CompletedCount  = @($ModuleExecutions | Where-Object ExecutionStatus -eq 'Completed').Count
        FailedCount     = @($ModuleExecutions | Where-Object ExecutionStatus -eq 'Failed').Count
        RecordCount     = $records.Count
        ReportPath      = $Session.Path
        Modules         = @($ModuleExecutions)
    }
    $summary | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $runPath -Encoding UTF8

    $txt = New-Object System.Collections.ArrayList
    [void]$txt.Add('WinScope 11 - Combined Run Report')
    [void]$txt.Add(('=' * 90))
    [void]$txt.Add(("Run ID          : {0}" -f $Session.RunId))
    [void]$txt.Add(("Mode            : {0}" -f $Session.Mode))
    [void]$txt.Add(("Started         : {0}" -f $Session.Started))
    [void]$txt.Add(("Completed       : {0}" -f $Session.Completed))
    [void]$txt.Add(("Selected modules: {0}" -f $summary.SelectedCount))
    [void]$txt.Add(("Failed modules  : {0}" -f $summary.FailedCount))
    [void]$txt.Add(("Result records  : {0}" -f $summary.RecordCount))
    [void]$txt.Add('')
    foreach($e in $ModuleExecutions) {
        [void]$txt.Add(("{0:D3}  {1,-42} {2,-10} {3,8:N0} ms  records={4}" -f `
            [int]$e.ModuleId,$e.ModuleName,$e.ExecutionStatus,[double]$e.DurationMs,[int]$e.RecordCount))
    }
    [void]$txt.Add('')
    foreach($r in $records) {
        [void]$txt.Add(('-' * 90))
        [void]$txt.Add(("[{0:D3}] {1} | {2} | {3}" -f [int]$r.ModuleId,$r.ModuleName,$r.Status,$r.Item))
        if($r.Details){[void]$txt.Add(("  Details: {0}" -f $r.Details))}
        if($r.Recommendation){[void]$txt.Add(("  Advice : {0}" -f $r.Recommendation))}
    }
    $txt | Set-Content -LiteralPath $txtPath -Encoding UTF8

    $statusGroups = @($records | Group-Object Status | Sort-Object Count -Descending)
    $statusHtml = if($statusGroups.Count -gt 0) {
        ($statusGroups | ForEach-Object {
            "<span class='badge'><b>$([System.Net.WebUtility]::HtmlEncode($_.Name))</b>: $($_.Count)</span>"
        }) -join ' '
    } else { "<span class='badge'>No finding records</span>" }

    $rows = foreach($r in $records) {
        "<tr><td>{0:D3}</td><td>{1}</td><td>{2}</td><td>{3}</td><td>{4}</td><td>{5}</td></tr>" -f `
            [int]$r.ModuleId,
            [System.Net.WebUtility]::HtmlEncode([string]$r.ModuleName),
            [System.Net.WebUtility]::HtmlEncode([string]$r.Status),
            [System.Net.WebUtility]::HtmlEncode([string]$r.Item),
            [System.Net.WebUtility]::HtmlEncode([string]$r.Details),
            [System.Net.WebUtility]::HtmlEncode([string]$r.Recommendation)
    }

    $html = @"
<!doctype html>
<html><head><meta charset="utf-8">
<title>WinScope 11 Report - $($Session.RunId)</title>
<style>
body{font-family:Segoe UI,Arial,sans-serif;background:#111820;color:#e7edf3;margin:0;padding:28px}
h1{color:#43d17a;margin-bottom:4px}.sub{color:#9ba9b5;margin-bottom:22px}
.card{background:#18232d;border:1px solid #2c3a45;border-radius:8px;padding:16px;margin-bottom:16px}
.badge{display:inline-block;background:#243440;border-radius:14px;padding:6px 10px;margin:3px}
table{width:100%;border-collapse:collapse;font-size:13px}th,td{border-bottom:1px solid #2b3944;padding:8px;vertical-align:top;text-align:left}
th{color:#72d99b}.muted{color:#8fa0ad}
</style></head>
<body>
<h1>WinScope 11</h1>
<div class="sub">Windows Client Health, Security &amp; Configuration Analyzer</div>
<div class="card">
<b>Run:</b> $($Session.RunId) &nbsp; <b>Mode:</b> $($Session.Mode) &nbsp;
<b>Selected:</b> $($summary.SelectedCount) &nbsp; <b>Failed:</b> $($summary.FailedCount) &nbsp;
<b>Records:</b> $($summary.RecordCount)<br><br>$statusHtml
</div>
<div class="card">
<table><thead><tr><th>ID</th><th>Module</th><th>Status</th><th>Item</th><th>Details</th><th>Recommendation</th></tr></thead>
<tbody>$($rows -join "`n")</tbody></table>
</div>
<div class="muted">Generated $([System.Net.WebUtility]::HtmlEncode([string]$Session.Completed))</div>
</body></html>
"@
    $html | Set-Content -LiteralPath $htmlPath -Encoding UTF8

    return [pscustomobject]@{
        Csv=$csvPath; Json=$jsonPath; Text=$txtPath; Html=$htmlPath; Run=$runPath
    }
}


function Save-WSHierarchyNodeReport {
    param(
        [Parameter(Mandatory)][object]$Session,
        [Parameter(Mandatory)][string]$Level,
        [Parameter(Mandatory)][string]$Code,
        [Parameter(Mandatory)][string]$Name,
        [AllowNull()][AllowEmptyCollection()][object[]]$Records=@(),
        [AllowNull()][AllowEmptyCollection()][object[]]$ModuleExecutions=@()
    )

    $safeName = ConvertTo-WSSafeFileName -Text $Name
    $root = Join-Path $Session.Path 'hierarchy'
    $levelDir = Join-Path $root $Level.ToLowerInvariant()
    New-Item -Path $levelDir -ItemType Directory -Force | Out-Null

    $baseName = "G{0}-{1}" -f ($Code -replace '\.','-'),$safeName
    $csvPath  = Join-Path $levelDir ($baseName + '.csv')
    $jsonPath = Join-Path $levelDir ($baseName + '.json')
    $txtPath  = Join-Path $levelDir ($baseName + '.txt')
    $htmlPath = Join-Path $levelDir ($baseName + '.html')

    $records = @($Records)
    $execs = @($ModuleExecutions)

    if($records.Count -gt 0) {
        $records | Export-Csv -LiteralPath $csvPath -NoTypeInformation -Encoding UTF8
    } else {
        'RunId,Timestamp,ModuleId,ModuleName,MainGroupCode,MainGroupName,SubGroupCode,SubGroupName,LeafGroupCode,LeafGroupName,Category,Item,Status,SizeBytes,Size,Details,Recommendation' |
            Set-Content -LiteralPath $csvPath -Encoding UTF8
    }

    $payload = [ordered]@{
        RunId          = $Session.RunId
        Level          = $Level
        Code           = $Code
        Name           = $Name
        ModuleCount    = $execs.Count
        FailedModules  = @($execs | Where-Object ExecutionStatus -eq 'Failed').Count
        RecordCount    = $records.Count
        Generated      = Get-Date
        ModuleExecutions = $execs
        Records        = $records
    }
    $payload | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $jsonPath -Encoding UTF8

    $lines = New-Object System.Collections.ArrayList
    [void]$lines.Add('WinScope 11 - Hierarchy Report')
    [void]$lines.Add(('='*90))
    [void]$lines.Add(("Level         : {0}" -f $Level))
    [void]$lines.Add(("Code          : G{0}" -f $Code))
    [void]$lines.Add(("Name          : {0}" -f $Name))
    [void]$lines.Add(("Modules       : {0}" -f $execs.Count))
    [void]$lines.Add(("Failed modules: {0}" -f @($execs | Where-Object ExecutionStatus -eq 'Failed').Count))
    [void]$lines.Add(("Records       : {0}" -f $records.Count))
    [void]$lines.Add('')
    foreach($e in $execs) {
        [void]$lines.Add(("{0:D3}  {1,-44} {2,-10} records={3}" -f [int]$e.ModuleId,$e.ModuleName,$e.ExecutionStatus,[int]$e.RecordCount))
    }
    [void]$lines.Add('')
    foreach($r in $records) {
        [void]$lines.Add(('-'*90))
        [void]$lines.Add(("[{0:D3}] {1} | {2} | {3}" -f [int]$r.ModuleId,$r.ModuleName,$r.Status,$r.Item))
        if($r.Details){[void]$lines.Add(("  Details: {0}" -f $r.Details))}
        if($r.Recommendation){[void]$lines.Add(("  Advice : {0}" -f $r.Recommendation))}
    }
    $lines | Set-Content -LiteralPath $txtPath -Encoding UTF8

    $rows = foreach($r in $records) {
        "<tr><td>{0:D3}</td><td>{1}</td><td>{2}</td><td>{3}</td><td>{4}</td></tr>" -f `
            [int]$r.ModuleId,
            [System.Net.WebUtility]::HtmlEncode([string]$r.ModuleName),
            [System.Net.WebUtility]::HtmlEncode([string]$r.Status),
            [System.Net.WebUtility]::HtmlEncode([string]$r.Item),
            [System.Net.WebUtility]::HtmlEncode([string]$r.Details)
    }

    $html = @"
<!doctype html>
<html><head><meta charset="utf-8">
<title>WinScope 11 - G$Code $Name</title>
<style>
body{font-family:Segoe UI,Arial,sans-serif;background:#111820;color:#e7edf3;margin:0;padding:28px}
h1{color:#43d17a}.sub{color:#9ba9b5}.card{background:#18232d;border:1px solid #2c3a45;border-radius:8px;padding:16px;margin:16px 0}
table{width:100%;border-collapse:collapse;font-size:13px}th,td{border-bottom:1px solid #2b3944;padding:8px;text-align:left;vertical-align:top}
th{color:#72d99b}
</style></head><body>
<h1>WinScope 11</h1>
<div class="sub">$Level report — G$Code $([System.Net.WebUtility]::HtmlEncode($Name))</div>
<div class="card">Modules: $($execs.Count) &nbsp; Failed: $(@($execs|Where-Object ExecutionStatus -eq 'Failed').Count) &nbsp; Records: $($records.Count)</div>
<div class="card"><table><thead><tr><th>ID</th><th>Module</th><th>Status</th><th>Item</th><th>Details</th></tr></thead><tbody>$($rows -join "`n")</tbody></table></div>
</body></html>
"@
    $html | Set-Content -LiteralPath $htmlPath -Encoding UTF8

    return [pscustomobject]@{Csv=$csvPath;Json=$jsonPath;Text=$txtPath;Html=$htmlPath}
}

function Save-WSHierarchyReports {
    param(
        [Parameter(Mandatory)][object]$Session,
        [AllowNull()][AllowEmptyCollection()][object[]]$Records=@(),
        [Parameter(Mandatory)][object[]]$ModuleExecutions
    )

    $records = @($Records)
    $execs = @($ModuleExecutions)
    $root = Join-Path $Session.Path 'hierarchy'
    New-Item -Path $root -ItemType Directory -Force | Out-Null

    [object[]]$index = @()

    foreach($level in @('MainGroup','SubGroup','LeafGroup')) {
        $codeProp = $level + 'Code'
        $nameProp = $level + 'Name'

        $codes = @(
            $execs |
                Select-Object -ExpandProperty $codeProp -Unique |
                Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) } |
                Sort-Object
        )

        foreach($code in $codes) {
            $nodeExec = @($execs | Where-Object { [string]($_.$codeProp) -eq [string]$code })
            if($nodeExec.Count -eq 0) { continue }
            $name = [string]$nodeExec[0].$nameProp
            $nodeRecords = @($records | Where-Object { [string]($_.$codeProp) -eq [string]$code })

            $paths = Save-WSHierarchyNodeReport -Session $Session -Level $level -Code ([string]$code) -Name $name -Records $nodeRecords -ModuleExecutions $nodeExec
            $index += [pscustomobject]@{
                Level=$level; Code=[string]$code; Name=$name; Modules=$nodeExec.Count; Records=$nodeRecords.Count
                Csv=$paths.Csv; Json=$paths.Json; Text=$paths.Text; Html=$paths.Html
            }
        }
    }

    $indexPath = Join-Path $root 'index.json'
    $index | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $indexPath -Encoding UTF8

    return [pscustomobject]@{
        Root=$root
        Index=$indexPath
        ReportCount=$index.Count
    }
}


Export-ModuleMember -Function New-WSRunSession,ConvertTo-WSNormalizedRecord,Save-WSModuleReport,Save-WSCombinedReport,Save-WSHierarchyReports
