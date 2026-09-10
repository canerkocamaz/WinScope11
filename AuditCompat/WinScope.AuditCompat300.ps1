#requires -Version 5.1
<#
.SYNOPSIS
    Windows 11 Client Digital Detox
.DESCRIPTION
    Interactive Windows 11 client hygiene, storage, startup, network and
    system-health analyzer with safe cleanup workflows.

    Design principles:
    - Scan and report first.
    - Always preview affected records before cleanup.
    - Cleanup requires explicit user confirmation.
    - High-risk areas are report-only unless a supported Windows maintenance
      command is available and the user explicitly approves it.
    - Scan All always runs in report-only mode.
    - CSV, JSON and readable TXT reports are supported.
    - Windows PowerShell 5.1 and PowerShell 7+ are targeted.

.NOTES
    Project : Windows 11 Client Digital Detox
    Version : 2.1.0
    Language: English
#>

param(
    [Parameter(Position=0)]
    [string]$Command = 'menu',

    [Parameter(Position=1)]
    [string]$Target
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'

# ---------------------------------------------------------------------------
# UTF-8 console support
# ---------------------------------------------------------------------------
try {
    [Console]::InputEncoding  = [System.Text.UTF8Encoding]::new($false)
    [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
    $OutputEncoding = [System.Text.UTF8Encoding]::new($false)
} catch {}

# ---------------------------------------------------------------------------
# Global state
# ---------------------------------------------------------------------------
$Script:AppName    = 'WinScope 11 Audit Compatibility Engine'
$Script:Version    = '2.1.0'
$Script:Results    = New-Object System.Collections.ArrayList
$Script:RunStarted = Get-Date

$Script:BaseDir = Join-Path $env:LOCALAPPDATA 'WinScope11\AuditCompat'
$Script:LogDir  = Join-Path $Script:BaseDir 'Logs'
$Script:ReportDir = Join-Path $Script:BaseDir 'Reports'

foreach ($dir in @($Script:BaseDir, $Script:LogDir, $Script:ReportDir)) {
    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -Path $dir -ItemType Directory -Force | Out-Null
    }
}

$Script:LogFile = Join-Path $Script:LogDir ("WinScopeAuditCompat_{0:yyyyMMdd_HHmmss}.log" -f (Get-Date))
$Script:LastTextReport = $null
$Script:LastCsvReport  = $null
$Script:LastJsonReport = $null
$Script:BatchMode      = $false

# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------
function Write-Log {
    param(
        [Parameter(Mandatory)][string]$Message,
        [ValidateSet('INFO','WARN','ERROR','ACTION')][string]$Level = 'INFO'
    )

    $line = '{0:yyyy-MM-dd HH:mm:ss} [{1}] {2}' -f (Get-Date), $Level, $Message
    try { Add-Content -LiteralPath $Script:LogFile -Value $line -Encoding UTF8 } catch {}
}

function Write-BrandBanner {
    param([string]$Section)

    Clear-Host

    $logo = @(
        '  ____  _       _ _        _   ____       _             ',
        ' |  _ \(_) __ _(_) |_ __ _| | |  _ \  ___| |_ _____  __ ',
        ' | | | | |/ _` | | __/ _` | | | | | |/ _ \ __/ _ \ \/ / ',
        ' | |_| | | (_| | | || (_| | | | |_| |  __/ || (_) >  <  ',
        ' |____/|_|\__, |_|\__\__,_|_| |____/ \___|\__\___/_/\_\ ',
        '          |___/                                           '
    )

    foreach ($line in $logo) {
        Write-Host $line -ForegroundColor Green
    }

    Write-Host '  Windows 11 Client Health, Security & Digital Detox Toolkit' -ForegroundColor DarkGreen
    Write-Host ("  v{0}  |  {1} modules  |  Preview-first cleanup" -f $Script:Version,$Script:ModuleCatalog.Count) -ForegroundColor DarkGray
    Write-Host ''

    if ($Section) {
        Write-Host ("  {0}" -f $Section) -ForegroundColor Cyan
        Write-Host ('  ' + ('-' * 72)) -ForegroundColor DarkGray
        Write-Host ''
    }
}

function Write-SectionLabel {
    param(
        [Parameter(Mandatory)][string]$Text,
        [ConsoleColor]$Color = [ConsoleColor]::White
    )

    Write-Host $Text -ForegroundColor $Color
    Write-Host ('-' * 78) -ForegroundColor DarkGray
}

function Show-CommandHelp {
    Write-BrandBanner -Section 'COMMAND REFERENCE'

    Write-Host 'Usage:' -ForegroundColor White
    Write-Host '  .\\Windows11_Client_Digital_Detox_v1.9_Windows_Health_Security.ps1 [COMMAND] [TARGET]' -ForegroundColor Gray
    Write-Host ''

    Write-Host 'Commands:' -ForegroundColor White
    Write-Host '  menu                     Open the interactive grouped console UI'
    Write-Host '  scan-all                 Scan all modules in report-only mode'
    Write-Host '  scan-group <id|name>     Scan one group in report-only mode'
    Write-Host '  module <id>              Run one module interactively'
    Write-Host '  list-groups              Print all scan groups'
    Write-Host '  list-modules             Print all modules and internal IDs'
    Write-Host '  findings                 Show current attention findings'
    Write-Host '  report                   Export current in-memory results'
    Write-Host '  progress-test            Test spinner and progress-bar rendering'
    Write-Host '  help                     Print this help screen'
    Write-Host ''

    Write-Host 'Examples:' -ForegroundColor White
    Write-Host '  .\\Windows11_Client_Digital_Detox_v1.9_Windows_Health_Security.ps1 scan-all' -ForegroundColor DarkGray
    Write-Host '  .\\Windows11_Client_Digital_Detox_v1.9_Windows_Health_Security.ps1 scan-group 5' -ForegroundColor DarkGray
    Write-Host '  .\\Windows11_Client_Digital_Detox_v1.9_Windows_Health_Security.ps1 module 75' -ForegroundColor DarkGray
}

function Show-CliGroupList {
    Write-BrandBanner -Section 'SCAN GROUPS'
    foreach ($g in $Script:GroupCatalog) {
        $count = @($Script:ModuleCatalog | Where-Object Group -eq $g.Name).Count
        Write-Host ("  [{0,2}] {1,-34} {2,2} modules" -f $g.No,$g.Name,$count) -ForegroundColor White
        Write-Host ("       {0}" -f $g.Description) -ForegroundColor DarkGray
    }
}

function Show-CliModuleList {
    Write-BrandBanner -Section 'MODULES'
    $Script:ModuleCatalog |
        Sort-Object No |
        Select-Object @{N='ID';E={$_.No}},Group,Name,Flags |
        Format-Table -Wrap -AutoSize |
        Out-Host
}

function Resolve-DetoxGroup {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) { return $null }

    if ($Value -match '^\d+$') {
        $id = [int]$Value
        return $Script:GroupCatalog | Where-Object No -eq $id | Select-Object -First 1
    }

    $exact = $Script:GroupCatalog | Where-Object Name -eq $Value | Select-Object -First 1
    if ($exact) { return $exact }

    return $Script:GroupCatalog |
        Where-Object { $_.Name -like ("*{0}*" -f $Value) } |
        Select-Object -First 1
}

function Invoke-DetoxCommand {
    param(
        [string]$CommandName,
        [string]$CommandTarget
    )

    $cmd = if ([string]::IsNullOrWhiteSpace($CommandName)) { 'menu' } else { $CommandName.Trim().ToLowerInvariant() }

    switch ($cmd) {
        'menu' { Show-MainMenu; return }
        'help' { Show-CommandHelp; return }
        '--help' { Show-CommandHelp; return }
        '-h' { Show-CommandHelp; return }
        'list-groups' { Show-CliGroupList; return }
        'list-modules' { Show-CliModuleList; return }
        'scan-all' { Invoke-ScanAll; return }
        'progress-test' { Test-ProgressIndicators; return }
        'findings' {
            Show-ResultRows -Rows @(Get-AttentionResults -Rows @($Script:Results)) -Title 'Attention Findings'
            return
        }
        'report' { Export-DetoxReport; return }
        'module' {
            if ($CommandTarget -notmatch '^\d+$') {
                Write-Host 'module requires a numeric module ID.' -ForegroundColor Red
                Show-CommandHelp
                return
            }
            $id = [int]$CommandTarget
            if (-not ($Script:ModuleCatalog | Where-Object No -eq $id)) {
                Write-Host ("Unknown module ID: {0}" -f $id) -ForegroundColor Red
                return
            }
            Invoke-InteractiveModule -Number $id
            return
        }
        'scan-group' {
            $group = Resolve-DetoxGroup -Value $CommandTarget
            if (-not $group) {
                Write-Host ("Unknown group: {0}" -f $CommandTarget) -ForegroundColor Red
                Show-CliGroupList
                return
            }
            $numbers = @($Script:ModuleCatalog | Where-Object Group -eq $group.Name | Select-Object -ExpandProperty No)
            Invoke-ScanSelection -Numbers $numbers -Title ("Scanning Group: {0}" -f $group.Name)
            return
        }
        default {
            Write-Host ("Unknown command: {0}" -f $CommandName) -ForegroundColor Red
            Show-CommandHelp
        }
    }
}

function Write-Title {
    param([string]$Title)

    if ($Script:BatchMode) {
        # Batch mode owns the progress display. Individual module titles are
        # suppressed so they cannot overwrite the live progress line.
        return
    }

    Clear-Host
    $w = 78
    Write-Host ('=' * $w) -ForegroundColor Cyan
    Write-Host ("  {0}" -f $Script:AppName) -ForegroundColor Cyan
    Write-Host ("  Version {0}" -f $Script:Version) -ForegroundColor DarkGray
    Write-Host ('=' * $w) -ForegroundColor Cyan
    if ($Title) {
        Write-Host ''
        Write-Host ("  {0}" -f $Title) -ForegroundColor Yellow
        Write-Host ('-' * $w) -ForegroundColor DarkGray
    }
}

function Pause-Detox {
    Write-Host ''
    [void](Read-Host 'Press Enter to continue')
}

function Test-IsAdministrator {
    try {
        $identity  = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = [Security.Principal.WindowsPrincipal]::new($identity)
        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } catch {
        return $false
    }
}

function Confirm-Action {
    param(
        [Parameter(Mandatory)][string]$Question,
        [switch]$HighRisk
    )

    Write-Host ''
    if ($HighRisk) {
        Write-Host 'WARNING: This action can change system configuration.' -ForegroundColor Red
        $token = Read-Host "$Question Type YES to continue"
        return ($token -ceq 'YES')
    }

    $answer = Read-Host "$Question [Y/N]"
    return ($answer -match '^(?i:y|yes)$')
}

function Format-Bytes {
    param([Nullable[long]]$Bytes)

    if ($null -eq $Bytes) { return 'Unknown' }
    $b = [double]$Bytes
    if ($b -ge 1TB) { return ('{0:N2} TB' -f ($b / 1TB)) }
    if ($b -ge 1GB) { return ('{0:N2} GB' -f ($b / 1GB)) }
    if ($b -ge 1MB) { return ('{0:N2} MB' -f ($b / 1MB)) }
    if ($b -ge 1KB) { return ('{0:N2} KB' -f ($b / 1KB)) }
    return ('{0:N0} B' -f $b)
}

function Get-SafeCount {
    param(
        [AllowNull()]
        [AllowEmptyCollection()]
        [object[]]$InputObject = @()
    )

    if($null -eq $InputObject) {
        return 0
    }

    return [int]@($InputObject | Where-Object { $null -ne $_ }).Count
}

function Get-SafePropertyValue {
    param(
        [AllowNull()][object]$InputObject,
        [Parameter(Mandatory)][string]$Name,
        [AllowNull()][object]$Default = $null
    )

    if($null -eq $InputObject) { return $Default }

    try {
        $property = $InputObject.PSObject.Properties[$Name]
        if($null -eq $property -or $null -eq $property.Value) {
            return $Default
        }
        return $property.Value
    }
    catch {
        return $Default
    }
}

function Get-SafePropertySum {
    param(
        [AllowNull()]
        [AllowEmptyCollection()]
        [object[]]$InputObject = @(),

        [Parameter(Mandatory)]
        [string]$Property
    )

    [long]$total = 0L

    foreach($item in @($InputObject)) {
        if($null -eq $item) { continue }

        $prop = $item.PSObject.Properties[$Property]
        if($null -eq $prop) { continue }
        if($null -eq $prop.Value) { continue }

        try {
            $total += [long]$prop.Value
        }
        catch {
            # Non-numeric property values are ignored by this aggregation helper.
        }
    }

    return $total
}

function Test-PathSafe {
    param(
        [Parameter(Mandatory)][string]$Path
    )

    try {
        return [bool](Test-Path -LiteralPath $Path -ErrorAction SilentlyContinue)
    }
    catch {
        return $false
    }
}

function Get-FolderSizeSafe {
    param([Parameter(Mandatory)][string]$Path)

    if(-not (Test-PathSafe -Path $Path)) {
        return 0L
    }

    try {
        [object[]]$files = @(
            Get-ChildItem -LiteralPath $Path -File -Force -Recurse -ErrorAction SilentlyContinue
        )

        return [long](Get-SafePropertySum -InputObject $files -Property 'Length')
    }
    catch {
        return 0L
    }
}

function Add-Result {
    param(
        [Parameter(Mandatory)][int]$Module,
        [Parameter(Mandatory)][string]$Category,
        [Parameter(Mandatory)][string]$Item,
        [string]$Status = 'Info',
        [string]$Details = '',
        [string]$Recommendation = '',
        [Nullable[long]]$SizeBytes = $null
    )

    $obj = [pscustomobject]@{
        Timestamp      = Get-Date
        Module         = $Module
        Category       = $Category
        Item           = $Item
        Status         = $Status
        SizeBytes      = $SizeBytes
        Size           = Format-Bytes $SizeBytes
        Details        = $Details
        Recommendation = $Recommendation
    }
    [void]$Script:Results.Add($obj)
    return $obj
}

function Show-ResultTable {
    param(
        [AllowNull()]
        [AllowEmptyCollection()]
        [object[]]$Data = @(),
        [string]$Title = 'Results'
    )

    [object[]]$rows = @()
    if($null -ne $Data) {
        $rows = @($Data | Where-Object { $null -ne $_ })
    }
    [int]$rowCount = Get-SafeCount -InputObject $rows

    if ($Script:BatchMode) {
        Write-Host ("    {0}: {1} record(s)" -f $Title,$rowCount) -ForegroundColor DarkGray
        return
    }

    Write-Host ''
    Write-Host $Title -ForegroundColor Green
    Write-Host ('-' * 78) -ForegroundColor DarkGray

    if ($rowCount -eq 0) {
        Write-Host 'No records found.' -ForegroundColor DarkGray
        return
    }

    $rows |
        Select-Object Item, Status, Size, Details, Recommendation |
        Format-Table -Wrap -AutoSize |
        Out-Host
}

function Show-AllCurrentResults {
    Write-Title 'All Current Result Records'

    $rows = @($Script:Results)
    if ($rows.Count -eq 0) {
        Write-Host 'There are no in-memory scan results yet.' -ForegroundColor Yellow
        return
    }

    Write-Host ("Total records: {0}" -f $rows.Count) -ForegroundColor Cyan
    Write-Host ''

    $view = @(
        $rows |
            Select-Object Timestamp,Module,Category,Item,Status,Size,Details,Recommendation
    )

    if ($view.Count -gt 35) {
        Write-Host 'Paged view is enabled. Use Space/Enter to continue or Q to close the view.' -ForegroundColor DarkGray
        Write-Host ''
        $view | Format-Table -Wrap -AutoSize | Out-Host -Paging
    } else {
        $view | Format-Table -Wrap -AutoSize | Out-Host
    }
}


function Show-DeletionPreview {
    param(
        [AllowNull()]
        [AllowEmptyCollection()]
        [object[]]$Data = @(),
        [string]$Title = 'Cleanup Preview',
        [Nullable[long]]$TotalBytes = $null,
        [switch]$UsePaging
    )

    Write-Host ''
    Write-Host ('=' * 78) -ForegroundColor Yellow
    Write-Host ("  {0}" -f $Title) -ForegroundColor Yellow
    Write-Host ('=' * 78) -ForegroundColor Yellow

    [object[]]$items = @()
    if($null -ne $Data) {
        $items = @($Data | Where-Object { $null -ne $_ })
    }
    [int]$itemCount = Get-SafeCount -InputObject $items

    if ($itemCount -eq 0) {
        Write-Host 'No records are available for cleanup.' -ForegroundColor DarkGray
        return
    }

    Write-Host ("Total records: {0}" -f $itemCount) -ForegroundColor Cyan
    if ($null -ne $TotalBytes) {
        Write-Host ("Total size: {0}" -f (Format-Bytes $TotalBytes)) -ForegroundColor Cyan
    }

    Write-Host ''
    Write-Host 'The records below have NOT been deleted yet.' -ForegroundColor Green
    Write-Host 'Review the list. Cleanup confirmation will be requested after the preview.' -ForegroundColor DarkGray
    Write-Host ''

    if ($UsePaging -and $itemCount -gt 30) {
        Write-Host 'The list is long, so paged output will be used.' -ForegroundColor DarkGray
        Write-Host 'Use Space/Enter to continue or Q to close the paged view.' -ForegroundColor DarkGray
        Write-Host ''
        $items | Format-Table -Wrap -AutoSize | Out-Host -Paging
    } else {
        $items | Format-Table -Wrap -AutoSize | Out-Host
    }

    Write-Host ''
    Write-Host ('-' * 78) -ForegroundColor DarkGray
    Write-Host 'END OF PREVIEW - nothing has been deleted yet.' -ForegroundColor Green
}

function Get-RegistryDefaultValueSafe {
    param([Parameter(Mandatory)][string]$LiteralPath)

    try {
        $item = Get-Item -LiteralPath $LiteralPath -ErrorAction Stop
        return $item.GetValue('', $null, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
    } catch {
        return $null
    }
}

function Test-PathTargetFromCommand {
    param([string]$Command)

    if ([string]::IsNullOrWhiteSpace($Command)) { return $null }

    $expanded = [Environment]::ExpandEnvironmentVariables($Command.Trim())

    # Tırnaklı executable/script yolu.
    if ($expanded -match '^\s*"([^\"]+?\.(?i:exe|com|bat|cmd|ps1|vbs|js))"(?:\s|$)') {
        return $Matches[1].Trim()
    }

    # Tırnaksız ve boşluk içerebilen Windows yolu.
    # Örn: C:\Program Files\Vendor\App\app.exe --background
    if ($expanded -match '^\s*(.+?\.(?i:exe|com|bat|cmd|ps1|vbs|js))(?:\s|$)') {
        return $Matches[1].Trim().Trim('"')
    }

    # Sadece dosya adı verilmiş olabilir.
    if ($expanded -match '^\s*([^\s\"]+\.(?i:exe|com|bat|cmd))(?:\s|$)') {
        $name = $Matches[1].Trim()
        try {
            $resolved = Get-Command -Name $name -CommandType Application -ErrorAction Stop | Select-Object -First 1
            if ($resolved -and $resolved.Source) { return [string]$resolved.Source }
        } catch {}
        return $name
    }

    return $null
}

function Test-ExecutableTargetExists {
    param([AllowNull()][string]$Target)

    if ([string]::IsNullOrWhiteSpace($Target)) { return $null }

    $expanded = [Environment]::ExpandEnvironmentVariables($Target.Trim().Trim('"'))

    if (Test-Path -LiteralPath $expanded -PathType Leaf -ErrorAction SilentlyContinue) {
        return $true
    }

    if (-not [System.IO.Path]::IsPathRooted($expanded)) {
        try {
            $resolved = Get-Command -Name $expanded -CommandType Application -ErrorAction Stop | Select-Object -First 1
            if ($resolved) { return $true }
        } catch {}
    }

    return $false
}

function Test-CommandAvailable {
    param([Parameter(Mandatory)][string]$Name)
    return ($null -ne (Get-Command -Name $Name -ErrorAction SilentlyContinue))
}


function Get-ConsoleLineWidth {
    try {
        $width = [Console]::WindowWidth
        if ($width -lt 40) { return 100 }
        return [math]::Min(180, $width - 1)
    } catch {
        return 100
    }
}

function Write-DirectConsole {
    param(
        [Parameter(Mandatory)][string]$Text,
        [ConsoleColor]$Color = [ConsoleColor]::Cyan,
        [switch]$NewLine
    )

    try {
        $oldColor = [Console]::ForegroundColor
        [Console]::ForegroundColor = $Color

        if ($NewLine) {
            [Console]::WriteLine($Text)
        } else {
            [Console]::Write($Text)
        }

        [Console]::Out.Flush()
        [Console]::ForegroundColor = $oldColor
    } catch {
        if ($NewLine) {
            Write-Host $Text -ForegroundColor Cyan
        } else {
            Write-Host $Text -NoNewline -ForegroundColor Cyan
        }
    }
}

function Write-SpinnerFrame {
    param(
        [Parameter(Mandatory)][string]$Activity,
        [int]$Step = 0
    )

    $frames = @('|','/','-','\')
    $frame = $frames[$Step % $frames.Count]
    $width = Get-ConsoleLineWidth

    $text = ("[{0}] {1}..." -f $frame,$Activity)
    if ($text.Length -gt ($width - 1)) {
        $text = $text.Substring(0, [math]::Max(1,$width - 4)) + '...'
    }

    # Pad the line so remnants of the previous, longer frame disappear.
    $padded = $text.PadRight($width - 1)
    Write-DirectConsole -Text ("`r{0}" -f $padded) -Color Cyan
}

function Complete-Spinner {
    param(
        [Parameter(Mandatory)][string]$Activity,
        [string]$Result = 'done'
    )

    $width = Get-ConsoleLineWidth
    $text = ("[OK] {0} - {1}" -f $Activity,$Result)
    if ($text.Length -gt ($width - 1)) {
        $text = $text.Substring(0, [math]::Max(1,$width - 4)) + '...'
    }

    Write-DirectConsole -Text ("`r{0}" -f $text.PadRight($width - 1)) -Color Green -NewLine
}

function Write-ScanProgress {
    param(
        [Parameter(Mandatory)][int]$Current,
        [Parameter(Mandatory)][int]$Total,
        [Parameter(Mandatory)][string]$Activity,
        [switch]$Transient
    )

    if ($Total -le 0) { return }

    $safeCurrent = [math]::Min($Total,[math]::Max(0,$Current))
    $pct = [math]::Min(100,[math]::Max(0,[math]::Floor(($safeCurrent / $Total) * 100)))

    # User-visible text bar.
    $barWidth = 22
    $filled = [math]::Floor(($pct / 100) * $barWidth)
    $bar = ('#' * $filled) + ('-' * ($barWidth - $filled))
    $line = ("[{0}] {1,3}%  {2}/{3}  {4}" -f $bar,$pct,$safeCurrent,$Total,$Activity)

    # Native PowerShell progress display as a second, independent visual path.
    try {
        if ($safeCurrent -ge $Total) {
            Write-Progress -Activity 'Windows 11 Client Digital Detox' -Completed
        } else {
            Write-Progress -Activity 'Windows 11 Client Digital Detox' `
                -Status ("{0} ({1}/{2})" -f $Activity,$safeCurrent,$Total) `
                -PercentComplete $pct
        }
    } catch {}

    $width = Get-ConsoleLineWidth
    if ($line.Length -gt ($width - 1)) {
        $line = $line.Substring(0,[math]::Max(1,$width - 4)) + '...'
    }

    if ($Transient) {
        Write-DirectConsole -Text ("`r{0}" -f $line.PadRight($width - 1)) -Color Cyan
    } else {
        # Completed progress is deliberately persistent: each completed module
        # leaves one visible progress-bar line in the console.
        Write-DirectConsole -Text ("`r{0}" -f $line.PadRight($width - 1)) -Color Green -NewLine
    }
}

function Test-ProgressIndicators {
    Write-Title 'Progress Indicator Test'

    Write-Host 'Spinner test (about 2 seconds):' -ForegroundColor Yellow
    for ($i = 0; $i -lt 16; $i++) {
        Write-SpinnerFrame -Activity 'Testing live spinner' -Step $i
        Start-Sleep -Milliseconds 125
    }
    Complete-Spinner -Activity 'Testing live spinner'

    Write-Host ''
    Write-Host 'Progress-bar test:' -ForegroundColor Yellow
    for ($i = 0; $i -le 10; $i++) {
        $current = $i
        Write-ScanProgress -Current $current -Total 10 `
            -Activity ("Progress test step {0}" -f $current) `
            -Transient:($current -lt 10)
        Start-Sleep -Milliseconds 120
    }

    try { Write-Progress -Activity 'Windows 11 Client Digital Detox' -Completed } catch {}

    Write-Host ''
    Write-Host 'If you saw the rotating | / - \ spinner and the [####----] bar, your console supports both indicators.' -ForegroundColor Green
}

function Invoke-JobWithSpinner {
    param(
        [Parameter(Mandatory)][scriptblock]$ScriptBlock,
        [object[]]$ArgumentList = @(),
        [Parameter(Mandatory)][string]$Activity
    )

    $job = $null
    try {
        $job = Start-Job -ScriptBlock $ScriptBlock -ArgumentList $ArgumentList -ErrorAction Stop
        $step = 0

        # Paint immediately before the first state refresh so even short jobs
        # display at least an initial activity frame.
        Write-SpinnerFrame -Activity $Activity -Step $step

        while ($job.State -eq 'Running' -or $job.State -eq 'NotStarted') {
            Start-Sleep -Milliseconds 120
            $step++
            Write-SpinnerFrame -Activity $Activity -Step $step
            $job = Get-Job -Id $job.Id
        }

        Complete-Spinner -Activity $Activity
        return @(Receive-Job -Job $job -ErrorAction SilentlyContinue)
    } catch {
        Write-DirectConsole -Text '' -NewLine
        Write-Log ("Spinner job failed: {0}" -f $_.Exception.Message) 'WARN'
        throw
    } finally {
        if ($null -ne $job) {
            Remove-Job -Job $job -Force -ErrorAction SilentlyContinue
        }
    }
}


function Get-FolderSizeWithSpinner {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Activity
    )

    if(-not (Test-PathSafe -Path $Path)) {
        return 0L
    }

    try {
        [object[]]$output = @(
            Invoke-JobWithSpinner -Activity $Activity -ArgumentList @($Path) -ScriptBlock {
                param($TargetPath)

                [long]$sum = 0L
                try {
                    foreach($file in @(
                        Get-ChildItem -LiteralPath $TargetPath -File -Force -Recurse -ErrorAction SilentlyContinue
                    )) {
                        if($null -eq $file) { continue }
                        try {
                            $sum += [long]$file.Length
                        }
                        catch {}
                    }
                }
                catch {}

                [long]$sum
            }
        )

        if((Get-SafeCount -InputObject $output) -gt 0) {
            return [long]$output[-1]
        }
    }
    catch {}

    return Get-FolderSizeSafe -Path $Path
}

function Get-WindowsEnvironmentInfo {
    $info = [ordered]@{
        ComputerName = $env:COMPUTERNAME
        UserName     = $env:USERNAME
        IsAdmin      = Test-IsAdministrator
        Caption      = 'Unknown'
        Version      = 'Unknown'
        BuildNumber  = 'Unknown'
        IsWindows11  = $false
    }

    try {
        $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
        $info.Caption = [string]$os.Caption
        $info.Version = [string]$os.Version
        $info.BuildNumber = [string]$os.BuildNumber
        if ($info.Caption -match 'Windows 11' -or ([int]$os.BuildNumber -ge 22000)) {
            $info.IsWindows11 = $true
        }
    } catch {}

    return [pscustomobject]$info
}

function Get-DetoxStatusSummary {
    if ($Script:Results.Count -eq 0) { return @() }

    return @(
        $Script:Results |
            Group-Object Status |
            Sort-Object Count -Descending |
            ForEach-Object {
                [pscustomobject]@{
                    Status = $_.Name
                    Count  = $_.Count
                }
            }
    )
}

function New-DetoxTextReport {
    param([Parameter(Mandatory)][string]$Path)

    $envInfo = Get-WindowsEnvironmentInfo
    $lines = New-Object System.Collections.ArrayList

    [void]$lines.Add('===============================================================================')
    [void]$lines.Add(' WINDOWS 11 CLIENT DIGITAL DETOX REPORT')
    [void]$lines.Add('===============================================================================')
    [void]$lines.Add((' Tarih       : {0:dd.MM.yyyy HH:mm:ss}' -f (Get-Date)))
    [void]$lines.Add((' Version      : {0}' -f $Script:Version))
    [void]$lines.Add((' Computer     : {0}' -f $envInfo.ComputerName))
    [void]$lines.Add((' User         : {0}' -f $envInfo.UserName))
    [void]$lines.Add((' Operating System: {0}' -f $envInfo.Caption))
    [void]$lines.Add((' Build       : {0}' -f $envInfo.BuildNumber))
    [void]$lines.Add((' Administrator: {0}' -f $(if ($envInfo.IsAdmin) { 'YES' } else { 'NO' })))
    [void]$lines.Add((' Total Records: {0}' -f $Script:Results.Count))
    [void]$lines.Add('')

    [void]$lines.Add('STATUS SUMMARY')
    [void]$lines.Add('-------------------------------------------------------------------------------')
    $statusSummary = @(Get-DetoxStatusSummary)
    if ($statusSummary.Count -eq 0) {
        [void]$lines.Add(' No records.')
    } else {
        foreach ($s in $statusSummary) {
            [void]$lines.Add((' {0,-18} : {1}' -f $s.Status, $s.Count))
        }
    }
    [void]$lines.Add('')

    $groups = @($Script:Results | Group-Object Module, Category | Sort-Object Name)
    foreach ($group in $groups) {
        [void]$lines.Add(('--- {0} ({1} records) ---' -f $group.Name, $group.Count))
        foreach ($item in $group.Group) {
            [void]$lines.Add(('  Item         : {0}' -f $item.Item))
            [void]$lines.Add(('  Status       : {0}' -f $item.Status))
            if ($item.Size -and $item.Size -ne 'Unknown') {
                [void]$lines.Add(('  Size         : {0}' -f $item.Size))
            }
            if ($item.Details) {
                $detailText = ([string]$item.Details) -replace "`r?`n", ' | '
                [void]$lines.Add(('  Details      : {0}' -f $detailText))
            }
            if ($item.Recommendation) {
                [void]$lines.Add(('  Recommendation: {0}' -f $item.Recommendation))
            }
            [void]$lines.Add('')
        }
    }

    [void]$lines.Add('===============================================================================')
    [void]$lines.Add(' END OF REPORT')
    [void]$lines.Add('===============================================================================')

    $lines | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Open-LastDetoxReport {
    if ([string]::IsNullOrWhiteSpace([string]$Script:LastTextReport) -or
        -not (Test-Path -LiteralPath $Script:LastTextReport)) {
        Write-Host 'No TXT report has been created yet.' -ForegroundColor Yellow
        return
    }

    try {
        Start-Process -FilePath 'notepad.exe' -ArgumentList @($Script:LastTextReport) -ErrorAction Stop
    } catch {
        Write-Host ("Could not open report: {0}" -f $_.Exception.Message) -ForegroundColor Red
    }
}

function Export-DetoxReport {
    if ($Script:Results.Count -eq 0) {
        Write-Host 'There are no scan results to export yet.' -ForegroundColor Yellow
        return
    }

    $stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $csv   = Join-Path $Script:ReportDir "Detox_Report_$stamp.csv"
    $json  = Join-Path $Script:ReportDir "Detox_Report_$stamp.json"
    $txt   = Join-Path $Script:ReportDir "Detox_Report_$stamp.txt"

    try {
        $Script:Results | Export-Csv -LiteralPath $csv -NoTypeInformation -Encoding UTF8
        $Script:Results | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $json -Encoding UTF8
        New-DetoxTextReport -Path $txt

        $Script:LastCsvReport  = $csv
        $Script:LastJsonReport = $json
        $Script:LastTextReport = $txt

        Write-Log "Report exported: $csv / $json / $txt" 'ACTION'
        Write-Host "CSV : $csv" -ForegroundColor Green
        Write-Host "JSON: $json" -ForegroundColor Green
        Write-Host "TXT : $txt" -ForegroundColor Green

        Write-Host ''
        Write-Host 'Status summary:' -ForegroundColor Cyan
        @(Get-DetoxStatusSummary) | Format-Table -AutoSize | Out-Host
    } catch {
        Write-Log "Report export error: $($_.Exception.Message)" 'ERROR'
        Write-Host ("Could not create report: {0}" -f $_.Exception.Message) -ForegroundColor Red
    }
}

# ---------------------------------------------------------------------------
# 1. Startup Registry Orphans
# ---------------------------------------------------------------------------
function Invoke-ScanStartupZombies {
    Write-Title '1. Startup Registry Orphans'
    $local = New-Object System.Collections.ArrayList

    $keys = @(
        @{ Path='HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'; Scope='HKCU' },
        @{ Path='HKLM:\Software\Microsoft\Windows\CurrentVersion\Run'; Scope='HKLM' },
        @{ Path='HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run'; Scope='HKLM-32bit' }
    )

    Write-Host 'Scanning Registry Run keys...' -ForegroundColor DarkGray
    Write-Host 'Only entries whose executable target is truly missing are marked Suspicious.' -ForegroundColor DarkGray
    Write-Host ''

    foreach ($key in $keys) {
        if (-not (Test-Path -LiteralPath $key.Path)) { continue }
        $props = Get-ItemProperty -LiteralPath $key.Path -ErrorAction SilentlyContinue
        if (-not $props) { continue }

        foreach ($p in $props.PSObject.Properties) {
            if ($p.Name -match '^PS(Path|ParentPath|ChildName|Drive|Provider)$') { continue }
            $cmd = [string]$p.Value
            if ([string]::IsNullOrWhiteSpace($cmd)) { continue }

            $target = Test-PathTargetFromCommand -Command $cmd
            $status = 'Review'
            $detail = "Registry: $($key.Scope) | Command: $cmd"
            $rec = 'Command target could not be verified automatically; review manually.'

            if ($target) {
                $exists = Test-ExecutableTargetExists -Target $target
                $detail += " | Target: $target"
                if ($exists -eq $true) {
                    $status = 'Healthy'
                    $detail += ' | File exists: True'
                    $rec = 'Target exists; this is not an orphaned startup entry.'
                } elseif ($exists -eq $false) {
                    $status = 'Suspicious'
                    $detail += ' | File exists: False'
                    $rec = 'Target file is missing. Verify that the application is truly removed before deleting the registry entry.'
                }
            } else {
                $detail += ' | Target path could not be resolved.'
            }

            $r = Add-Result 1 'Startup' $p.Name $status $detail $rec
            [void]$local.Add($r)
        }
    }

    $suspicious = @($local | Where-Object Status -eq 'Suspicious')
    $review     = @($local | Where-Object Status -eq 'Review')
    $healthy    = @($local | Where-Object Status -eq 'Healthy')

    Write-Host ("Summary: Suspicious={0} | Review={1} | Healthy={2}" -f $suspicious.Count, $review.Count, $healthy.Count) -ForegroundColor Cyan
    if ($suspicious.Count -gt 0) {
        Show-ResultTable -Data $suspicious -Title 'Startup entries with missing targets'
    } else {
        Write-Host ''
        Write-Host 'No startup entry with a missing target was found.' -ForegroundColor Green
    }
    if ($review.Count -gt 0) {
        Show-ResultTable -Data $review -Title 'Startup entries requiring manual review'
    }

    Write-Host ''
    Write-Host 'Note: This module does not automatically delete startup entries.' -ForegroundColor Yellow
    return $local
}

# ---------------------------------------------------------------------------
# 2. Context Menu Orphans
# ---------------------------------------------------------------------------
function Invoke-ScanContextMenu {
    Write-Title '2. Context Menu Orphans'
    $local = New-Object System.Collections.ArrayList

    # HKCR altındaki * gerçek bir registry anahtarıdır.
    # Bu nedenle Test-Path/Get-ChildItem için mutlaka -LiteralPath kullanılır.
    $roots = @(
        @{ Path='Registry::HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers'; Kind='Handler'; Label='File ContextMenuHandlers' },
        @{ Path='Registry::HKEY_CLASSES_ROOT\*\shell'; Kind='Shell'; Label='File shell' },
        @{ Path='Registry::HKEY_CLASSES_ROOT\Directory\shellex\ContextMenuHandlers'; Kind='Handler'; Label='Directory ContextMenuHandlers' },
        @{ Path='Registry::HKEY_CLASSES_ROOT\Directory\shell'; Kind='Shell'; Label='Directory shell' }
    )

    $rootIndex = 0
    foreach ($root in $roots) {
        $rootIndex++
        Write-Host ("[{0}/{1}] Scanning {2}..." -f $rootIndex, $roots.Count, $root.Label) -ForegroundColor DarkGray
        if (-not (Test-Path -LiteralPath $root.Path)) { continue }

        $children = @(Get-ChildItem -LiteralPath $root.Path -ErrorAction SilentlyContinue)
        foreach ($key in $children) {
            $name = $key.PSChildName
            $status = 'Info'
            $detail = "Root: $($root.Path)"
            $rec = 'Verify the owning application and function before removing the entry.'

            if ($root.Kind -eq 'Handler') {
                $default = Get-RegistryDefaultValueSafe -LiteralPath $key.PSPath
                $clsid = $null
                if ($default -and ([string]$default -match '^\{[0-9A-Fa-f-]+\}$')) {
                    $clsid = [string]$default
                } elseif ($name -match '^\{[0-9A-Fa-f-]+\}$') {
                    $clsid = $name
                }

                if ($clsid) {
                    $clsidPath = "Registry::HKEY_CLASSES_ROOT\CLSID\$clsid"
                    $detail += " | CLSID: $clsid"
                    if (-not (Test-Path -LiteralPath $clsidPath)) {
                        $status = 'Suspicious'
                        $detail += ' | CLSID registration missing'
                        $rec = 'Handler CLSID is missing; this may be an orphaned entry.'
                    } else {
                        $inproc = Join-Path $clsidPath 'InprocServer32'
                        if (Test-Path -LiteralPath $inproc) {
                            $dll = Get-RegistryDefaultValueSafe -LiteralPath $inproc
                            if ($dll) {
                                $dllExpanded = [Environment]::ExpandEnvironmentVariables([string]$dll).Trim().Trim('"')
                                $detail += " | InprocServer32: $dllExpanded"
                                if ([System.IO.Path]::IsPathRooted($dllExpanded) -and -not (Test-Path -LiteralPath $dllExpanded -PathType Leaf -ErrorAction SilentlyContinue)) {
                                    $status = 'Suspicious'
                                    $detail += ' | DLL missing'
                                    $rec = 'CLSID exists but its InprocServer32 DLL is missing; review manually.'
                                }
                            }
                        }
                    }
                } else {
                    $status = 'Review'
                    $detail += ' | CLSID otomatik belirlenemedi'
                }
            } elseif ($root.Kind -eq 'Shell') {
                $commandPath = Join-Path $key.PSPath 'command'
                if (Test-Path -LiteralPath $commandPath) {
                    $command = Get-RegistryDefaultValueSafe -LiteralPath $commandPath
                    if ($command) {
                        $target = Test-PathTargetFromCommand -Command ([string]$command)
                        $detail += " | Command: $command"
                        if ($target) {
                            $exists = Test-ExecutableTargetExists -Target $target
                            $detail += " | Target: $target"
                            if ($exists -eq $false) {
                                $status = 'Suspicious'
                                $detail += ' | Target missing'
                                $rec = 'Shell command executable is missing; this may be an orphaned entry.'
                            } elseif ($exists -eq $true) {
                                $status = 'Healthy'
                                $detail += ' | Target exists'
                            } else {
                                $status = 'Review'
                            }
                        } else {
                            $status = 'Review'
                            $detail += ' | Command target could not be resolved'
                        }
                    } else {
                        $status = 'Review'
                        $detail += ' | command default value is empty'
                    }
                } else {
                    $status = 'Info'
                    $detail += ' | no direct command subkey'
                }
            }

            $r = Add-Result 2 'ContextMenu' $name $status $detail $rec
            [void]$local.Add($r)
        }
    }

    $suspicious = @($local | Where-Object Status -eq 'Suspicious')
    $review = @($local | Where-Object Status -eq 'Review')
    Write-Host ''
    Write-Host ("Scan complete. Total={0} | Suspicious={1} | Review={2}" -f $local.Count, $suspicious.Count, $review.Count) -ForegroundColor Cyan
    if ($suspicious.Count -gt 0) {
        Show-ResultTable -Data $suspicious -Title 'Suspicious Context Menu entries'
    } else {
        Write-Host 'No clear orphaned Context Menu entry was found.' -ForegroundColor Green
    }
    if ($review.Count -gt 0) {
        Show-ResultTable -Data $review -Title 'Context Menu entries requiring manual review'
    }

    Write-Host ''
    Write-Host 'Note: This module does not automatically delete Context Menu registry entries.' -ForegroundColor Yellow
    return $local
}

# ---------------------------------------------------------------------------
# 3. Windows Geçmişi (Recent Items)
# ---------------------------------------------------------------------------
function Invoke-ScanRecentItems {
    param([switch]$ReportOnly)
    Write-Title '3. File Explorer Recent Items'
    $local = New-Object System.Collections.ArrayList
    $path = Join-Path $env:APPDATA 'Microsoft\Windows\Recent'
    $cutoff = (Get-Date).AddDays(-90)

    if (-not (Test-Path $path)) {
        Write-Host 'Recent folder was not found.'
        return $local
    }

    $files = @(
        Get-ChildItem -LiteralPath $path -File -Force -ErrorAction SilentlyContinue |
            Where-Object { $_.LastWriteTime -lt $cutoff } |
            Sort-Object LastWriteTime
    )

    foreach ($f in $files) {
        $r = Add-Result 3 'RecentItems' $f.Name 'Old' `
            "Last modified: $($f.LastWriteTime)" `
            'Recent shortcut older than 90 days; it can be removed if no longer needed.' `
            $f.Length
        [void]$local.Add($r)
    }

    Show-ResultTable $local ("Recent items older than 90 days: {0}" -f $local.Count)

    if (-not $ReportOnly -and $files.Count -gt 0) {
        $preview = @(
            $files | ForEach-Object {
                [pscustomobject]@{
                    Name           = $_.Name
                    FullPath       = $_.FullName
                    LastModified   = $_.LastWriteTime
                    Size           = Format-Bytes $_.Length
                }
            }
        )

        $totalBytes = [long](Get-SafePropertySum -InputObject $files -Property 'Length')
        Show-DeletionPreview -Data $preview `
            -Title 'RECENT ITEMS TO DELETE - PREVIEW' `
            -TotalBytes $totalBytes `
            -UsePaging

        if (Confirm-Action ("Delete the {0} Recent items shown above?" -f $files.Count)) {
            $ok = 0
            $fail = 0

            foreach ($f in $files) {
                try {
                    $null = $f.FullName
                    Write-Log "Safe Audit: Recent item was not deleted: $($f.FullName)" 'INFO'
                    $ok++
                } catch {
                    Write-Log "Recent item could not be deleted: $($f.FullName) | $($_.Exception.Message)" 'ERROR'
                    $fail++
                }
            }

            Write-Host ''
            Write-Host ("Deleted: {0} | Failed/Skipped: {1}" -f $ok, $fail) -ForegroundColor Green
        } else {
            Write-Host 'Cleanup cancelled. No Recent item was deleted.' -ForegroundColor Yellow
        }
    }

    return $local
}

# ---------------------------------------------------------------------------
# 4. Geçici Dosyalar (Temp)
# ---------------------------------------------------------------------------
function Invoke-ScanTemp {
    param([switch]$ReportOnly)
    Write-Title '4. Temporary Files'
    $local = New-Object System.Collections.ArrayList
    $cutoff = (Get-Date).AddDays(-30)

    $paths = @(
        $env:TEMP,
        (Join-Path $env:WINDIR 'Temp'),
        (Join-Path $env:LOCALAPPDATA 'Temp')
    ) | Select-Object -Unique

    $candidates = New-Object System.Collections.ArrayList

    foreach ($path in $paths) {
        if (-not $path -or -not (Test-Path $path)) { continue }

        $files = @(
            Get-ChildItem -LiteralPath $path -File -Recurse -Force -ErrorAction SilentlyContinue |
                Where-Object { $_.LastWriteTime -lt $cutoff }
        )

        $bytes = [long](Get-SafePropertySum -InputObject $files -Property 'Length')

        $r = Add-Result 4 'Temp' $path 'Aday' `
            ("Files older than 30 days: {0}" -f $files.Count) `
            'Old temporary files can be cleaned; locked or active files are skipped.' `
            $bytes
        [void]$local.Add($r)

        foreach ($f in $files) { [void]$candidates.Add($f) }
    }

    Show-ResultTable $local 'Temp summary'

    if (-not $ReportOnly -and $candidates.Count -gt 0) {
        $orderedCandidates = @(
            $candidates |
                Sort-Object -Property `
                    @{ Expression = { $_.Length }; Descending = $true }, `
                    @{ Expression = { $_.LastWriteTime }; Descending = $false }
        )

        $preview = @(
            $orderedCandidates | ForEach-Object {
                [pscustomobject]@{
                    Name           = $_.Name
                    FullPath       = $_.FullName
                    LastModified   = $_.LastWriteTime
                    Size           = Format-Bytes $_.Length
                }
            }
        )

        $totalBytes = [long](Get-SafePropertySum -InputObject $orderedCandidates -Property 'Length')

        Show-DeletionPreview -Data $preview `
            -Title 'TEMP FILES TO DELETE - PREVIEW' `
            -TotalBytes $totalBytes `
            -UsePaging

        if (Confirm-Action ("Delete the {0} old Temp files shown above?" -f $orderedCandidates.Count)) {
            $ok = 0
            $fail = 0

            foreach ($f in $orderedCandidates) {
                try {
                    $null = $f.FullName
                    Write-Log "Safe Audit: Temp file was not deleted: $($f.FullName)" 'INFO'
                    $ok++
                } catch {
                    Write-Log "Temp file failed/skipped: $($f.FullName) | $($_.Exception.Message)" 'WARN'
                    $fail++
                }
            }

            Write-Log "Temp cleanup: success=$ok failed/skipped=$fail" 'ACTION'
            Write-Host ''
            Write-Host ("Deleted: {0} | Skipped/Locked: {1}" -f $ok, $fail) -ForegroundColor Green
        } else {
            Write-Host 'Cleanup cancelled. No Temp file was deleted.' -ForegroundColor Yellow
        }
    }

    return $local
}

# ---------------------------------------------------------------------------
# 5. Windows Cache Usage
# ---------------------------------------------------------------------------
function Invoke-ScanCaches {
    Write-Title '5. Windows Cache Usage'
    $local = New-Object System.Collections.ArrayList

    $cachePaths = @(
        @{ Name='Thumbnail Cache'; Path=(Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Explorer') },
        @{ Name='Microsoft Store Cache'; Path=(Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsStore_8wekyb3d8bbwe\LocalCache') },
        @{ Name='FontCache'; Path=(Join-Path $env:WINDIR 'ServiceProfiles\LocalService\AppData\Local\FontCache') },
        @{ Name='Delivery Optimization Cache'; Path=(Join-Path $env:WINDIR 'SoftwareDistribution\DeliveryOptimization') }
    )

    foreach ($c in $cachePaths) {
        $size = Get-FolderSizeSafe $c.Path
        $status = if ($size -gt 1GB) { 'Large' } elseif ($size -gt 500MB) { 'Review' } else { 'Info' }
        $detail = "Path: $($c.Path)"
        if ($size -gt 500MB) { $detail += ' | over 500 MB' }
        $r = Add-Result 5 'Cache' $c.Name $status $detail `
            'Review the size; cache cleanup should be application-aware and controlled.' $size
        [void]$local.Add($r)
    }

    # DNS cache dosya klasörü değildir; kayıt sayısı raporlanır.
    try {
        $dnsCount = @(Get-DnsClientCache -ErrorAction Stop).Count
        $r = Add-Result 5 'Cache' 'DNS Client Cache' 'Info' "Record count: $dnsCount" `
            'DNS cache cleanup is usually unnecessary unless troubleshooting.'
        [void]$local.Add($r)
    } catch {}

    Show-ResultTable $local 'Cache sizes'
    return $local
}

# ---------------------------------------------------------------------------
# 6. Hiberfil.sys
# ---------------------------------------------------------------------------
function Invoke-ScanHibernation {
    param([switch]$ReportOnly)
    Write-Title '6. Hibernation / hiberfil.sys'
    $local = New-Object System.Collections.ArrayList

    $hiber = Join-Path $env:SystemDrive 'hiberfil.sys'
    $exists = Test-Path -LiteralPath $hiber
    $size = 0L
    if ($exists) {
        try {
            $hiberItem = Get-Item -LiteralPath $hiber -Force -ErrorAction Stop
            if ($null -ne $hiberItem) { $size = [long]$hiberItem.Length }
        } catch {
            Write-Log "Could not read hiberfil.sys size: $($_.Exception.Message)" 'WARN'
        }
    }

    $hibernateEnabled = $false
    try {
        $reg = Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Power' -Name HibernateEnabled -ErrorAction Stop
        $hibernateValue = Get-SafePropertyValue -InputObject $reg -Name 'HibernateEnabled'
        $hibernateEnabled = ($null -ne $hibernateValue -and [int]$hibernateValue -ne 0)
    } catch {}

    $status = if ($exists -and $hibernateEnabled) { 'Active' } elseif ($exists) { 'Review' } else { 'Disabled/Absent' }
    $detail = "hiberfil.sys exists: $exists | HibernateEnabled: $hibernateEnabled"
    $rec = if ($hibernateEnabled) {
        'If hibernation is not required, review the supported Windows power settings.'
    } else {
        'Hibernation appears to be disabled.'
    }

    $r = Add-Result 6 'Hibernation' 'hiberfil.sys' $status $detail $rec $size
    [void]$local.Add($r)
    Show-ResultTable $local

    if (-not $ReportOnly -and $hibernateEnabled -and (Confirm-Action 'Disable hibernation? (This can also affect Fast Startup.)' -HighRisk)) {
        if (-not (Test-IsAdministrator)) {
            Write-Host 'PowerShell must be run as Administrator for this action.' -ForegroundColor Red
        } else {
            Write-Host 'Safe Audit: hibernation changes are disabled.' -ForegroundColor Yellow
            Write-Log 'Safe Audit: hibernation change was not executed.' 'INFO'
        }
    }
    return $local
}

# ---------------------------------------------------------------------------
# 7. Pagefile
# ---------------------------------------------------------------------------
function Invoke-ScanPagefile {
    Write-Title '7. Pagefile Size and Usage'
    $local = New-Object System.Collections.ArrayList

    try {
        $usage = Get-CimInstance Win32_PageFileUsage -ErrorAction Stop
        foreach ($p in $usage) {
            $allocated = [long]$p.AllocatedBaseSize * 1MB
            $current   = [long]$p.CurrentUsage * 1MB
            $peak      = [long]$p.PeakUsage * 1MB
            $pct = if ($allocated -gt 0) { [math]::Round(($current / $allocated) * 100, 1) } else { 0 }
            $r = Add-Result 7 'Pagefile' $p.Name 'Info' `
                "Allocated: $(Format-Bytes $allocated) | Usage: $(Format-Bytes $current) ($pct%) | Peak: $(Format-Bytes $peak)" `
                'There is no one-size-fits-all fixed pagefile size. Consider crash-dump, RAM, workload and commit requirements.' `
                $allocated
            [void]$local.Add($r)
        }
    } catch {
        $r = Add-Result 7 'Pagefile' 'Pagefile information' 'Error' $_.Exception.Message `
            'Verify WMI/CIM access.'
        [void]$local.Add($r)
    }

    Show-ResultTable $local
    Write-Host ''
    Write-Host 'Note: The script does not automatically change pagefile size.' -ForegroundColor Yellow
    return $local
}

# ---------------------------------------------------------------------------
# 8. Windows Update Old Sürücü Paketleri
# ---------------------------------------------------------------------------
function Invoke-ScanDrivers {
    Write-Title '8. DriverStore / OEM Driver Packages'
    $local = New-Object System.Collections.ArrayList

    $driverStorePath = Join-Path $env:WINDIR 'System32\DriverStore\FileRepository'
    if (Test-Path -LiteralPath $driverStorePath) {
        Write-Host 'Calculating DriverStore size...' -ForegroundColor DarkGray
        $driverStoreSize = Get-FolderSizeSafe $driverStorePath
        $driverStoreStatus = if ($driverStoreSize -gt 10GB) { 'Large' } elseif ($driverStoreSize -gt 5GB) { 'Review' } else { 'Info' }

        $rSize = Add-Result 8 'Drivers' 'DriverStore FileRepository total size' $driverStoreStatus `
            "Path: $driverStorePath" `
            'A large size alone does not prove stale drivers. Review with the PnPUtil inventory; never delete files directly from DriverStore.' `
            $driverStoreSize
        [void]$local.Add($rSize)
    }

    if (-not (Test-CommandAvailable 'pnputil.exe')) {
        $r = Add-Result 8 'Drivers' 'PnPUtil' 'Error' 'pnputil.exe was not found.' `
            'Verify Windows system files and the PATH environment.'
        [void]$local.Add($r)
        Show-ResultTable $local 'DriverStore / driver summary'
        return $local
    }

    try {
        $output = & pnputil.exe /enum-drivers 2>&1
        $text = $output -join [Environment]::NewLine

        # pnputil çıktısı dil bağımlıdır. Ham çıktıyı rapora ekleyerek yanlış eşleştirme
        # nedeniyle sürücü silme riskinden kaçınıyoruz.
        $count = ([regex]::Matches($text, '(?im)^\s*Published Name\s*:\s*oem\d+\.inf\s*$')).Count
        if ($count -eq 0) {
            $count = ([regex]::Matches($text, '(?im)^\s*Yayımlanan Ad\s*:\s*oem\d+\.inf\s*$')).Count
        }

        $r = Add-Result 8 'Drivers' 'PnPUtil OEM driver inventory' 'Info' `
            "Detected package count (locale-dependent count): $count`n$text" `
            'Remove old drivers only after verifying version, device usage and rollback plan.'
        [void]$local.Add($r)

        Write-Host $text
        Write-Host ''
        Write-Host 'SAFETY: This tool does not automatically remove driver packages.' -ForegroundColor Yellow
        Write-Host 'Removal can be performed with Microsoft PnPUtil; /force is especially risky.' -ForegroundColor Yellow
    } catch {
        $r = Add-Result 8 'Drivers' 'PnPUtil' 'Error' $_.Exception.Message 'Check access to pnputil.exe.'
        [void]$local.Add($r)
    }

    return $local
}

# ---------------------------------------------------------------------------
# 9. Windows Optional Features
# ---------------------------------------------------------------------------
function Invoke-ScanOptionalFeatures {
    Write-Title '9. Windows Optional Features'
    $local = New-Object System.Collections.ArrayList

    try {
        $features = Get-WindowsOptionalFeature -Online -ErrorAction Stop
        $watch = @('SMB1Protocol','TelnetClient','TFTP','MicrosoftWindowsPowerShellV2','WorkFolders-Client')

        foreach ($f in $features | Sort-Object FeatureName) {
            $status = if ($f.State -eq 'Enabled' -and $watch -contains $f.FeatureName) { 'Review' } else { [string]$f.State }
            $rec = if ($status -eq 'Review') {
                'This feature may be unnecessary on many clients; verify business/compatibility requirements.'
            } else {
                'Change only features that are truly unused.'
            }
            $r = Add-Result 9 'OptionalFeature' $f.FeatureName $status "State: $($f.State)" $rec
            [void]$local.Add($r)
        }
    } catch {
        $r = Add-Result 9 'OptionalFeature' 'Windows Features' 'Error' $_.Exception.Message `
            'Administrator rights may be required for this query.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data @($local | Where-Object Status -eq 'Review') -Title 'Enabled features to review first'
    return $local
}

# ---------------------------------------------------------------------------
# 10. Saved Wi-Fi Profiles
# ---------------------------------------------------------------------------
function Invoke-ScanWifiProfiles {
    param([switch]$ReportOnly)
    Write-Title '10. Saved Wi-Fi Profiles'
    $local = New-Object System.Collections.ArrayList

    $output = & netsh.exe wlan show profiles 2>&1
    $lines = @($output)

    $names = New-Object System.Collections.ArrayList
    foreach ($line in $lines) {
        if ($line -match '^\s*(?i:All User Profile|Tüm Kullanıcı Profili)\s*:\s*(.+?)\s*$') {
            $name = $Matches[1].Trim()
            if ($name -and -not $names.Contains($name)) {
                [void]$names.Add($name)
            }
        }
    }

    foreach ($name in $names) {
        $r = Add-Result 10 'WiFi' $name 'Info' `
            'Profile saved by Windows WLAN configuration.' `
            'netsh does not provide a reliable last-connected date; age must be verified by the user.'
        [void]$local.Add($r)
    }

    Show-ResultTable $local 'Saved Wi-Fi profiles'

    if (-not $ReportOnly -and $local.Count -gt 0) {
        $preview = @()
        for ($i = 0; $i -lt $local.Count; $i++) {
            $preview += [pscustomobject]@{
                No      = $i + 1
                Profil  = $local[$i].Item
                Status  = $local[$i].Status
                Description = 'Saved Wi-Fi profile'
            }
        }

        Show-DeletionPreview -Data $preview `
            -Title 'WI-FI PROFILES AVAILABLE FOR DELETION - PREVIEW'

        if (Confirm-Action 'Do you want to delete one of the Wi-Fi profiles shown above?') {
            $pick = Read-Host 'Profile number to delete (Enter to cancel)'
            if ($pick -match '^\d+$') {
                $idx = [int]$pick - 1
                if ($idx -ge 0 -and $idx -lt $local.Count) {
                    $profile = $local[$idx].Item

                    Write-Host ''
                    Write-Host 'Selected record:' -ForegroundColor Yellow
                    [pscustomobject]@{
                        Profil = $profile
                    } | Format-List | Out-Host

                    if (Confirm-Action "Really delete Wi-Fi profile '$profile'?" -HighRisk) {
                        Write-Host 'Safe Audit: Wi-Fi profile deletion is disabled.' -ForegroundColor Yellow
                        Write-Log "Safe Audit: Wi-Fi profile deletion was not executed: $profile" 'INFO'
                    } else {
                        Write-Host 'Deletion cancelled.' -ForegroundColor Yellow
                    }
                } else {
                    Write-Host 'Invalid profile number. Nothing was deleted.' -ForegroundColor Yellow
                }
            } else {
                Write-Host 'Selection cancelled. Nothing was deleted.' -ForegroundColor Yellow
            }
        } else {
            Write-Host 'Cleanup cancelled. No Wi-Fi profile was deleted.' -ForegroundColor Yellow
        }
    }

    return $local
}

# ---------------------------------------------------------------------------
# 11. Bluetooth Device Inventory
# ---------------------------------------------------------------------------
function Invoke-ScanBluetooth {
    Write-Title '11. Bluetooth Device Inventory'
    $local = New-Object System.Collections.ArrayList

    try {
        $devices = Get-PnpDevice -Class Bluetooth -ErrorAction Stop
        foreach ($d in $devices) {
            $displayName = [string]$d.FriendlyName
            if ([string]::IsNullOrWhiteSpace($displayName)) {
                $displayName = [string]$d.InstanceId
            }
            $r = Add-Result 11 'Bluetooth' $displayName ([string]$d.Status) `
                "InstanceId: $($d.InstanceId)" `
                'PnP inventory does not provide a reliable last-used date. Staleness must be verified by the user.'
            [void]$local.Add($r)
        }
    } catch {
        $r = Add-Result 11 'Bluetooth' 'Bluetooth envanteri' 'Error' $_.Exception.Message `
            'Check access to the Get-PnpDevice cmdlet.'
        [void]$local.Add($r)
    }

    Show-ResultTable $local
    Write-Host 'This tool does not automatically remove Bluetooth devices.' -ForegroundColor Yellow
    return $local
}

# ---------------------------------------------------------------------------
# 12. Defender Dışlama Artıkları
# ---------------------------------------------------------------------------
function Invoke-ScanDefenderExclusions {
    param([switch]$ReportOnly)
    Write-Title '12. Microsoft Defender Exclusion Orphans'
    $local = New-Object System.Collections.ArrayList

    try {
        $pref = Get-MpPreference -ErrorAction Stop
        foreach ($path in @($pref.ExclusionPath)) {
            if ([string]::IsNullOrWhiteSpace($path)) { continue }

            $expanded = [Environment]::ExpandEnvironmentVariables($path)
            $exists = Test-Path -LiteralPath $expanded
            $status = if ($exists) { 'Present' } else { 'Stale?' }
            $rec = if (-not $exists) {
                'The path no longer exists. Verify whether the exclusion is still required; unnecessary exclusions are a security risk.'
            } else {
                'Keep an existing exclusion only when there is a valid business requirement.'
            }

            $r = Add-Result 12 'DefenderExclusion' $path $status "Path exists: $exists" $rec
            [void]$local.Add($r)
        }
    } catch {
        $r = Add-Result 12 'DefenderExclusion' 'Defender' 'Error' $_.Exception.Message `
            'Check Microsoft Defender availability and PowerShell permissions.'
        [void]$local.Add($r)
    }

    Show-ResultTable $local 'All Defender exclusion entries'

    $stale = @($local | Where-Object Status -eq 'Stale?')
    if (-not $ReportOnly -and $stale.Count -gt 0) {
        $preview = @()
        for ($i = 0; $i -lt $stale.Count; $i++) {
            $preview += [pscustomobject]@{
                No          = $i + 1
                ExclusionPath = $stale[$i].Item
                Status        = $stale[$i].Status
                Description   = 'File/folder path no longer exists'
            }
        }

        Show-DeletionPreview -Data $preview `
            -Title 'DEFENDER EXCLUSIONS AVAILABLE FOR REMOVAL - PREVIEW'

        if (Confirm-Action 'Do you want to remove one of the stale Defender exclusions shown above?') {
            $pick = Read-Host 'Record number to remove (Enter to cancel)'
            if ($pick -match '^\d+$') {
                $idx = [int]$pick - 1
                if ($idx -ge 0 -and $idx -lt $stale.Count) {
                    $target = $stale[$idx].Item

                    Write-Host ''
                    Write-Host 'Selected record:' -ForegroundColor Yellow
                    [pscustomobject]@{
                        DefenderExclusionPath = $target
                        Status                  = 'Path does not exist'
                    } | Format-List | Out-Host

                    if (Confirm-Action "Really remove Defender exclusion '$target'?" -HighRisk) {
                        if (-not (Test-IsAdministrator)) {
                            Write-Host 'Administrator rights are required. No changes were made.' -ForegroundColor Red
                        } else {
                            try {
                                Write-Host 'Safe Audit: Defender exclusion changes are disabled.' -ForegroundColor Yellow
                                Write-Log "Safe Audit: Defender exclusion was not changed: $target" 'INFO'
                                Write-Host 'Exclusion removed.' -ForegroundColor Green
                            } catch {
                                Write-Host $_.Exception.Message -ForegroundColor Red
                            }
                        }
                    } else {
                        Write-Host 'Removal cancelled.' -ForegroundColor Yellow
                    }
                } else {
                    Write-Host 'Invalid record number. No changes were made.' -ForegroundColor Yellow
                }
            } else {
                Write-Host 'Selection cancelled. No changes were made.' -ForegroundColor Yellow
            }
        } else {
            Write-Host 'Removal cancelled. Defender exclusions were not changed.' -ForegroundColor Yellow
        }
    } elseif (-not $ReportOnly -and $stale.Count -eq 0) {
        Write-Host ''
        Write-Host 'No stale Defender exclusion is available for removal.' -ForegroundColor Green
    }

    return $local
}

# ---------------------------------------------------------------------------
# 13. Failed Scheduled Tasks
# ---------------------------------------------------------------------------
function Invoke-ScanScheduledTasks {
    Write-Title '13. Failed Scheduled Tasks'
    $local = New-Object System.Collections.ArrayList

    try {
        foreach ($task in Get-ScheduledTask -ErrorAction Stop) {
            try {
                $info = $task | Get-ScheduledTaskInfo -ErrorAction Stop
                if ($info.LastTaskResult -ne 0 -and $info.LastRunTime -gt [datetime]::MinValue) {
                    $ageDays = [math]::Floor(((Get-Date) - $info.LastRunTime).TotalDays)
                    $taskStatus = if ($ageDays -ge 30) { 'Old Failed' } else { 'Failed' }
                    $r = Add-Result 13 'ScheduledTask' ($task.TaskPath + $task.TaskName) $taskStatus `
                        "LastResult=$($info.LastTaskResult) | LastRun=$($info.LastRunTime) | Age=$ageDays days" `
                        'A single failure does not prove a chronic problem. Review task history and application logs.'
                    [void]$local.Add($r)
                }
            } catch {}
        }
    } catch {
        $r = Add-Result 13 'ScheduledTask' 'Task Scheduler' 'Error' $_.Exception.Message 'Check permissions.'
        [void]$local.Add($r)
    }

    Show-ResultTable $local 'Tasks whose last run appears to have failed'
    return $local
}

# ---------------------------------------------------------------------------
# 14. Gereksiz Hizmetler
# ---------------------------------------------------------------------------
function Invoke-ScanServices {
    Write-Title '14. Service Review'
    $local = New-Object System.Collections.ArrayList

    $reviewPatterns = @(
        'Xbox','Xbl','Spooler','Bluetooth','bthserv','Fax','MapsBroker','RemoteRegistry'
    )

    try {
        $services = Get-CimInstance Win32_Service -ErrorAction Stop
        foreach ($s in $services) {
            if ($s.StartMode -eq 'Auto' -or $s.State -eq 'Running') {
                $matched = $false
                foreach ($pattern in $reviewPatterns) {
                    if ($s.Name -like "*$pattern*" -or $s.DisplayName -like "*$pattern*") {
                        $matched = $true; break
                    }
                }

                $status = if ($matched) { 'Review' } else { 'Info' }
                $rec = if ($matched) {
                    'This service may be unnecessary on some systems; do not disable it before verifying the device role.'
                } else {
                    'Do not change startup type without verifying the service role and dependencies.'
                }

                $r = Add-Result 14 'Service' $s.DisplayName $status `
                    "Name=$($s.Name) | State=$($s.State) | StartMode=$($s.StartMode)" $rec
                [void]$local.Add($r)
            }
        }
    } catch {
        $r = Add-Result 14 'Service' 'Services' 'Error' $_.Exception.Message 'Check WMI/CIM access.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data @($local | Where-Object Status -eq 'Review') -Title 'Services recommended for user review'
    Write-Host ''
    Write-Host 'Note: Get-Service/Win32_Service does not provide 30 days of network-traffic history.' -ForegroundColor Yellow
    Write-Host 'Therefore the tool does not disable services based on an unsupported no-traffic assumption.' -ForegroundColor Yellow
    return $local
}

# ---------------------------------------------------------------------------
# 15. Invalid CLSID / COM Registrations
# ---------------------------------------------------------------------------
function Invoke-ScanInvalidClsid {
    Write-Title '15. Invalid CLSID / COM Registrations'
    $local = New-Object System.Collections.ArrayList
    $root = 'Registry::HKEY_CLASSES_ROOT\CLSID'

    try {
        foreach ($clsid in Get-ChildItem $root -ErrorAction Stop) {
            $inproc = $clsid.PSPath.TrimEnd('\') + '\InprocServer32'
            if (-not (Test-Path $inproc)) { continue }

            $value = Get-RegistryDefaultValueSafe -LiteralPath $inproc
            if ([string]::IsNullOrWhiteSpace([string]$value)) { continue }

            $path = [Environment]::ExpandEnvironmentVariables([string]$value)
            if ($path -match '^[A-Za-z]:\\' -and -not (Test-Path -LiteralPath $path)) {
                $r = Add-Result 15 'CLSID' $clsid.PSChildName 'Suspicious' `
                    "InprocServer32 target missing: $path" `
                    'Do not automatically delete the registry entry. Verify COM registration, MSI repair and application ownership.'
                [void]$local.Add($r)
            }
        }
    } catch {
        $r = Add-Result 15 'CLSID' 'HKCR\CLSID' 'Error' $_.Exception.Message 'Check registry access.'
        [void]$local.Add($r)
    }

    Show-ResultTable $local 'CLSID registrations with missing DLL targets'
    Write-Host 'This tool does not automatically delete CLSID registrations.' -ForegroundColor Yellow
    return $local
}

# ---------------------------------------------------------------------------
# 16. .NET Framework Inventory
# ---------------------------------------------------------------------------
function Invoke-ScanDotNetFramework {
    Write-Title '16. .NET Framework Inventory'
    $local = New-Object System.Collections.ArrayList
    $root = 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP'

    if (Test-PathSafe -Path $root) {
        foreach ($key in @(Get-ChildItem -LiteralPath $root -Recurse -ErrorAction SilentlyContinue)) {
            if($null -eq $key) { continue }

            try {
                $p = Get-ItemProperty -LiteralPath $key.PSPath -ErrorAction SilentlyContinue
                if($null -eq $p) { continue }

                $version = Get-SafePropertyValue -InputObject $p -Name 'Version'
                $release = Get-SafePropertyValue -InputObject $p -Name 'Release'
                $install = Get-SafePropertyValue -InputObject $p -Name 'Install'

                if($null -eq $version -and $null -eq $release) { continue }

                $versionText = if($null -eq $version) { '<not set>' } else { [string]$version }
                $releaseText = if($null -eq $release) { '<not set>' } else { [string]$release }
                $installText = if($null -eq $install) { '<not set>' } else { [string]$install }

                $detail = "Version=$versionText | Release=$releaseText | Install=$installText"
                $r = Add-Result 16 '.NET Framework' ([string]$key.PSChildName) 'Info' $detail `
                    'Change Windows .NET components only after application compatibility has been verified.'
                [void]$local.Add($r)
            }
            catch {
                $r = Add-Result 16 '.NET Framework' ([string]$key.PSChildName) 'Error' $_.Exception.Message `
                    'This registry node could not be read; the rest of the .NET inventory was still processed.'
                [void]$local.Add($r)
            }
        }
    }

    Show-ResultTable -Data $local -Title '.NET Framework inventory'
    return $local
}

# ---------------------------------------------------------------------------
# 17. Windows Appx Artıkları
# ---------------------------------------------------------------------------
function Invoke-ScanAppx {
    Write-Title '17. Appx Package Health'
    $local = New-Object System.Collections.ArrayList

    try {
        $packages = @(Get-AppxPackage -AllUsers -ErrorAction Stop)

        foreach ($p in $packages) {
            # Get-AppxPackage çıktısında yaygın sağlık alanı "Status" değeridir.
            $statusText = $null
            if ($p.PSObject.Properties.Name -contains 'Status') {
                $statusText = [string]$p.Status
            }

            $isPartiallyStaged = $false
            if ($p.PSObject.Properties.Name -contains 'IsPartiallyStaged') {
                $isPartiallyStaged = [bool]$p.IsPartiallyStaged
            }

            $needsReview = $isPartiallyStaged
            if ($statusText -and $statusText -notmatch '^(?i:ok)$') {
                $needsReview = $true
            }

            if ($needsReview) {
                $detail = "PackageFullName=$($p.PackageFullName)"
                if ($statusText) { $detail += " | Status=$statusText" }
                $detail += " | IsPartiallyStaged=$isPartiallyStaged"

                $r = Add-Result 17 'Appx' $p.Name 'Broken/Review' `
                    $detail `
                    'Do not manually delete files from WindowsApps; prefer Settings, Reset/Repair or supported Appx cmdlets.'
                [void]$local.Add($r)
            }
        }

        if ($local.Count -eq 0) {
            $r = Add-Result 17 'Appx' 'Appx packages' 'Info' `
                ("Scanned {0} Appx packages; no clear broken or partially staged package was detected." -f $packages.Count) `
                'Do not directly modify the WindowsApps folder.'
            [void]$local.Add($r)
        }
    } catch {
        $r = Add-Result 17 'Appx' 'Appx inventory' 'Error' $_.Exception.Message `
            'Administrator rights may be required for the AllUsers query.'
        [void]$local.Add($r)
    }

    Show-ResultTable $local
    return $local
}

# ---------------------------------------------------------------------------
# 18. Windows.old
# ---------------------------------------------------------------------------
function Invoke-ScanWindowsOld {
    Write-Title '18. Previous Windows Installation (Windows.old)'
    $local = New-Object System.Collections.ArrayList
    $path = Join-Path $env:SystemDrive 'Windows.old'

    if (Test-Path -LiteralPath $path) {
        Write-Host 'Calculating Windows.old size; this can take time on large folders...' -ForegroundColor DarkGray
        $size = Get-FolderSizeSafe $path
        $r = Add-Result 18 'Windows.old' $path 'Present' `
            'Previous Windows installation files were found.' `
            'Prefer Windows Settings > System > Storage > Temporary files / Storage Sense for supported cleanup.' `
            $size
        [void]$local.Add($r)
    } else {
        $r = Add-Result 18 'Windows.old' $path 'Not Found' 'Windows.old was not found.' 'No action is required.' 0
        [void]$local.Add($r)
    }

    Show-ResultTable $local
    return $local
}

# ---------------------------------------------------------------------------
# 19. Olay Günlükleri
# ---------------------------------------------------------------------------
function Invoke-ScanEventLogs {
    Write-Title '19. Large Event Logs'
    $local = New-Object System.Collections.ArrayList

    try {
        $logs = Get-WinEvent -ListLog * -ErrorAction SilentlyContinue |
            Where-Object { $_.FileSize -gt 100MB }

        foreach ($log in $logs) {
            $r = Add-Result 19 'EventLog' $log.LogName 'Large' `
                "RecordCount=$($log.RecordCount) | IsEnabled=$($log.IsEnabled)" `
                'Do not blindly clear Security/System/Application logs. Check retention, audit and incident-response requirements.' `
                ([long]$log.FileSize)
            [void]$local.Add($r)
        }
    } catch {
        $r = Add-Result 19 'EventLog' 'Event Logs' 'Error' $_.Exception.Message 'Check permissions.'
        [void]$local.Add($r)
    }

    Show-ResultTable $local 'Logs larger than 100 MB'
    return $local
}

# ---------------------------------------------------------------------------
# 20. DNS Cache ve Hosts Artıkları
# ---------------------------------------------------------------------------
function Invoke-ScanHosts {
    param([switch]$ReportOnly)
    Write-Title '20. Hosts File and DNS Cache'
    $local = New-Object System.Collections.ArrayList
    $hosts = Join-Path $env:WINDIR 'System32\drivers\etc\hosts'

    if (Test-Path -LiteralPath $hosts) {
        $lineNo = 0
        foreach ($line in Get-Content -LiteralPath $hosts -ErrorAction SilentlyContinue) {
            $lineNo++
            $clean = ($line -replace '#.*$','').Trim()
            if (-not $clean) { continue }

            $parts = $clean -split '\s+'
            if ($parts.Count -lt 2) { continue }

            $ip = $parts[0]
            foreach ($hostName in $parts[1..($parts.Count-1)]) {
                if ($hostName -in @('localhost','localhost.localdomain','broadcasthost')) { continue }

                $dnsResolved = $false
                try {
                    $null = Resolve-DnsName -Name $hostName -DnsOnly -ErrorAction Stop
                    $dnsResolved = $true
                } catch {}

                $ping = $false
                try {
                    $ping = Test-Connection -ComputerName $hostName -Count 1 -Quiet -ErrorAction SilentlyContinue
                } catch {}

                $status = if (-not $dnsResolved -and -not $ping) { 'Review' } else { 'Info' }
                $detail = "Line=$lineNo | Hosts IP=$ip | DNS=$dnsResolved | Ping=$ping"
                $rec = 'DNS/ping failure alone does not prove a hosts entry is invalid; services, firewalls or local routing may affect the result.'

                $r = Add-Result 20 'Hosts' $hostName $status $detail $rec
                [void]$local.Add($r)
            }
        }
    }

    $dnsEntries = @()
    if (Test-CommandAvailable 'Get-DnsClientCache') {
        try {
            $dnsEntries = @(Get-DnsClientCache -ErrorAction Stop)
            $r = Add-Result 20 'DNS' 'DNS Client Cache' 'Info' `
                ("Record count: {0}" -f $dnsEntries.Count) `
                'DNS cache should be cleared only for troubleshooting or explicit user preference.'
            [void]$local.Add($r)
        } catch {
            $r = Add-Result 20 'DNS' 'DNS Client Cache' 'Error' $_.Exception.Message `
                'Check access to DNS Client cmdlets.'
            [void]$local.Add($r)
        }
    } else {
        $r = Add-Result 20 'DNS' 'DNS Client Cache' 'Error' `
            'Get-DnsClientCache was not found.' `
            'Check the DNS Client PowerShell module.'
        [void]$local.Add($r)
    }

    Show-ResultTable $local 'Hosts and DNS summary'

    if (-not $ReportOnly -and $dnsEntries.Count -gt 0) {
        $dnsPreview = @(
            $dnsEntries | ForEach-Object {
                $entryName = $null
                foreach ($propName in @('Entry','Name')) {
                    if ($_.PSObject.Properties.Name -contains $propName) {
                        $entryName = [string]$_.($propName)
                        if ($entryName) { break }
                    }
                }

                $recordType = if ($_.PSObject.Properties.Name -contains 'Type') {
                    [string]$_.Type
                } elseif ($_.PSObject.Properties.Name -contains 'RecordType') {
                    [string]$_.RecordType
                } else {
                    ''
                }

                $dataValue = ''
                foreach ($propName in @('Data','DataLength')) {
                    if ($_.PSObject.Properties.Name -contains $propName) {
                        $dataValue = [string]$_.($propName)
                        if ($dataValue) { break }
                    }
                }

                $ttlValue = ''
                foreach ($propName in @('TimeToLive','TTL')) {
                    if ($_.PSObject.Properties.Name -contains $propName) {
                        $ttlValue = [string]$_.($propName)
                        if ($ttlValue) { break }
                    }
                }

                [pscustomobject]@{
                    Record      = $entryName
                    Type        = $recordType
                    Data       = $dataValue
                    TTL        = $ttlValue
                }
            } | Sort-Object Record, Type
        )

        Show-DeletionPreview -Data $dnsPreview `
            -Title 'DNS CACHE RECORDS TO CLEAR - PREVIEW' `
            -UsePaging

        if (Confirm-Action ("Clear the {0} DNS cache records shown above?" -f $dnsEntries.Count)) {
            if (-not (Test-CommandAvailable 'Get-DnsClientCache')) {
                Write-Host 'DNS client tooling was not found. No changes were made.' -ForegroundColor Red
            } else {
                try {
                    Write-Host 'Safe Audit: DNS cache changes are disabled.' -ForegroundColor Yellow
                    Write-Log "Safe Audit: DNS cache was not changed. Previewed records: $($dnsEntries.Count)" 'INFO'
                    Write-Host 'Safe Audit: DNS cache was not changed.' -ForegroundColor Yellow
                } catch {
                    Write-Host $_.Exception.Message -ForegroundColor Red
                }
            }
        } else {
            Write-Host 'Cleanup cancelled. DNS cache was not changed.' -ForegroundColor Yellow
        }
    } elseif (-not $ReportOnly -and $dnsEntries.Count -eq 0) {
        Write-Host ''
        Write-Host 'No DNS cache records are available to clear.' -ForegroundColor Green
    }

    return $local
}


# ---------------------------------------------------------------------------
# 21. Large Files Analyzer
# ---------------------------------------------------------------------------
function Invoke-ScanLargeFiles {
    Write-Title '21. Large Files Analyzer'
    $local = New-Object System.Collections.ArrayList
    $threshold = 1GB
    $cutoff = (Get-Date).AddDays(-180)

    $roots = @(
        (Join-Path $env:USERPROFILE 'Desktop'),
        (Join-Path $env:USERPROFILE 'Documents'),
        (Join-Path $env:USERPROFILE 'Downloads'),
        (Join-Path $env:USERPROFILE 'Pictures'),
        (Join-Path $env:USERPROFILE 'Videos')
    ) | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -Unique

    $scanned = 0
    $spinner = 0
    foreach ($root in $roots) {
        Write-Host ("Scanning: {0}" -f $root) -ForegroundColor DarkGray
        foreach ($f in Get-ChildItem -LiteralPath $root -File -Force -Recurse -ErrorAction SilentlyContinue) {
            $scanned++
            if (($scanned % 200) -eq 0) {
                Write-SpinnerFrame -Activity ("Scanning user files ({0} checked)" -f $scanned) -Step $spinner
                $spinner++
            }
            if ($f.Length -ge $threshold -and $f.LastWriteTime -lt $cutoff) {
                $r = Add-Result 21 'LargeFiles' $f.FullName 'Review' `
                    ("Last modified={0} | Extension={1}" -f $f.LastWriteTime, $f.Extension) `
                    'Large and old does not mean unnecessary. Review manually before deleting.' `
                    ([long]$f.Length)
                [void]$local.Add($r)
            }
        }
    }
    if ($scanned -gt 0) { Complete-Spinner -Activity ("Scanning user files ({0} checked)" -f $scanned) }

    Show-ResultTable -Data @($local | Sort-Object SizeBytes -Descending) -Title 'Files >= 1 GB and older than 180 days'
    Write-Host 'Report-only module: large files are never automatically deleted.' -ForegroundColor Yellow
    return $local
}

# ---------------------------------------------------------------------------
# 22. Downloads Cleanup
# ---------------------------------------------------------------------------
function Invoke-ScanDownloads {
    param([switch]$ReportOnly)
    Write-Title '22. Downloads Folder Cleanup'
    $local = New-Object System.Collections.ArrayList
    $path = Join-Path $env:USERPROFILE 'Downloads'
    $cutoff = (Get-Date).AddDays(-90)

    if (-not (Test-Path -LiteralPath $path)) {
        Write-Host 'Downloads folder was not found.' -ForegroundColor Yellow
        return $local
    }

    $files = @(Get-ChildItem -LiteralPath $path -File -Force -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTime -lt $cutoff } |
        Sort-Object LastWriteTime)

    foreach ($f in $files) {
        $r = Add-Result 22 'Downloads' $f.FullName 'Old' `
            ("Last modified={0}" -f $f.LastWriteTime) `
            'Review downloads carefully; installers, archives and documents may still be important.' `
            ([long]$f.Length)
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Downloads items older than 90 days'

    if (-not $ReportOnly -and $files.Count -gt 0) {
        $preview = @($files | ForEach-Object {
            [pscustomobject]@{
                Name         = $_.Name
                FullPath     = $_.FullName
                LastModified = $_.LastWriteTime
                Size         = Format-Bytes $_.Length
            }
        })
        $totalBytes = [long](Get-SafePropertySum -InputObject $files -Property 'Length')
        Show-DeletionPreview -Data $preview -Title 'DOWNLOADS ITEMS TO DELETE - PREVIEW' -TotalBytes $totalBytes -UsePaging

        if (Confirm-Action ("Delete the {0} Downloads files shown above?" -f $files.Count)) {
            $ok=0; $fail=0
            foreach ($f in $files) {
                try { $null = $f.FullName; $ok++; Write-Log "Downloads file deleted: $($f.FullName)" 'ACTION' }
                catch { $fail++; Write-Log "Downloads file failed/skipped: $($f.FullName) | $($_.Exception.Message)" 'WARN' }
            }
            Write-Host ("Deleted: {0} | Failed/Skipped: {1}" -f $ok,$fail) -ForegroundColor Green
        } else {
            Write-Host 'Cleanup cancelled. No Downloads file was deleted.' -ForegroundColor Yellow
        }
    }
    return $local
}

# ---------------------------------------------------------------------------
# 23. Recycle Bin Analyzer / Cleanup
# ---------------------------------------------------------------------------
function Invoke-ScanRecycleBin {
    param([switch]$ReportOnly)
    Write-Title '23. Recycle Bin Analyzer'
    $local = New-Object System.Collections.ArrayList
    $items = @()

    try {
        $shell = New-Object -ComObject Shell.Application
        $folder = $shell.Namespace(0xA)
        if ($null -ne $folder) {
            $items = @($folder.Items())
        }
    } catch {
        $r = Add-Result 23 'RecycleBin' 'Recycle Bin' 'Error' $_.Exception.Message 'Windows Shell COM access failed.'
        [void]$local.Add($r)
    }

    foreach ($item in $items) {
        $size = 0L
        try { if ($null -ne $item.Size) { $size = [long]$item.Size } } catch {}
        $path = ''
        try { $path = [string]$item.Path } catch {}
        $r = Add-Result 23 'RecycleBin' ([string]$item.Name) 'Review' `
            ("Recycle path={0}" -f $path) `
            'Review before emptying the Recycle Bin.' `
            $size
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Recycle Bin contents'

    if (-not $ReportOnly -and $items.Count -gt 0) {
        $preview = @($local | Select-Object @{N='Name';E={$_.Item}}, Size, Details)
        $sum = [long](Get-SafePropertySum -InputObject $local -Property 'SizeBytes')
        $totalBytes = if ($null -eq $sum) { 0L } else { [long]$sum }
        Show-DeletionPreview -Data $preview -Title 'RECYCLE BIN CONTENTS TO DELETE - PREVIEW' -TotalBytes $totalBytes -UsePaging

        if (Confirm-Action ("Empty the Recycle Bin containing {0} displayed items?" -f $items.Count) -HighRisk) {
            if (Test-CommandAvailable 'Get-ChildItem') {
                try {
                    Write-Host 'Safe Audit: Recycle Bin changes are disabled.' -ForegroundColor Yellow
                    Write-Log "Safe Audit: Recycle Bin was not changed. Items previewed=$($items.Count)" 'INFO'
                    Write-Host 'Safe Audit: Recycle Bin was not changed.' -ForegroundColor Yellow
                } catch { Write-Host $_.Exception.Message -ForegroundColor Red }
            } else {
                Write-Host 'Recycle Bin cleanup is disabled in Safe Audit. No deletion was performed.' -ForegroundColor Yellow
            }
        } else {
            Write-Host 'Cleanup cancelled. The Recycle Bin was not changed.' -ForegroundColor Yellow
        }
    }
    return $local
}

# ---------------------------------------------------------------------------
# 24. Crash Dump Analyzer
# ---------------------------------------------------------------------------
function Invoke-ScanCrashDumps {
    param([switch]$ReportOnly)
    Write-Title '24. Crash Dump Analyzer'
    $local = New-Object System.Collections.ArrayList
    $cutoff = (Get-Date).AddDays(-30)

    $userDumpPath = Join-Path $env:LOCALAPPDATA 'CrashDumps'
    $userCandidates = @()
    if (Test-Path -LiteralPath $userDumpPath) {
        $userCandidates = @(Get-ChildItem -LiteralPath $userDumpPath -File -Filter '*.dmp' -Force -ErrorAction SilentlyContinue |
            Where-Object { $_.LastWriteTime -lt $cutoff })
        foreach ($f in $userCandidates) {
            $r = Add-Result 24 'CrashDump' $f.FullName 'Old' ("Last modified={0}" -f $f.LastWriteTime) `
                'User crash dump older than 30 days. Keep it if debugging is still required.' ([long]$f.Length)
            [void]$local.Add($r)
        }
    }

    foreach ($systemPath in @((Join-Path $env:WINDIR 'MEMORY.DMP'), (Join-Path $env:WINDIR 'Minidump'))) {
        if (Test-Path -LiteralPath $systemPath) {
            if ((Get-Item -LiteralPath $systemPath -Force -ErrorAction SilentlyContinue).PSIsContainer) {
                foreach ($f in Get-ChildItem -LiteralPath $systemPath -File -Filter '*.dmp' -Force -ErrorAction SilentlyContinue) {
                    $r = Add-Result 24 'SystemCrashDump' $f.FullName 'Review' ("Last modified={0}" -f $f.LastWriteTime) `
                        'System crash dump is report-only because it may be needed for diagnostics.' ([long]$f.Length)
                    [void]$local.Add($r)
                }
            } else {
                $f = Get-Item -LiteralPath $systemPath -Force -ErrorAction SilentlyContinue
                if ($null -ne $f) {
                    $r = Add-Result 24 'SystemCrashDump' $f.FullName 'Review' ("Last modified={0}" -f $f.LastWriteTime) `
                        'System MEMORY.DMP is report-only because it may be needed for diagnostics.' ([long]$f.Length)
                    [void]$local.Add($r)
                }
            }
        }
    }

    Show-ResultTable -Data $local -Title 'Crash dump files'

    if (-not $ReportOnly -and $userCandidates.Count -gt 0) {
        $preview = @($userCandidates | Select-Object Name,FullName,LastWriteTime,@{N='Size';E={Format-Bytes $_.Length}})
        $bytes=[long](Get-SafePropertySum -InputObject $userCandidates -Property 'Length')
        Show-DeletionPreview -Data $preview -Title 'OLD USER CRASH DUMPS TO DELETE - PREVIEW' -TotalBytes $bytes -UsePaging
        if (Confirm-Action ("Delete the {0} old user crash dumps shown above?" -f $userCandidates.Count)) {
            $ok=0;$fail=0
            foreach($f in $userCandidates){try{$null = $f.FullName;$ok++}catch{$fail++}}
            Write-Host ("Deleted: {0} | Failed/Skipped: {1}" -f $ok,$fail) -ForegroundColor Green
        }
    }
    return $local
}

# ---------------------------------------------------------------------------
# 25. Windows Error Reporting (WER)
# ---------------------------------------------------------------------------
function Invoke-ScanWER {
    param([switch]$ReportOnly)
    Write-Title '25. Windows Error Reporting (WER)'
    $local = New-Object System.Collections.ArrayList
    $cutoff = (Get-Date).AddDays(-30)
    $paths = @(
        (Join-Path $env:ProgramData 'Microsoft\Windows\WER\ReportArchive'),
        (Join-Path $env:ProgramData 'Microsoft\Windows\WER\ReportQueue'),
        (Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\WER')
    ) | Select-Object -Unique

    $candidates = New-Object System.Collections.ArrayList
    foreach ($path in $paths) {
        if (-not (Test-Path -LiteralPath $path)) { continue }
        foreach ($f in Get-ChildItem -LiteralPath $path -File -Force -Recurse -ErrorAction SilentlyContinue |
            Where-Object { $_.LastWriteTime -lt $cutoff }) {
            [void]$candidates.Add($f)
        }
    }

    foreach ($f in $candidates) {
        $r = Add-Result 25 'WER' $f.FullName 'Old' ("Last modified={0}" -f $f.LastWriteTime) `
            'WER file older than 30 days; keep it if application-crash investigation is ongoing.' ([long]$f.Length)
        [void]$local.Add($r)
    }
    Show-ResultTable -Data $local -Title 'WER files older than 30 days'

    if (-not $ReportOnly -and $candidates.Count -gt 0) {
        $preview=@($candidates|Select-Object Name,FullName,LastWriteTime,@{N='Size';E={Format-Bytes $_.Length}})
        $bytes=[long](Get-SafePropertySum -InputObject $candidates -Property 'Length')
        Show-DeletionPreview -Data $preview -Title 'OLD WER FILES TO DELETE - PREVIEW' -TotalBytes $bytes -UsePaging
        if (Confirm-Action ("Delete the {0} old WER files shown above?" -f $candidates.Count)) {
            $ok=0;$fail=0
            foreach($f in $candidates){try{$null = $f.FullName;$ok++}catch{$fail++}}
            Write-Host ("Deleted: {0} | Failed/Skipped: {1}" -f $ok,$fail) -ForegroundColor Green
        }
    }
    return $local
}

# ---------------------------------------------------------------------------
# 26. Browser Cache Analyzer
# ---------------------------------------------------------------------------
function Invoke-ScanBrowserCaches {
    Write-Title '26. Browser Cache Analyzer'
    $local = New-Object System.Collections.ArrayList
    $targets = New-Object System.Collections.ArrayList

    foreach ($browser in @(
        @{Name='Microsoft Edge'; Root=(Join-Path $env:LOCALAPPDATA 'Microsoft\Edge\User Data')},
        @{Name='Google Chrome'; Root=(Join-Path $env:LOCALAPPDATA 'Google\Chrome\User Data')}
    )) {
        if (Test-Path -LiteralPath $browser.Root) {
            foreach($profile in Get-ChildItem -LiteralPath $browser.Root -Directory -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -eq 'Default' -or $_.Name -like 'Profile *' }) {
                foreach($sub in @('Cache','Code Cache','GPUCache','Service Worker\CacheStorage')) {
                    $p=Join-Path $profile.FullName $sub
                    if(Test-Path -LiteralPath $p){[void]$targets.Add([pscustomobject]@{Browser=$browser.Name;Profile=$profile.Name;Path=$p})}
                }
            }
        }
    }

    $ffRoot = Join-Path $env:LOCALAPPDATA 'Mozilla\Firefox\Profiles'
    if(Test-Path -LiteralPath $ffRoot){
        foreach($profile in Get-ChildItem -LiteralPath $ffRoot -Directory -ErrorAction SilentlyContinue){
            $p=Join-Path $profile.FullName 'cache2'
            if(Test-Path -LiteralPath $p){[void]$targets.Add([pscustomobject]@{Browser='Mozilla Firefox';Profile=$profile.Name;Path=$p})}
        }
    }

    $step=0
    foreach($t in $targets){
        Write-SpinnerFrame -Activity ("Measuring browser caches ({0}/{1})" -f ($step+1),$targets.Count) -Step $step
        $size=Get-FolderSizeSafe $t.Path
        $status=if($size -gt 1GB){'Large'}elseif($size -gt 500MB){'Review'}else{'Info'}
        $r=Add-Result 26 'BrowserCache' ("{0} / {1}" -f $t.Browser,$t.Profile) $status ("Path={0}" -f $t.Path) `
            'Report-only in v1.4. Close the browser and use its own cleanup UI before deleting cache files manually.' $size
        [void]$local.Add($r);$step++
    }
    if($targets.Count -gt 0){Complete-Spinner -Activity 'Measuring browser caches'}
    Show-ResultTable -Data $local -Title 'Browser cache sizes'
    return $local
}

# ---------------------------------------------------------------------------
# 27. Startup Folder Analyzer
# ---------------------------------------------------------------------------
function Invoke-ScanStartupFolders {
    Write-Title '27. Startup Folder Analyzer'
    $local=New-Object System.Collections.ArrayList
    $paths=@(
        (Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Startup'),
        (Join-Path $env:ProgramData 'Microsoft\Windows\Start Menu\Programs\StartUp')
    )|Select-Object -Unique
    $wsh=$null
    try{$wsh=New-Object -ComObject WScript.Shell}catch{}

    foreach($path in $paths){
        if(-not(Test-Path -LiteralPath $path)){continue}
        foreach($f in Get-ChildItem -LiteralPath $path -File -Force -ErrorAction SilentlyContinue){
            $status='Info';$detail="Path=$($f.FullName)";$rec='Review startup-folder items manually before removing them.'
            if($f.Extension -ieq '.lnk' -and $null -ne $wsh){
                try{
                    $shortcut=$wsh.CreateShortcut($f.FullName);$target=[Environment]::ExpandEnvironmentVariables([string]$shortcut.TargetPath)
                    $exists=if([string]::IsNullOrWhiteSpace($target)){$false}else{Test-Path -LiteralPath $target}
                    $detail += " | Target=$target | Exists=$exists"
                    if(-not $exists){$status='Suspicious';$rec='Shortcut target is missing. Verify the application before deleting the shortcut.'}
                    else{$status='Healthy'}
                }catch{$status='Review';$detail += ' | Shortcut could not be resolved'}
            }
            $r=Add-Result 27 'StartupFolder' $f.Name $status $detail $rec ([long]$f.Length);[void]$local.Add($r)
        }
    }
    Show-ResultTable -Data $local -Title 'Startup folder items'
    Write-Host 'Report-only module: startup-folder files are not automatically deleted.' -ForegroundColor Yellow
    return $local
}

# ---------------------------------------------------------------------------
# 28. VPN and Proxy Analyzer
# ---------------------------------------------------------------------------
function Invoke-ScanVpnProxy {
    Write-Title '28. VPN and Proxy Analyzer'
    $local=New-Object System.Collections.ArrayList

    if(Test-CommandAvailable 'Get-VpnConnection'){
        try{
            foreach($v in @(Get-VpnConnection -ErrorAction SilentlyContinue)){
                $r=Add-Result 28 'VPN' $v.Name 'Info' ("Server={0} | Tunnel={1} | SplitTunneling={2}" -f $v.ServerAddress,$v.TunnelType,$v.SplitTunneling) `
                    'Review unused VPN profiles manually.';[void]$local.Add($r)
            }
            foreach($v in @(Get-VpnConnection -AllUserConnection -ErrorAction SilentlyContinue)){
                $r=Add-Result 28 'VPN-AllUsers' $v.Name 'Info' ("Server={0} | Tunnel={1} | AllUsers=True" -f $v.ServerAddress,$v.TunnelType) `
                    'All-user VPN profiles may require Administrator rights to change.';[void]$local.Add($r)
            }
        }catch{}
    }

    $inet='HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'
    if(Test-PathSafe -Path $inet){
        $p=Get-ItemProperty -LiteralPath $inet -ErrorAction SilentlyContinue
        $proxyEnable = Get-SafePropertyValue -InputObject $p -Name 'ProxyEnable' -Default 0
        $proxyServer = Get-SafePropertyValue -InputObject $p -Name 'ProxyServer' -Default '<not set>'
        $autoConfig  = Get-SafePropertyValue -InputObject $p -Name 'AutoConfigURL' -Default '<not set>'
        $enabled=([int]$proxyEnable -ne 0)
        $r=Add-Result 28 'Proxy' 'WinINET Proxy' $(if($enabled){'Review'}else{'Info'}) `
            ("Enabled={0} | Server={1} | PAC={2}" -f $enabled,$proxyServer,$autoConfig) `
            'Verify that proxy/PAC settings are still required.';[void]$local.Add($r)
    }

    if(Test-CommandAvailable 'netsh.exe'){
        try{
            $out=(& netsh.exe winhttp show proxy 2>&1)-join [Environment]::NewLine
            $r=Add-Result 28 'Proxy' 'WinHTTP Proxy' 'Info' $out 'Review WinHTTP proxy settings if they are unexpected.';[void]$local.Add($r)
        }catch{}
    }
    Show-ResultTable -Data $local -Title 'VPN and proxy configuration'
    return $local
}

# ---------------------------------------------------------------------------
# 29. Component Store (WinSxS) Analyzer
# ---------------------------------------------------------------------------
function Invoke-ScanComponentStore {
    param([switch]$ReportOnly)
    Write-Title '29. Component Store (WinSxS) Analyzer'
    $local=New-Object System.Collections.ArrayList
    if(-not(Test-CommandAvailable 'dism.exe')){
        $r=Add-Result 29 'ComponentStore' 'DISM' 'Error' 'dism.exe was not found.' 'Windows servicing tools are unavailable.';[void]$local.Add($r)
        Show-ResultTable -Data $local;return $local
    }

    try{
        $output=Invoke-JobWithSpinner -Activity 'Analyzing Component Store' -ScriptBlock { & dism.exe /Online /Cleanup-Image /AnalyzeComponentStore 2>&1 }
        $textOut=$output -join [Environment]::NewLine
        Write-Host $textOut
        $status=if($textOut -match '(?i)Component Store Cleanup Recommended\s*:\s*Yes'){'Review'}else{'Info'}
        $r=Add-Result 29 'ComponentStore' 'DISM AnalyzeComponentStore' $status $textOut `
            'Use supported Windows servicing tools if component-store maintenance is required. This module is report-only.';[void]$local.Add($r)

        if(-not $ReportOnly -and (Test-IsAdministrator)){
            if(Confirm-Action 'Display the Safe Audit cleanup-disabled notice?'){
                $cleanup=Invoke-JobWithSpinner -Activity 'Running Component Store cleanup' -ScriptBlock { 'Safe Audit: component-store cleanup is disabled.' }
                Write-Host ($cleanup -join [Environment]::NewLine)
                Write-Log 'Safe Audit: component-store cleanup was not executed.' 'INFO'
            }
        }elseif(-not $ReportOnly -and -not(Test-IsAdministrator)){
            Write-Host 'Administrator rights are required to run Component Store cleanup.' -ForegroundColor Yellow
        }
    }catch{
        $r=Add-Result 29 'ComponentStore' 'DISM' 'Error' $_.Exception.Message 'Run the module from an elevated Windows PowerShell session.';[void]$local.Add($r)
    }
    return $local
}

# ---------------------------------------------------------------------------
# 30. Restore Points and VSS Analyzer
# ---------------------------------------------------------------------------
function Invoke-ScanRestorePoints {
    Write-Title '30. Restore Points and VSS Analyzer'
    $local=New-Object System.Collections.ArrayList

    if(Test-CommandAvailable 'Get-ComputerRestorePoint'){
        try{
            foreach($rp in @(Get-ComputerRestorePoint -ErrorAction Stop)){
                $created=[string]$rp.CreationTime
                try{$created=[System.Management.ManagementDateTimeConverter]::ToDateTime([string]$rp.CreationTime)}catch{}
                $r=Add-Result 30 'RestorePoint' ("Sequence {0}: {1}" -f $rp.SequenceNumber,$rp.Description) 'Info' `
                    ("Created={0} | Type={1}" -f $created,$rp.RestorePointType) `
                    'Report-only in v1.4. Restore points are not automatically deleted.';[void]$local.Add($r)
            }
        }catch{
            $r=Add-Result 30 'RestorePoint' 'System Restore' 'Error' $_.Exception.Message 'System Restore may be disabled or elevated rights may be required.';[void]$local.Add($r)
        }
    }

    if(Test-CommandAvailable 'vssadmin.exe'){
        try{
            $out=Invoke-JobWithSpinner -Activity 'Reading VSS shadow-storage usage' -ScriptBlock { & vssadmin.exe list shadowstorage 2>&1 }
            $vssText=$out -join [Environment]::NewLine
            $r=Add-Result 30 'VSS' 'Shadow Storage' 'Info' $vssText 'Report-only. Do not delete shadow copies unless recovery requirements are understood.';[void]$local.Add($r)
        }catch{}
    }
    Show-ResultTable -Data $local -Title 'Restore points and VSS information'
    Write-Host 'Report-only module: no restore point or shadow copy is deleted.' -ForegroundColor Yellow
    return $local
}


# ---------------------------------------------------------------------------
# 31. Storage Sense Configuration
# ---------------------------------------------------------------------------
function Invoke-ScanStorageSense {
    Write-Title '31. Storage Sense Configuration'
    $local = New-Object System.Collections.ArrayList
    $path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy'

    if (Test-Path -LiteralPath $path) {
        try {
            $p = Get-ItemProperty -LiteralPath $path -ErrorAction Stop
            $enabled = $null
            if ($p.PSObject.Properties.Name -contains '01') {
                $enabled = ([int]$p.'01' -ne 0)
            }

            $status = if ($enabled -eq $true) { 'Enabled' } elseif ($enabled -eq $false) { 'Disabled' } else { 'Configured' }
            $detail = if ($null -ne $enabled) {
                "Storage Sense enabled: $enabled"
            } else {
                'Storage Sense policy key exists; enable state could not be determined from the current profile.'
            }

            $r = Add-Result 31 'StorageSense' 'Storage Sense' $status $detail `
                'Review Storage Sense settings in Settings > System > Storage. This module does not change them.'
            [void]$local.Add($r)

            $numeric = @(
                $p.PSObject.Properties |
                    Where-Object { $_.Name -match '^\d+$' } |
                    Sort-Object Name
            )

            foreach ($prop in $numeric) {
                if ($prop.Name -eq '01') { continue }
                $r = Add-Result 31 'StorageSensePolicy' ("Policy value {0}" -f $prop.Name) 'Info' `
                    ("Value: {0}" -f $prop.Value) `
                    'Raw Storage Sense policy value shown for inspection; no automatic change is made.'
                [void]$local.Add($r)
            }
        } catch {
            $r = Add-Result 31 'StorageSense' 'Storage Sense' 'Error' $_.Exception.Message 'Review the current user Storage Sense configuration.'
            [void]$local.Add($r)
        }
    } else {
        $r = Add-Result 31 'StorageSense' 'Storage Sense' 'Not configured' `
            'No per-user Storage Sense policy key was found.' `
            'Open Settings > System > Storage to review Storage Sense.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Storage Sense configuration'
    return $local
}

# ---------------------------------------------------------------------------
# 32. Delivery Optimization Cache
# ---------------------------------------------------------------------------
function Invoke-ScanDeliveryOptimization {
    Write-Title '32. Delivery Optimization Cache'
    $local = New-Object System.Collections.ArrayList
    $paths = @(
        (Join-Path $env:WINDIR 'SoftwareDistribution\DeliveryOptimization'),
        (Join-Path $env:WINDIR 'ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization')
    ) | Select-Object -Unique

    foreach ($path in $paths) {
        if (-not (Test-Path -LiteralPath $path)) { continue }

        $size = Get-FolderSizeWithSpinner -Path $path -Activity 'Measuring Delivery Optimization cache'
        $status = if ($size -gt 5GB) { 'Large' } elseif ($size -gt 1GB) { 'Review' } else { 'Info' }

        $r = Add-Result 32 'DeliveryOptimization' $path $status `
            'Windows Delivery Optimization cache location.' `
            'Use Windows Storage / Delivery Optimization controls rather than deleting protected files manually.' `
            $size
        [void]$local.Add($r)
    }

    if ($local.Count -eq 0) {
        $r = Add-Result 32 'DeliveryOptimization' 'Delivery Optimization cache' 'No data' `
            'No known Delivery Optimization cache directory was accessible.' `
            'No cleanup is required based on this scan.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Delivery Optimization cache'
    return $local
}

# ---------------------------------------------------------------------------
# 33. Windows Search Index
# ---------------------------------------------------------------------------
function Invoke-ScanSearchIndex {
    Write-Title '33. Windows Search Index'
    $local = New-Object System.Collections.ArrayList
    $dbPath = Join-Path $env:ProgramData 'Microsoft\Search\Data\Applications\Windows\Windows.db'

    $serviceText = 'Unknown'
    try {
        $svc = Get-Service -Name 'WSearch' -ErrorAction Stop
        $serviceText = "Status=$($svc.Status) | StartType=$($svc.StartType)"
    } catch {}

    if (Test-Path -LiteralPath $dbPath) {
        $item = Get-Item -LiteralPath $dbPath -Force -ErrorAction SilentlyContinue
        $size = if ($item) { [long]$item.Length } else { 0L }
        $status = if ($size -gt 5GB) { 'Large' } elseif ($size -gt 2GB) { 'Review' } else { 'Info' }

        $r = Add-Result 33 'SearchIndex' 'Windows.db' $status `
            "Path=$dbPath | $serviceText" `
            'If search indexing is problematic, use Windows indexing settings/rebuild controls; do not delete the database while the service is active.' `
            $size
        [void]$local.Add($r)
    } else {
        $r = Add-Result 33 'SearchIndex' 'Windows Search' 'Info' `
            "Search database was not found at the common Windows 11 path. $serviceText" `
            'No direct file cleanup is performed.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Windows Search index'
    return $local
}

# ---------------------------------------------------------------------------
# 34. OneDrive Local Storage
# ---------------------------------------------------------------------------
function Invoke-ScanOneDriveStorage {
    Write-Title '34. OneDrive Local Storage'
    $local = New-Object System.Collections.ArrayList

    $candidatePaths = @(
        $env:OneDrive,
        $env:OneDriveConsumer,
        $env:OneDriveCommercial,
        (Join-Path $env:USERPROFILE 'OneDrive')
    ) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique

    foreach ($path in $candidatePaths) {
        if (-not (Test-Path -LiteralPath $path)) { continue }

        $size = Get-FolderSizeWithSpinner -Path $path -Activity ("Measuring OneDrive local files: {0}" -f (Split-Path $path -Leaf))
        $status = if ($size -gt 20GB) { 'Large' } elseif ($size -gt 5GB) { 'Review' } else { 'Info' }
        $r = Add-Result 34 'OneDrive' $path $status `
            'Local OneDrive folder size. Cloud-only placeholders may not consume their displayed logical size locally.' `
            'Use OneDrive Files On-Demand / Free up space for supported space recovery rather than deleting synchronized files blindly.' `
            $size
        [void]$local.Add($r)
    }

    if ($local.Count -eq 0) {
        $r = Add-Result 34 'OneDrive' 'OneDrive' 'Not found' `
            'No common OneDrive sync folder was found for the current user.' `
            'No action required.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'OneDrive local storage'
    return $local
}

# ---------------------------------------------------------------------------
# 35. Microsoft Office Document Cache
# ---------------------------------------------------------------------------
function Invoke-ScanOfficeCache {
    Write-Title '35. Microsoft Office Document Cache'
    $local = New-Object System.Collections.ArrayList

    $paths = @(
        (Join-Path $env:LOCALAPPDATA 'Microsoft\Office\16.0\OfficeFileCache'),
        (Join-Path $env:LOCALAPPDATA 'Microsoft\Office\15.0\OfficeFileCache'),
        (Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\INetCache\Content.MSO')
    ) | Select-Object -Unique

    foreach ($path in $paths) {
        if (-not (Test-Path -LiteralPath $path)) { continue }

        $size = Get-FolderSizeWithSpinner -Path $path -Activity 'Measuring Microsoft Office cache'
        $status = if ($size -gt 2GB) { 'Large' } elseif ($size -gt 500MB) { 'Review' } else { 'Info' }

        $r = Add-Result 35 'OfficeCache' $path $status `
            'Microsoft Office document/cache location.' `
            'Close Office applications before considering supported cache cleanup; this module is report-only.' `
            $size
        [void]$local.Add($r)
    }

    if ($local.Count -eq 0) {
        $r = Add-Result 35 'OfficeCache' 'Office document cache' 'Not found' `
            'No common Office document-cache directory was found.' `
            'No action required.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Microsoft Office caches'
    return $local
}

# ---------------------------------------------------------------------------
# 36. Microsoft Store Cache
# ---------------------------------------------------------------------------
function Invoke-ScanStoreCache {
    Write-Title '36. Microsoft Store Cache'
    $local = New-Object System.Collections.ArrayList

    $packagesRoot = Join-Path $env:LOCALAPPDATA 'Packages'
    $targets = @()

    if (Test-Path -LiteralPath $packagesRoot) {
        $targets = @(
            Get-ChildItem -LiteralPath $packagesRoot -Directory -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -like 'Microsoft.WindowsStore_*' -or $_.Name -like 'Microsoft.StorePurchaseApp_*' }
        )
    }

    foreach ($pkg in $targets) {
        foreach ($sub in @('LocalCache','TempState','AC\INetCache')) {
            $path = Join-Path $pkg.FullName $sub
            if (-not (Test-Path -LiteralPath $path)) { continue }

            $size = Get-FolderSizeSafe -Path $path
            $status = if ($size -gt 1GB) { 'Large' } elseif ($size -gt 250MB) { 'Review' } else { 'Info' }

            $r = Add-Result 36 'StoreCache' $path $status `
                "Package=$($pkg.Name)" `
                'Use Microsoft Store reset/repair controls when troubleshooting; this module does not delete package data.' `
                $size
            [void]$local.Add($r)
        }
    }

    if ($local.Count -eq 0) {
        $r = Add-Result 36 'StoreCache' 'Microsoft Store cache' 'No data' `
            'No common Store cache directory was found or accessible.' `
            'No action required.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Microsoft Store cache'
    return $local
}

# ---------------------------------------------------------------------------
# 37. Broken Shortcuts
# ---------------------------------------------------------------------------
function Invoke-ScanBrokenShortcuts {
    Write-Title '37. Broken Shortcuts'
    $local = New-Object System.Collections.ArrayList

    $roots = @(
        [Environment]::GetFolderPath('Desktop'),
        [Environment]::GetFolderPath('CommonDesktopDirectory'),
        [Environment]::GetFolderPath('StartMenu'),
        [Environment]::GetFolderPath('CommonStartMenu')
    ) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and (Test-Path -LiteralPath $_) } | Select-Object -Unique

    $shell = $null
    try { $shell = New-Object -ComObject WScript.Shell } catch {}

    if ($null -eq $shell) {
        $r = Add-Result 37 'Shortcuts' 'WScript.Shell' 'Error' `
            'Shortcut resolver could not be created.' `
            'Run the module again in Windows PowerShell.'
        [void]$local.Add($r)
    } else {
        $links = @()
        foreach ($root in $roots) {
            $links += @(Get-ChildItem -LiteralPath $root -Filter '*.lnk' -File -Recurse -ErrorAction SilentlyContinue)
        }

        $step = 0
        foreach ($lnk in $links) {
            $step++
            if (($step % 20) -eq 0) {
                Write-SpinnerFrame -Activity ("Checking shortcuts ({0}/{1})" -f $step,$links.Count) -Step $step
            }

            try {
                $shortcut = $shell.CreateShortcut($lnk.FullName)
                $target = [Environment]::ExpandEnvironmentVariables([string]$shortcut.TargetPath)
                if (-not [string]::IsNullOrWhiteSpace($target) -and -not (Test-Path -LiteralPath $target -ErrorAction SilentlyContinue)) {
                    $r = Add-Result 37 'Shortcuts' $lnk.FullName 'Broken' `
                        "Target not found: $target" `
                        'Verify the application was removed before deleting the shortcut.'
                    [void]$local.Add($r)
                }
            } catch {}
        }

        if ($links.Count -gt 0) {
            Complete-Spinner -Activity ("Checking shortcuts ({0} checked)" -f $links.Count)
        }
    }

    if ($local.Count -eq 0) {
        $r = Add-Result 37 'Shortcuts' 'Desktop and Start Menu shortcuts' 'Healthy' `
            'No broken .lnk target was found in the scanned locations.' `
            'No action required.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Broken shortcut scan'
    return $local
}

# ---------------------------------------------------------------------------
# 38. Persistent / Static Routes
# ---------------------------------------------------------------------------
function Invoke-ScanStaticRoutes {
    Write-Title '38. Persistent / Static Routes'
    $local = New-Object System.Collections.ArrayList

    if (Test-CommandAvailable 'Get-NetRoute') {
        try {
            $routes = @()
            try {
                $routes = @(Get-NetRoute -PolicyStore PersistentStore -ErrorAction Stop)
            } catch {
                $routes = @(Get-NetRoute -ErrorAction Stop | Where-Object { $_.Protocol -eq 'NetMgmt' })
            }

            foreach ($rte in $routes | Sort-Object DestinationPrefix, InterfaceIndex) {
                $r = Add-Result 38 'StaticRoute' $rte.DestinationPrefix 'Review' `
                    ("NextHop={0} | IfIndex={1} | Metric={2} | Protocol={3}" -f $rte.NextHop,$rte.InterfaceIndex,$rte.RouteMetric,$rte.Protocol) `
                    'Persistent routes can be intentional. Verify VPN, corporate, lab or virtualization requirements before changing them.'
                [void]$local.Add($r)
            }
        } catch {
            $r = Add-Result 38 'StaticRoute' 'Route inventory' 'Error' $_.Exception.Message 'Review route configuration manually.'
            [void]$local.Add($r)
        }
    } else {
        $r = Add-Result 38 'StaticRoute' 'Get-NetRoute' 'Unavailable' `
            'Get-NetRoute is not available in this PowerShell environment.' `
            'No route changes were made.'
        [void]$local.Add($r)
    }

    if ($local.Count -eq 0) {
        $r = Add-Result 38 'StaticRoute' 'Persistent routes' 'Healthy' `
            'No persistent/static routes were found by this scan.' `
            'No action required.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Persistent/static routes'
    return $local
}

# ---------------------------------------------------------------------------
# 39. Network Adapter Inventory
# ---------------------------------------------------------------------------
function Invoke-ScanNetworkAdapters {
    Write-Title '39. Network Adapter Inventory'
    $local = New-Object System.Collections.ArrayList

    if (Test-CommandAvailable 'Get-NetAdapter') {
        try {
            $adapters = @(Get-NetAdapter -IncludeHidden -ErrorAction Stop | Sort-Object Name)
            foreach ($a in $adapters) {
                $status = if ($a.Status -eq 'Up') { 'Active' } elseif ($a.Status -eq 'Disabled') { 'Disabled' } else { [string]$a.Status }
                $r = Add-Result 39 'NetworkAdapter' $a.Name $status `
                    ("Description={0} | MAC={1} | LinkSpeed={2} | IfIndex={3}" -f $a.InterfaceDescription,$a.MacAddress,$a.LinkSpeed,$a.ifIndex) `
                    'Disabled/hidden adapters may belong to VPN, Hyper-V, WSL or old hardware. Review before removal.'
                [void]$local.Add($r)
            }
        } catch {
            $r = Add-Result 39 'NetworkAdapter' 'Network adapters' 'Error' $_.Exception.Message 'Review Device Manager / Network Connections.'
            [void]$local.Add($r)
        }
    } else {
        $r = Add-Result 39 'NetworkAdapter' 'Get-NetAdapter' 'Unavailable' 'Get-NetAdapter is unavailable.' 'No action performed.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Network adapters'
    return $local
}

# ---------------------------------------------------------------------------
# 40. Print Queue and Spooler
# ---------------------------------------------------------------------------
function Invoke-ScanPrintQueue {
    Write-Title '40. Print Queue and Spooler'
    $local = New-Object System.Collections.ArrayList

    try {
        $spooler = Get-Service -Name Spooler -ErrorAction Stop
        $r = Add-Result 40 'Printing' 'Print Spooler' ([string]$spooler.Status) `
            ("StartType={0}" -f $spooler.StartType) `
            'Do not disable the Print Spooler if this computer prints or uses PDF/virtual printer workflows.'
        [void]$local.Add($r)
    } catch {}

    if (Test-CommandAvailable 'Get-Printer') {
        try {
            foreach ($p in @(Get-Printer -ErrorAction Stop | Sort-Object Name)) {
                $r = Add-Result 40 'Printer' $p.Name 'Info' `
                    ("Driver={0} | Port={1} | Shared={2}" -f $p.DriverName,$p.PortName,$p.Shared) `
                    'Remove only printers that are confirmed unused.'
                [void]$local.Add($r)
            }
        } catch {}
    }

    $spoolPath = Join-Path $env:WINDIR 'System32\spool\PRINTERS'
    if (Test-Path -LiteralPath $spoolPath) {
        $jobs = @(Get-ChildItem -LiteralPath $spoolPath -File -Force -ErrorAction SilentlyContinue)
        $sum = [long](Get-SafePropertySum -InputObject $jobs -Property 'Length')
        if ($null -eq $sum) { $sum = 0L }

        $r = Add-Result 40 'PrintSpool' 'Spool queue files' $(if($jobs.Count -gt 0){'Review'}else{'Healthy'}) `
            ("Queued spool files: {0}" -f $jobs.Count) `
            'Do not delete spool files while printing. Cancel stuck jobs through the print queue first.' `
            ([long]$sum)
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Printing and spooler'
    return $local
}

# ---------------------------------------------------------------------------
# 41. Advertising ID and Diagnostic Data
# ---------------------------------------------------------------------------
function Invoke-ScanPrivacySettings {
    Write-Title '41. Advertising ID and Diagnostic Data'
    $local = New-Object System.Collections.ArrayList

    $adPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo'
    if (Test-Path -LiteralPath $adPath) {
        try {
            $p = Get-ItemProperty -LiteralPath $adPath -ErrorAction Stop
            $enabled = if ($p.PSObject.Properties.Name -contains 'Enabled') { [int]$p.Enabled } else { $null }
            $r = Add-Result 41 'Privacy' 'Advertising ID' 'Info' `
                ("Enabled registry value: {0}" -f $(if($null -eq $enabled){'Not set'}else{$enabled})) `
                'Review this setting in Windows Privacy settings. No privacy setting is changed automatically.'
            [void]$local.Add($r)
        } catch {}
    } else {
        $r = Add-Result 41 'Privacy' 'Advertising ID' 'Not configured' 'AdvertisingInfo key not found for the current user.' 'Review Windows Privacy settings if desired.'
        [void]$local.Add($r)
    }

    $telemetryPaths = @(
        'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection',
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection'
    )

    $telemetryFound = $false
    foreach ($path in $telemetryPaths) {
        if (-not (Test-Path -LiteralPath $path)) { continue }
        try {
            $p = Get-ItemProperty -LiteralPath $path -ErrorAction Stop
            if ($p.PSObject.Properties.Name -contains 'AllowTelemetry') {
                $telemetryFound = $true
                $r = Add-Result 41 'Privacy' 'Diagnostic data policy' 'Info' `
                    ("AllowTelemetry={0} | Path={1}" -f $p.AllowTelemetry,$path) `
                    'Interpret policy values according to your Windows edition and organization policy. No change is made.'
                [void]$local.Add($r)
            }
        } catch {}
    }

    if (-not $telemetryFound) {
        $r = Add-Result 41 'Privacy' 'Diagnostic data policy' 'Default/Not set' `
            'No explicit AllowTelemetry policy value was found in the scanned registry locations.' `
            'Review Settings > Privacy & security > Diagnostics & feedback.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Privacy settings'
    return $local
}

# ---------------------------------------------------------------------------
# 42. Clipboard and Activity History
# ---------------------------------------------------------------------------
function Invoke-ScanHistoryPrivacy {
    Write-Title '42. Clipboard and Activity History'
    $local = New-Object System.Collections.ArrayList

    $clipPath = 'HKCU:\Software\Microsoft\Clipboard'
    if (Test-Path -LiteralPath $clipPath) {
        try {
            $p = Get-ItemProperty -LiteralPath $clipPath -ErrorAction Stop
            $value = if ($p.PSObject.Properties.Name -contains 'EnableClipboardHistory') { $p.EnableClipboardHistory } else { 'Not set' }
            $r = Add-Result 42 'PrivacyHistory' 'Clipboard history' 'Info' `
                ("EnableClipboardHistory={0}" -f $value) `
                'Review Settings > System > Clipboard. This module does not clear clipboard history.'
            [void]$local.Add($r)
        } catch {}
    } else {
        $r = Add-Result 42 'PrivacyHistory' 'Clipboard history' 'Not configured' `
            'Clipboard registry key was not found for the current user.' `
            'Review Settings > System > Clipboard if needed.'
        [void]$local.Add($r)
    }

    $activityPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'
    $names = @('EnableActivityFeed','PublishUserActivities','UploadUserActivities')
    if (Test-Path -LiteralPath $activityPath) {
        try {
            $p = Get-ItemProperty -LiteralPath $activityPath -ErrorAction Stop
            foreach ($name in $names) {
                if ($p.PSObject.Properties.Name -contains $name) {
                    $r = Add-Result 42 'PrivacyHistory' $name 'Info' `
                        ("Policy value: {0}" -f $p.$name) `
                        'Policy value is reported only; no automatic change is made.'
                    [void]$local.Add($r)
                }
            }
        } catch {}
    }

    Show-ResultTable -Data $local -Title 'Clipboard and activity-history settings'
    return $local
}


# ---------------------------------------------------------------------------
# 43. Windows Update Download Cache
# ---------------------------------------------------------------------------
function Invoke-ScanWindowsUpdateCache {
    Write-Title '43. Windows Update Download Cache'
    $local = New-Object System.Collections.ArrayList
    $path = Join-Path $env:WINDIR 'SoftwareDistribution\Download'

    if (Test-Path -LiteralPath $path) {
        $size = Get-FolderSizeWithSpinner -Path $path -Activity 'Measuring Windows Update download cache'
        $files = @(
            Get-ChildItem -LiteralPath $path -File -Recurse -Force -ErrorAction SilentlyContinue
        )
        $oldFiles = @($files | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) })
        $status = if ($size -gt 10GB) { 'Large' } elseif ($size -gt 3GB) { 'Review' } else { 'Info' }

        $r = Add-Result 43 'WindowsUpdateCache' $path $status `
            ("Files={0} | 30+ day files={1}" -f $files.Count,$oldFiles.Count) `
            'Use Windows Update/Storage cleanup mechanisms. This module does not manually delete SoftwareDistribution files.' `
            $size
        [void]$local.Add($r)
    } else {
        $r = Add-Result 43 'WindowsUpdateCache' 'Windows Update download cache' 'No data' `
            'SoftwareDistribution\Download was not found or accessible.' `
            'No action required based on this scan.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Windows Update download cache'
    return $local
}

# ---------------------------------------------------------------------------
# 44. Pending Reboot and Servicing State
# ---------------------------------------------------------------------------
function Invoke-ScanPendingReboot {
    Write-Title '44. Pending Reboot and Servicing State'
    $local = New-Object System.Collections.ArrayList
    $pending = $false

    $checks = @(
        @{Name='Component Based Servicing';Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'},
        @{Name='Windows Update';Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'}
    )

    foreach ($check in $checks) {
        $exists = Test-Path -LiteralPath $check.Path
        if ($exists) { $pending = $true }
        $r = Add-Result 44 'PendingReboot' $check.Name $(if($exists){'Pending'}else{'Clear'}) `
            ("Registry indicator present: {0}" -f $exists) `
            'A pending reboot is not junk; complete the reboot before aggressive maintenance or servicing.'
        [void]$local.Add($r)
    }

    try {
        $session = Get-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' `
            -Name PendingFileRenameOperations -ErrorAction SilentlyContinue
        $renameOperations = Get-SafePropertyValue -InputObject $session -Name 'PendingFileRenameOperations'
        $hasRename = ($null -ne $renameOperations)
        if ($hasRename) { $pending = $true }

        $r = Add-Result 44 'PendingReboot' 'Pending file rename operations' $(if($hasRename){'Pending'}else{'Clear'}) `
            ("PendingFileRenameOperations present: {0}" -f $hasRename) `
            'Pending file operations are normally completed by rebooting Windows.'
        [void]$local.Add($r)
    } catch {}

    if (-not $pending) {
        $r = Add-Result 44 'PendingReboot' 'Overall reboot state' 'Healthy' `
            'No common pending-reboot indicator was detected.' `
            'No action required.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Pending reboot / servicing state'
    return $local
}

# ---------------------------------------------------------------------------
# 45. Windows Maintenance Logs
# ---------------------------------------------------------------------------
function Invoke-ScanMaintenanceLogs {
    Write-Title '45. Windows Maintenance Logs'
    $local = New-Object System.Collections.ArrayList

    $targets = @(
        @{Name='CBS Logs';Path=(Join-Path $env:WINDIR 'Logs\CBS')},
        @{Name='DISM Logs';Path=(Join-Path $env:WINDIR 'Logs\DISM')},
        @{Name='MoSetup Logs';Path=(Join-Path $env:WINDIR 'Logs\MoSetup')},
        @{Name='Panther Setup Logs';Path=(Join-Path $env:WINDIR 'Panther')}
    )

    foreach ($target in $targets) {
        if (-not (Test-Path -LiteralPath $target.Path)) { continue }

        $files = @(
            Get-ChildItem -LiteralPath $target.Path -File -Recurse -Force -ErrorAction SilentlyContinue
        )
        $sum = [long](Get-SafePropertySum -InputObject $files -Property 'Length')
        if ($null -eq $sum) { $sum = 0L }

        $old = @($files | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-90) })
        $status = if ([long]$sum -gt 2GB) { 'Large' } elseif ([long]$sum -gt 500MB) { 'Review' } else { 'Info' }

        $r = Add-Result 45 'MaintenanceLogs' $target.Name $status `
            ("Path={0} | Files={1} | 90+ day files={2}" -f $target.Path,$files.Count,$old.Count) `
            'Logs may be useful for troubleshooting and servicing history. This module is report-only.' `
            ([long]$sum)
        [void]$local.Add($r)
    }

    if ($local.Count -eq 0) {
        $r = Add-Result 45 'MaintenanceLogs' 'Windows maintenance logs' 'No data' `
            'No common maintenance-log directory was accessible.' `
            'No action required.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Windows maintenance logs'
    return $local
}

# ---------------------------------------------------------------------------
# 46. Volume Space and File System Health
# ---------------------------------------------------------------------------
function Invoke-ScanVolumeHealth {
    Write-Title '46. Volume Space and File System Health'
    $local = New-Object System.Collections.ArrayList

    if (Test-CommandAvailable 'Get-Volume') {
        try {
            $volumes = @(Get-Volume -ErrorAction Stop | Sort-Object DriveLetter,FileSystemLabel)
            foreach ($v in $volumes) {
                if ($v.Size -le 0) { continue }

                $freePct = if ($v.Size -gt 0) {
                    [math]::Round(([double]$v.SizeRemaining / [double]$v.Size) * 100,1)
                } else { 0 }

                $status = if ($v.HealthStatus -and $v.HealthStatus -ne 'Healthy') {
                    'Health warning'
                } elseif ($freePct -lt 10) {
                    'Low space'
                } elseif ($freePct -lt 20) {
                    'Review'
                } else {
                    'Healthy'
                }

                $name = if ($v.DriveLetter) {
                    ("{0}: {1}" -f $v.DriveLetter,$v.FileSystemLabel)
                } else {
                    ("Volume {0}" -f $v.UniqueId)
                }

                $r = Add-Result 46 'Volume' $name $status `
                    ("FileSystem={0} | Health={1} | Operational={2} | Free={3}% | FreeBytes={4}" -f `
                        $v.FileSystem,$v.HealthStatus,($v.OperationalStatus -join ','),$freePct,(Format-Bytes ([long]$v.SizeRemaining))) `
                    'Low free space can reduce update and application reliability. This module does not modify partitions or files.' `
                    ([long]$v.Size)
                [void]$local.Add($r)
            }
        } catch {
            $r = Add-Result 46 'Volume' 'Get-Volume' 'Error' $_.Exception.Message 'Review Disk Management / Storage settings.'
            [void]$local.Add($r)
        }
    } else {
        try {
            foreach ($d in @(Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' -ErrorAction Stop)) {
                $freePct = if ($d.Size -gt 0) { [math]::Round(($d.FreeSpace/$d.Size)*100,1) } else { 0 }
                $status = if ($freePct -lt 10) { 'Low space' } elseif ($freePct -lt 20) { 'Review' } else { 'Healthy' }
                $r = Add-Result 46 'Volume' $d.DeviceID $status `
                    ("FileSystem={0} | Free={1}% | FreeBytes={2}" -f $d.FileSystem,$freePct,(Format-Bytes ([long]$d.FreeSpace))) `
                    'This fallback reports local fixed-disk space only.' `
                    ([long]$d.Size)
                [void]$local.Add($r)
            }
        } catch {
            $r = Add-Result 46 'Volume' 'Volume inventory' 'Error' $_.Exception.Message 'Review disk space manually.'
            [void]$local.Add($r)
        }
    }

    Show-ResultTable -Data $local -Title 'Volume and file-system health'
    return $local
}

# ---------------------------------------------------------------------------
# 47. Power Plan and Sleep Configuration
# ---------------------------------------------------------------------------
function Invoke-ScanPowerConfiguration {
    Write-Title '47. Power Plan and Sleep Configuration'
    $local = New-Object System.Collections.ArrayList

    if (-not (Test-CommandAvailable 'powercfg.exe')) {
        $r = Add-Result 47 'Power' 'powercfg.exe' 'Unavailable' 'powercfg.exe was not found.' 'No action performed.'
        [void]$local.Add($r)
        Show-ResultTable -Data $local -Title 'Power configuration'
        return $local
    }

    try {
        $active = (& powercfg.exe /getactivescheme 2>&1) -join ' '
        $r = Add-Result 47 'Power' 'Active power scheme' 'Info' $active `
            'Balanced is normal for many Windows 11 systems. This tool does not force High Performance.'
        [void]$local.Add($r)
    } catch {}

    try {
        $sleep = (& powercfg.exe /a 2>&1) -join [Environment]::NewLine
        $r = Add-Result 47 'Power' 'Available sleep states' 'Info' $sleep `
            'Sleep-state availability depends on hardware, firmware and Modern Standby support.'
        [void]$local.Add($r)
    } catch {}

    Show-ResultTable -Data $local -Title 'Power plan and sleep configuration'
    return $local
}

# ---------------------------------------------------------------------------
# 48. PATH Integrity Analyzer
# ---------------------------------------------------------------------------
function Invoke-ScanPathIntegrity {
    Write-Title '48. PATH Integrity Analyzer'
    $local = New-Object System.Collections.ArrayList

    $sources = @(
        @{Scope='Machine';Value=[Environment]::GetEnvironmentVariable('Path','Machine')},
        @{Scope='User';Value=[Environment]::GetEnvironmentVariable('Path','User')}
    )

    foreach ($src in $sources) {
        if ([string]::IsNullOrWhiteSpace($src.Value)) { continue }

        $seen = @{}
        $index = 0
        foreach ($raw in ($src.Value -split ';')) {
            $index++
            $entry = $raw.Trim().Trim('"')
            if ([string]::IsNullOrWhiteSpace($entry)) { continue }

            $expanded = [Environment]::ExpandEnvironmentVariables($entry)
            $key = $expanded.TrimEnd('\').ToLowerInvariant()
            $duplicate = $seen.ContainsKey($key)
            if (-not $duplicate) { $seen[$key] = $true }

            $exists = Test-Path -LiteralPath $expanded -PathType Container -ErrorAction SilentlyContinue
            $status = if ($duplicate) { 'Duplicate' } elseif (-not $exists) { 'Missing' } else { 'Present' }

            $r = Add-Result 48 'PATH' ("{0} PATH #{1}" -f $src.Scope,$index) $status `
                ("Raw={0} | Expanded={1}" -f $entry,$expanded) `
                'Do not remove a PATH entry until the related application/toolchain is identified and verified.'
            [void]$local.Add($r)
        }
    }

    Show-ResultTable -Data $local -Title 'PATH entries'
    return $local
}

# ---------------------------------------------------------------------------
# 49. Mapped Network Drives
# ---------------------------------------------------------------------------
function Invoke-ScanMappedDrives {
    Write-Title '49. Mapped Network Drives'
    $local = New-Object System.Collections.ArrayList
    $seen = @{}

    if (Test-CommandAvailable 'Get-SmbMapping') {
        try {
            foreach ($m in @(Get-SmbMapping -ErrorAction Stop)) {
                $key = ("{0}|{1}" -f $m.LocalPath,$m.RemotePath).ToLowerInvariant()
                if ($seen.ContainsKey($key)) { continue }
                $seen[$key] = $true

                $r = Add-Result 49 'MappedDrive' ([string]$m.LocalPath) ([string]$m.Status) `
                    ("RemotePath={0} | Persistent={1}" -f $m.RemotePath,$m.Persistent) `
                    'Disconnect only mappings that are confirmed obsolete.'
                [void]$local.Add($r)
            }
        } catch {}
    }

    try {
        foreach ($d in @(Get-PSDrive -PSProvider FileSystem -ErrorAction SilentlyContinue)) {
            if ([string]::IsNullOrWhiteSpace([string]$d.DisplayRoot)) { continue }
            if (-not ([string]$d.DisplayRoot).StartsWith('\\')) { continue }

            $key = ("{0}|{1}" -f $d.Name,$d.DisplayRoot).ToLowerInvariant()
            if ($seen.ContainsKey($key)) { continue }
            $seen[$key] = $true

            $r = Add-Result 49 'MappedDrive' ("{0}:" -f $d.Name) 'Info' `
                ("RemotePath={0}" -f $d.DisplayRoot) `
                'Verify availability and business need before disconnecting the mapping.'
            [void]$local.Add($r)
        }
    } catch {}

    if ($local.Count -eq 0) {
        $r = Add-Result 49 'MappedDrive' 'Mapped network drives' 'Healthy' `
            'No mapped network drives were found for the current session.' `
            'No action required.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Mapped network drives'
    return $local
}

# ---------------------------------------------------------------------------
# 50. SMB Shares Inventory
# ---------------------------------------------------------------------------
function Invoke-ScanSmbShares {
    Write-Title '50. SMB Shares Inventory'
    $local = New-Object System.Collections.ArrayList

    if (Test-CommandAvailable 'Get-SmbShare') {
        try {
            foreach ($share in @(Get-SmbShare -ErrorAction Stop | Sort-Object Name)) {
                $isSystem = $share.Special -or $share.Name -in @('ADMIN$','C$','IPC$')
                $status = if ($isSystem) { 'System' } else { 'Review' }

                $r = Add-Result 50 'SMBShare' $share.Name $status `
                    ("Path={0} | Description={1} | Special={2} | Temporary={3}" -f `
                        $share.Path,$share.Description,$share.Special,$share.Temporary) `
                    'Non-system SMB shares can expose data to the network. Verify ownership and need before changing share configuration.'
                [void]$local.Add($r)
            }
        } catch {
            $r = Add-Result 50 'SMBShare' 'SMB shares' 'Error' $_.Exception.Message 'Administrator rights may be required.'
            [void]$local.Add($r)
        }
    } else {
        $r = Add-Result 50 'SMBShare' 'Get-SmbShare' 'Unavailable' `
            'Get-SmbShare is not available in this environment.' `
            'No share configuration was changed.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'SMB shares'
    return $local
}

# ---------------------------------------------------------------------------
# 51. Xbox Game Bar and Capture Storage
# ---------------------------------------------------------------------------
function Invoke-ScanXboxCapture {
    Write-Title '51. Xbox Game Bar and Capture Storage'
    $local = New-Object System.Collections.ArrayList

    $gameConfigPath = 'HKCU:\System\GameConfigStore'
    if (Test-Path -LiteralPath $gameConfigPath) {
        try {
            $p = Get-ItemProperty -LiteralPath $gameConfigPath -ErrorAction Stop
            if ($p.PSObject.Properties.Name -contains 'GameDVR_Enabled') {
                $r = Add-Result 51 'XboxGameBar' 'Game DVR' 'Info' `
                    ("GameDVR_Enabled={0}" -f $p.GameDVR_Enabled) `
                    'Review Windows Gaming settings if background capture is not required.'
                [void]$local.Add($r)
            }
        } catch {}
    }

    $capturePath = Join-Path ([Environment]::GetFolderPath('MyVideos')) 'Captures'
    if (Test-Path -LiteralPath $capturePath) {
        $size = Get-FolderSizeWithSpinner -Path $capturePath -Activity 'Measuring Xbox/Game Bar capture storage'
        $files = @(Get-ChildItem -LiteralPath $capturePath -File -Recurse -ErrorAction SilentlyContinue)
        $status = if ($size -gt 20GB) { 'Large' } elseif ($size -gt 5GB) { 'Review' } else { 'Info' }

        $r = Add-Result 51 'XboxCaptures' $capturePath $status `
            ("Capture files={0}" -f $files.Count) `
            'Review recordings before deleting them; this module is report-only.' `
            $size
        [void]$local.Add($r)
    } else {
        $r = Add-Result 51 'XboxCaptures' 'Game Bar Captures folder' 'Not found' `
            'No standard Videos\Captures folder was found.' `
            'No action required.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Xbox Game Bar and captures'
    return $local
}

# ---------------------------------------------------------------------------
# 52. PowerShell Module Footprint
# ---------------------------------------------------------------------------
function Invoke-ScanPowerShellModules {
    Write-Title '52. PowerShell Module Footprint'
    $local = New-Object System.Collections.ArrayList

    $roots = @(
        $env:PSModulePath -split [IO.Path]::PathSeparator |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and (Test-Path -LiteralPath $_) } |
            Select-Object -Unique
    )

    $moduleRows = New-Object System.Collections.ArrayList
    $step = 0

    foreach ($root in $roots) {
        $dirs = @(Get-ChildItem -LiteralPath $root -Directory -ErrorAction SilentlyContinue)
        foreach ($dir in $dirs) {
            $step++
            if (($step % 10) -eq 0) {
                Write-SpinnerFrame -Activity ("Measuring PowerShell modules ({0})" -f $step) -Step $step
            }

            $size = Get-FolderSizeSafe -Path $dir.FullName
            $versions = @(
                Get-ChildItem -LiteralPath $dir.FullName -Directory -ErrorAction SilentlyContinue |
                    Where-Object { $_.Name -match '^\d+(\.\d+){1,3}$' }
            )

            [void]$moduleRows.Add([pscustomobject]@{
                Name=$dir.Name
                Root=$root
                SizeBytes=[long]$size
                Versions=$versions.Count
            })
        }
    }

    if ($step -gt 0) {
        Complete-Spinner -Activity ("Measured {0} PowerShell module folder(s)" -f $step)
    }

    foreach ($m in @($moduleRows | Sort-Object SizeBytes -Descending | Select-Object -First 40)) {
        $status = if ($m.SizeBytes -gt 1GB) { 'Large' } elseif ($m.Versions -gt 3) { 'Review' } else { 'Info' }
        $r = Add-Result 52 'PowerShellModule' $m.Name $status `
            ("Root={0} | VersionFolders={1}" -f $m.Root,$m.Versions) `
            'Multiple module versions may be intentional. Remove modules only with package/module-management tooling and after dependency review.' `
            $m.SizeBytes
        [void]$local.Add($r)
    }

    if ($local.Count -eq 0) {
        $r = Add-Result 52 'PowerShellModule' 'PowerShell modules' 'No data' `
            'No module folders were found in the current PSModulePath.' `
            'No action required.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Largest PowerShell module folders'
    return $local
}

# ---------------------------------------------------------------------------
# 53. Windows Installer Cache Analyzer
# ---------------------------------------------------------------------------
function Invoke-ScanInstallerCache {
    Write-Title '53. Windows Installer Cache Analyzer'
    $local = New-Object System.Collections.ArrayList
    $path = Join-Path $env:WINDIR 'Installer'

    if (-not (Test-Path -LiteralPath $path)) {
        $r = Add-Result 53 'InstallerCache' 'Windows Installer cache' 'Not found' `
            'The Windows Installer cache directory was not found or accessible.' `
            'No action required.'
        [void]$local.Add($r)
        Show-ResultTable -Data $local -Title 'Windows Installer cache'
        return $local
    }

    $size = Get-FolderSizeWithSpinner -Path $path -Activity 'Measuring Windows Installer cache'
    $packages = @(
        Get-ChildItem -LiteralPath $path -File -Recurse -Force -ErrorAction SilentlyContinue |
            Where-Object { $_.Extension -in @('.msi','.msp') }
    )

    $status = if ($size -gt 20GB) { 'Large' } elseif ($size -gt 10GB) { 'Review' } else { 'Info' }
    $r = Add-Result 53 'InstallerCache' 'Windows Installer cache total' $status `
        ("Path={0} | MSI/MSP files={1}" -f $path,$packages.Count) `
        'Never delete C:\Windows\Installer files based only on age or size. They may be required for repair, patching and uninstall.' `
        $size
    [void]$local.Add($r)

    foreach ($pkg in @($packages | Sort-Object Length -Descending | Select-Object -First 20)) {
        $r = Add-Result 53 'InstallerPackage' $pkg.Name 'Info' `
            ("Path={0} | LastWrite={1}" -f $pkg.FullName,$pkg.LastWriteTime) `
            'Shown for size visibility only. No automatic deletion is provided.' `
            ([long]$pkg.Length)
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Windows Installer cache'
    return $local
}

# ---------------------------------------------------------------------------
# 54. User Profile Inventory
# ---------------------------------------------------------------------------
function Invoke-ScanUserProfiles {
    Write-Title '54. User Profile Inventory'
    $local = New-Object System.Collections.ArrayList

    try {
        $profiles = @(Get-CimInstance Win32_UserProfile -ErrorAction Stop | Sort-Object LocalPath)
        foreach ($p in $profiles) {
            $lastUse = $p.LastUseTime
            $ageDays = $null
            if ($lastUse) {
                try { $ageDays = [math]::Floor(((Get-Date) - [datetime]$lastUse).TotalDays) } catch {}
            }

            $status = if ($p.Special) {
                'System'
            } elseif ($p.Loaded) {
                'Loaded'
            } elseif ($null -ne $ageDays -and $ageDays -ge 180) {
                'Stale?'
            } else {
                'Info'
            }

            $detail = "SID=$($p.SID) | Loaded=$($p.Loaded) | Special=$($p.Special)"
            if ($null -ne $ageDays) {
                $detail += " | LastUse=$lastUse | AgeDays=$ageDays"
            }

            $r = Add-Result 54 'UserProfile' $p.LocalPath $status $detail `
                'Do not delete user-profile folders manually. Confirm account ownership, backups, encryption and organizational policy first.'
            [void]$local.Add($r)
        }
    } catch {
        $r = Add-Result 54 'UserProfile' 'User profiles' 'Error' $_.Exception.Message `
            'Administrator rights may be required to inventory all profiles.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Local user profiles'
    return $local
}


# ---------------------------------------------------------------------------
# 55. Battery Health and Capacity Analyzer
# ---------------------------------------------------------------------------
function Invoke-ScanBatteryHealth {
    Write-Title '55. Battery Health and Capacity Analyzer'
    $local = New-Object System.Collections.ArrayList

    try {
        $staticData = @(Get-CimInstance -Namespace 'root\wmi' -ClassName BatteryStaticData -ErrorAction Stop)
        $fullData = @(Get-CimInstance -Namespace 'root\wmi' -ClassName BatteryFullChargedCapacity -ErrorAction SilentlyContinue)
        $cycleData = @(Get-CimInstance -Namespace 'root\wmi' -ClassName BatteryCycleCount -ErrorAction SilentlyContinue)

        if ($staticData.Count -eq 0) {
            $r = Add-Result 55 'Battery' 'Battery inventory' 'Not applicable' `
                'No battery was reported by the Windows battery WMI provider.' `
                'This is normal for desktop computers.'
            [void]$local.Add($r)
        }

        foreach ($b in $staticData) {
            $instance = [string]$b.InstanceName
            $design = 0L
            if ($b.PSObject.Properties.Name -contains 'DesignedCapacity') { $design = [long]$b.DesignedCapacity }

            $full = 0L
            $fullMatch = $fullData | Where-Object InstanceName -eq $instance | Select-Object -First 1
            if ($fullMatch -and $fullMatch.PSObject.Properties.Name -contains 'FullChargedCapacity') {
                $full = [long]$fullMatch.FullChargedCapacity
            }

            $cycles = $null
            $cycleMatch = $cycleData | Where-Object InstanceName -eq $instance | Select-Object -First 1
            if ($cycleMatch -and $cycleMatch.PSObject.Properties.Name -contains 'CycleCount') {
                $cycles = $cycleMatch.CycleCount
            }

            $wear = $null
            if ($design -gt 0 -and $full -gt 0) {
                $wear = [math]::Round((1 - ([double]$full / [double]$design)) * 100,1)
                if ($wear -lt 0) { $wear = 0 }
            }

            $status = if ($null -ne $wear -and $wear -ge 40) { 'Warning' } elseif ($null -ne $wear -and $wear -ge 20) { 'Review' } else { 'Info' }
            $detail = "DesignCapacity=$design mWh | FullChargeCapacity=$full mWh"
            if ($null -ne $wear) { $detail += " | EstimatedWear=$wear%" }
            if ($null -ne $cycles) { $detail += " | CycleCount=$cycles" }

            $r = Add-Result 55 'Battery' $instance $status $detail `
                'Battery wear is an estimate based on firmware-reported capacities. Replace a battery only after considering runtime and device behavior.'
            [void]$local.Add($r)
        }
    } catch {
        $r = Add-Result 55 'Battery' 'Battery health provider' 'Unavailable' $_.Exception.Message `
            'Battery WMI data may be unavailable on some hardware. No setting was changed.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Battery health and capacity'
    return $local
}

# ---------------------------------------------------------------------------
# 56. BitLocker and Device Encryption Status
# ---------------------------------------------------------------------------
function Invoke-ScanBitLockerStatus {
    Write-Title '56. BitLocker and Device Encryption Status'
    $local = New-Object System.Collections.ArrayList

    if (Test-CommandAvailable 'Get-BitLockerVolume') {
        try {
            $volumes = @(Get-BitLockerVolume -ErrorAction Stop)
            foreach ($v in $volumes) {
                $status = if ([string]$v.ProtectionStatus -match 'On') { 'Protected' } elseif ([string]$v.VolumeStatus -match 'FullyDecrypted') { 'Unencrypted' } else { 'Review' }
                $r = Add-Result 56 'BitLocker' ([string]$v.MountPoint) $status `
                    ("VolumeStatus={0} | ProtectionStatus={1} | Encryption={2}% | Method={3} | Lock={4}" -f `
                        $v.VolumeStatus,$v.ProtectionStatus,$v.EncryptionPercentage,$v.EncryptionMethod,$v.LockStatus) `
                    'Encryption choices depend on organization policy and recovery-key availability. This module is report-only.'
                [void]$local.Add($r)
            }
        } catch {
            $r = Add-Result 56 'BitLocker' 'BitLocker inventory' 'Error' $_.Exception.Message `
                'Run as administrator if BitLocker status cannot be queried.'
            [void]$local.Add($r)
        }
    } elseif (Test-CommandAvailable 'manage-bde.exe') {
        try {
            $raw = (& manage-bde.exe -status 2>&1) -join [Environment]::NewLine
            $r = Add-Result 56 'BitLocker' 'manage-bde status' 'Info' $raw `
                'PowerShell BitLocker cmdlets were unavailable; raw manage-bde status is shown. No encryption setting was changed.'
            [void]$local.Add($r)
        } catch {
            $r = Add-Result 56 'BitLocker' 'manage-bde.exe' 'Error' $_.Exception.Message 'Review device encryption manually.'
            [void]$local.Add($r)
        }
    } else {
        $r = Add-Result 56 'BitLocker' 'BitLocker tools' 'Unavailable' 'No supported BitLocker status command was found.' 'No action performed.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'BitLocker / device encryption status'
    return $local
}

# ---------------------------------------------------------------------------
# 57. Windows Firewall Profile Health
# ---------------------------------------------------------------------------
function Invoke-ScanFirewallProfiles {
    Write-Title '57. Windows Firewall Profile Health'
    $local = New-Object System.Collections.ArrayList

    if (Test-CommandAvailable 'Get-NetFirewallProfile') {
        try {
            foreach ($p in @(Get-NetFirewallProfile -ErrorAction Stop | Sort-Object Name)) {
                $status = if ($p.Enabled) { 'Enabled' } else { 'Warning' }
                $r = Add-Result 57 'FirewallProfile' ([string]$p.Name) $status `
                    ("Enabled={0} | DefaultInboundAction={1} | DefaultOutboundAction={2} | NotifyOnListen={3}" -f `
                        $p.Enabled,$p.DefaultInboundAction,$p.DefaultOutboundAction,$p.NotifyOnListen) `
                    'A disabled firewall profile can increase exposure. Verify organization policy before changing firewall configuration.'
                [void]$local.Add($r)
            }
        } catch {
            $r = Add-Result 57 'FirewallProfile' 'Windows Firewall profiles' 'Error' $_.Exception.Message 'Review Windows Defender Firewall settings.'
            [void]$local.Add($r)
        }
    } else {
        $r = Add-Result 57 'FirewallProfile' 'Get-NetFirewallProfile' 'Unavailable' 'Firewall PowerShell cmdlets are unavailable.' 'No action performed.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Windows Firewall profiles'
    return $local
}

# ---------------------------------------------------------------------------
# 58. Orphaned Firewall Application Rules
# ---------------------------------------------------------------------------
function Invoke-ScanOrphanFirewallRules {
    Write-Title '58. Orphaned Firewall Application Rules'
    $local = New-Object System.Collections.ArrayList

    if (-not (Test-CommandAvailable 'Get-NetFirewallApplicationFilter')) {
        $r = Add-Result 58 'FirewallRule' 'Firewall application filters' 'Unavailable' `
            'Get-NetFirewallApplicationFilter is unavailable.' `
            'No firewall rule was changed.'
        [void]$local.Add($r)
        Show-ResultTable -Data $local -Title 'Orphaned firewall application paths'
        return $local
    }

    try {
        $filters = @(Get-NetFirewallApplicationFilter -All -ErrorAction Stop)
        $step = 0
        foreach ($filter in $filters) {
            $step++
            if (($step % 100) -eq 0) {
                Write-SpinnerFrame -Activity ("Checking firewall application paths ({0}/{1})" -f $step,$filters.Count) -Step $step
            }

            $program = [string]$filter.Program
            if ([string]::IsNullOrWhiteSpace($program)) { continue }
            if ($program -in @('Any','System')) { continue }

            $expanded = [Environment]::ExpandEnvironmentVariables($program.Trim().Trim('"'))
            if (-not [System.IO.Path]::IsPathRooted($expanded)) { continue }

            if (-not (Test-Path -LiteralPath $expanded -PathType Leaf -ErrorAction SilentlyContinue)) {
                $r = Add-Result 58 'FirewallRule' $program 'Orphan?' `
                    ("Application path does not exist | InstanceID={0}" -f $filter.InstanceID) `
                    'A missing executable can indicate an old application rule. Verify the owning application/rule before removing anything.'
                [void]$local.Add($r)
            }
        }
        if ($filters.Count -gt 0) { Complete-Spinner -Activity ("Checked {0} firewall application filter(s)" -f $filters.Count) }
    } catch {
        $r = Add-Result 58 'FirewallRule' 'Firewall application rules' 'Error' $_.Exception.Message 'Administrator rights may be required.'
        [void]$local.Add($r)
    }

    if ($local.Count -eq 0) {
        $r = Add-Result 58 'FirewallRule' 'Application-path firewall rules' 'Healthy' `
            'No firewall application filter with a missing absolute executable path was found.' `
            'No action required.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Orphaned firewall application paths'
    return $local
}

# ---------------------------------------------------------------------------
# 59. Microsoft Defender Health
# ---------------------------------------------------------------------------
function Invoke-ScanDefenderHealth {
    Write-Title '59. Microsoft Defender Health'
    $local = New-Object System.Collections.ArrayList

    if (-not (Test-CommandAvailable 'Get-MpComputerStatus')) {
        $r = Add-Result 59 'DefenderHealth' 'Microsoft Defender' 'Unavailable' 'Get-MpComputerStatus is unavailable.' 'No action performed.'
        [void]$local.Add($r)
        Show-ResultTable -Data $local -Title 'Microsoft Defender health'
        return $local
    }

    try {
        $s = Get-MpComputerStatus -ErrorAction Stop
        $signatureAge = $null
        if ($s.AntivirusSignatureLastUpdated) {
            $signatureAge = [math]::Floor(((Get-Date) - [datetime]$s.AntivirusSignatureLastUpdated).TotalDays)
        }

        $protectionStatus = if ($s.AntivirusEnabled -and $s.RealTimeProtectionEnabled) { 'Healthy' } else { 'Warning' }
        $r = Add-Result 59 'DefenderHealth' 'Protection status' $protectionStatus `
            ("AntivirusEnabled={0} | RealTimeProtection={1} | Antispyware={2} | NIS={3}" -f `
                $s.AntivirusEnabled,$s.RealTimeProtectionEnabled,$s.AntispywareEnabled,$s.NISEnabled) `
            'Unexpectedly disabled real-time protection should be investigated, especially on unmanaged clients.'
        [void]$local.Add($r)

        $sigStatus = if ($null -ne $signatureAge -and $signatureAge -gt 7) { 'Warning' } elseif ($null -ne $signatureAge -and $signatureAge -gt 3) { 'Review' } else { 'Info' }
        $r = Add-Result 59 'DefenderHealth' 'Signature status' $sigStatus `
            ("LastUpdated={0} | AgeDays={1} | Version={2}" -f $s.AntivirusSignatureLastUpdated,$signatureAge,$s.AntivirusSignatureVersion) `
            'Old signatures may indicate update/connectivity or policy issues.'
        [void]$local.Add($r)

        $r = Add-Result 59 'DefenderHealth' 'Scan and engine information' 'Info' `
            ("Engine={0} | QuickScanAge={1} | FullScanAge={2}" -f $s.AMEngineVersion,$s.QuickScanAge,$s.FullScanAge) `
            'Scan age is informational; use organizational policy to decide the required scan cadence.'
        [void]$local.Add($r)
    } catch {
        $r = Add-Result 59 'DefenderHealth' 'Microsoft Defender status' 'Error' $_.Exception.Message 'Review Windows Security and Defender service state.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Microsoft Defender health'
    return $local
}

# ---------------------------------------------------------------------------
# 60. Time Synchronization / NTP Health
# ---------------------------------------------------------------------------
function Invoke-ScanTimeSync {
    Write-Title '60. Time Synchronization / NTP Health'
    $local = New-Object System.Collections.ArrayList

    try {
        $svc = Get-Service -Name W32Time -ErrorAction Stop
        $r = Add-Result 60 'TimeSync' 'Windows Time service' ([string]$svc.Status) `
            ("StartType={0}" -f $svc.StartType) `
            'Incorrect time can affect authentication, certificates and logs.'
        [void]$local.Add($r)
    } catch {
        $r = Add-Result 60 'TimeSync' 'Windows Time service' 'Error' $_.Exception.Message 'Review the Windows Time service.'
        [void]$local.Add($r)
    }

    if (Test-CommandAvailable 'w32tm.exe') {
        try {
            $source = (& w32tm.exe /query /source 2>&1) -join ' '
            $statusRaw = (& w32tm.exe /query /status 2>&1) -join [Environment]::NewLine
            $r = Add-Result 60 'TimeSync' 'Time source' 'Info' ("Source={0}`n{1}" -f $source,$statusRaw) `
                'Verify unexpected Local CMOS Clock, unsynchronized state or domain/NTP source issues.'
            [void]$local.Add($r)
        } catch {
            $r = Add-Result 60 'TimeSync' 'w32tm status' 'Error' $_.Exception.Message 'Review time synchronization manually.'
            [void]$local.Add($r)
        }
    }

    Show-ResultTable -Data $local -Title 'Time synchronization health'
    return $local
}

# ---------------------------------------------------------------------------
# 61. WSL Distribution and VHDX Footprint
# ---------------------------------------------------------------------------
function Invoke-ScanWslFootprint {
    Write-Title '61. WSL Distribution and VHDX Footprint'
    $local = New-Object System.Collections.ArrayList

    if (Test-CommandAvailable 'wsl.exe') {
        try {
            $raw = (& wsl.exe --list --verbose 2>&1) -join [Environment]::NewLine
            $r = Add-Result 61 'WSL' 'Installed WSL distributions' 'Info' $raw `
                'Distribution inventory is report-only. Unregistering a WSL distribution deletes its Linux filesystem and is not offered here.'
            [void]$local.Add($r)
        } catch {}
    }

    $paths = New-Object System.Collections.ArrayList
    $packagesRoot = Join-Path $env:LOCALAPPDATA 'Packages'
    if (Test-Path -LiteralPath $packagesRoot) {
        foreach ($pkg in @(Get-ChildItem -LiteralPath $packagesRoot -Directory -ErrorAction SilentlyContinue)) {
            $vhd = Join-Path $pkg.FullName 'LocalState\ext4.vhdx'
            if (Test-Path -LiteralPath $vhd -PathType Leaf -ErrorAction SilentlyContinue) { [void]$paths.Add($vhd) }
        }
    }

    $wslRoot = Join-Path $env:LOCALAPPDATA 'wsl'
    if (Test-Path -LiteralPath $wslRoot) {
        foreach ($vhd in @(Get-ChildItem -LiteralPath $wslRoot -Filter 'ext4.vhdx' -File -Recurse -ErrorAction SilentlyContinue)) {
            if (-not $paths.Contains($vhd.FullName)) { [void]$paths.Add($vhd.FullName) }
        }
    }

    foreach ($path in $paths) {
        $item = Get-Item -LiteralPath $path -Force -ErrorAction SilentlyContinue
        if (-not $item) { continue }
        $status = if ($item.Length -gt 100GB) { 'Large' } elseif ($item.Length -gt 40GB) { 'Review' } else { 'Info' }
        $r = Add-Result 61 'WSL' $path $status `
            ("LastWrite={0}" -f $item.LastWriteTime) `
            'Do not delete ext4.vhdx manually. Use WSL export/unregister/compact procedures only after backup and validation.' `
            ([long]$item.Length)
        [void]$local.Add($r)
    }

    if ($local.Count -eq 0) {
        $r = Add-Result 61 'WSL' 'WSL' 'Not found' 'No WSL installation or common ext4.vhdx file was detected.' 'No action required.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'WSL distributions and virtual disks'
    return $local
}

# ---------------------------------------------------------------------------
# 62. Hyper-V Virtual Disk Footprint
# ---------------------------------------------------------------------------
function Invoke-ScanHyperVDisks {
    Write-Title '62. Hyper-V Virtual Disk Footprint'
    $local = New-Object System.Collections.ArrayList
    $seen = @{}

    if ((Test-CommandAvailable 'Get-VM') -and (Test-CommandAvailable 'Get-VMHardDiskDrive')) {
        try {
            foreach ($vm in @(Get-VM -ErrorAction Stop)) {
                foreach ($disk in @(Get-VMHardDiskDrive -VMName $vm.Name -ErrorAction SilentlyContinue)) {
                    $path = [string]$disk.Path
                    if ([string]::IsNullOrWhiteSpace($path) -or $seen.ContainsKey($path.ToLowerInvariant())) { continue }
                    $seen[$path.ToLowerInvariant()] = $true
                    $item = Get-Item -LiteralPath $path -Force -ErrorAction SilentlyContinue
                    $size = if ($item) { [long]$item.Length } else { $null }
                    $status = if ($null -ne $size -and $size -gt 200GB) { 'Large' } elseif ($null -ne $size -and $size -gt 80GB) { 'Review' } else { 'Info' }
                    $r = Add-Result 62 'HyperV' $path $status `
                        ("VM={0} | Controller={1}:{2}" -f $vm.Name,$disk.ControllerType,$disk.ControllerNumber) `
                        'Virtual disks can contain complete guest systems. Never delete a VHD/VHDX solely because it is large.' `
                        $size
                    [void]$local.Add($r)
                }
            }
        } catch {}
    }

    $roots = @(
        (Join-Path $env:PUBLIC 'Documents\Hyper-V\Virtual hard disks'),
        (Join-Path $env:ProgramData 'Microsoft\Windows\Virtual Hard Disks')
    )
    foreach ($root in $roots) {
        if (-not (Test-Path -LiteralPath $root)) { continue }
        foreach ($item in @(Get-ChildItem -LiteralPath $root -File -ErrorAction SilentlyContinue | Where-Object { $_.Extension -in @('.vhd','.vhdx') })) {
            $key = $item.FullName.ToLowerInvariant()
            if ($seen.ContainsKey($key)) { continue }
            $seen[$key] = $true
            $status = if ($item.Length -gt 200GB) { 'Large' } elseif ($item.Length -gt 80GB) { 'Review' } else { 'Info' }
            $r = Add-Result 62 'HyperV' $item.FullName $status `
                ("LastWrite={0} | Unassociated/common-location discovery" -f $item.LastWriteTime) `
                'Verify whether the disk belongs to an active, exported or archived virtual machine before any file operation.' `
                ([long]$item.Length)
            [void]$local.Add($r)
        }
    }

    if ($local.Count -eq 0) {
        $r = Add-Result 62 'HyperV' 'Hyper-V virtual disks' 'Not found' 'No Hyper-V VHD/VHDX was found through the available inventory methods.' 'No action required.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Hyper-V virtual disk footprint'
    return $local
}

# ---------------------------------------------------------------------------
# 63. Outlook OST/PST Analyzer
# ---------------------------------------------------------------------------
function Invoke-ScanOutlookDataFiles {
    Write-Title '63. Outlook OST/PST Analyzer'
    $local = New-Object System.Collections.ArrayList

    $roots = @(
        (Join-Path $env:LOCALAPPDATA 'Microsoft\Outlook'),
        (Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'Outlook Files')
    ) | Select-Object -Unique

    $files = @()
    foreach ($root in $roots) {
        if (-not (Test-Path -LiteralPath $root)) { continue }
        $files += @(Get-ChildItem -LiteralPath $root -File -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Extension -in @('.ost','.pst') })
    }

    foreach ($f in @($files | Sort-Object Length -Descending)) {
        $age = [math]::Floor(((Get-Date) - $f.LastWriteTime).TotalDays)
        $status = if ($f.Length -gt 40GB) { 'Large' } elseif ($f.Length -gt 15GB -or $age -gt 365) { 'Review' } else { 'Info' }
        $r = Add-Result 63 'OutlookData' $f.FullName $status `
            ("Type={0} | LastWrite={1} | AgeDays={2}" -f $f.Extension,$f.LastWriteTime,$age) `
            'OST files are usually cache data but should be managed through Outlook/account settings. PST files may contain unique archived mail and must not be deleted blindly.' `
            ([long]$f.Length)
        [void]$local.Add($r)
    }

    if ($local.Count -eq 0) {
        $r = Add-Result 63 'OutlookData' 'Outlook data files' 'Not found' 'No OST/PST file was found in common current-user locations.' 'No action required.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Outlook data files'
    return $local
}

# ---------------------------------------------------------------------------
# 64. Microsoft Teams Cache Analyzer
# ---------------------------------------------------------------------------
function Invoke-ScanTeamsCache {
    Write-Title '64. Microsoft Teams Cache Analyzer'
    $local = New-Object System.Collections.ArrayList

    $paths = @(
        (Join-Path $env:APPDATA 'Microsoft\Teams'),
        (Join-Path $env:LOCALAPPDATA 'Microsoft\Teams'),
        (Join-Path $env:LOCALAPPDATA 'Packages\MSTeams_8wekyb3d8bbwe\LocalCache'),
        (Join-Path $env:LOCALAPPDATA 'Packages\MSTeams_8wekyb3d8bbwe\TempState')
    ) | Select-Object -Unique

    foreach ($path in $paths) {
        if (-not (Test-Path -LiteralPath $path)) { continue }
        $size = Get-FolderSizeWithSpinner -Path $path -Activity 'Measuring Microsoft Teams cache'
        $status = if ($size -gt 5GB) { 'Large' } elseif ($size -gt 1GB) { 'Review' } else { 'Info' }
        $r = Add-Result 64 'TeamsCache' $path $status `
            'Microsoft Teams local data/cache location.' `
            'Sign out/close Teams before supported cache troubleshooting. This module is report-only and does not delete Teams data.' `
            $size
        [void]$local.Add($r)
    }

    if ($local.Count -eq 0) {
        $r = Add-Result 64 'TeamsCache' 'Microsoft Teams cache' 'Not found' 'No common classic/new Teams cache location was found.' 'No action required.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Microsoft Teams cache'
    return $local
}

# ---------------------------------------------------------------------------
# 65. Browser Profile Analyzer
# ---------------------------------------------------------------------------
function Invoke-ScanBrowserProfiles {
    Write-Title '65. Browser Profile Analyzer'
    $local = New-Object System.Collections.ArrayList
    $profiles = New-Object System.Collections.ArrayList

    $chromiumRoots = @(
        @{Browser='Edge';Root=(Join-Path $env:LOCALAPPDATA 'Microsoft\Edge\User Data')},
        @{Browser='Chrome';Root=(Join-Path $env:LOCALAPPDATA 'Google\Chrome\User Data')}
    )

    foreach ($entry in $chromiumRoots) {
        if (-not (Test-Path -LiteralPath $entry.Root)) { continue }
        foreach ($dir in @(Get-ChildItem -LiteralPath $entry.Root -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq 'Default' -or $_.Name -like 'Profile *' })) {
            [void]$profiles.Add([pscustomobject]@{Browser=$entry.Browser;Path=$dir.FullName;LastWrite=$dir.LastWriteTime})
        }
    }

    $ffRoot = Join-Path $env:APPDATA 'Mozilla\Firefox\Profiles'
    if (Test-Path -LiteralPath $ffRoot) {
        foreach ($dir in @(Get-ChildItem -LiteralPath $ffRoot -Directory -ErrorAction SilentlyContinue)) {
            [void]$profiles.Add([pscustomobject]@{Browser='Firefox';Path=$dir.FullName;LastWrite=$dir.LastWriteTime})
        }
    }

    $step = 0
    foreach ($p in $profiles) {
        $step++
        Write-SpinnerFrame -Activity ("Measuring browser profiles ({0}/{1})" -f $step,$profiles.Count) -Step $step
        $size = Get-FolderSizeSafe -Path $p.Path
        $age = [math]::Floor(((Get-Date) - $p.LastWrite).TotalDays)
        $status = if ($age -gt 365) { 'Stale?' } elseif ($size -gt 10GB) { 'Large' } elseif ($age -gt 180 -or $size -gt 5GB) { 'Review' } else { 'Info' }
        $r = Add-Result 65 'BrowserProfile' ("{0}: {1}" -f $p.Browser,$p.Path) $status `
            ("LastWrite={0} | AgeDays={1}" -f $p.LastWrite,$age) `
            'Old-looking profiles may still contain bookmarks, passwords, extensions or active sign-in state. Review in the browser before profile deletion.' `
            $size
        [void]$local.Add($r)
    }
    if ($profiles.Count -gt 0) { Complete-Spinner -Activity ("Measured {0} browser profile(s)" -f $profiles.Count) }

    if ($local.Count -eq 0) {
        $r = Add-Result 65 'BrowserProfile' 'Browser profiles' 'Not found' 'No common Edge, Chrome or Firefox profile directory was found.' 'No action required.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Browser profiles'
    return $local
}

# ---------------------------------------------------------------------------
# 66. Environment Variable Integrity
# ---------------------------------------------------------------------------
function Invoke-ScanEnvironmentVariables {
    Write-Title '66. Environment Variable Integrity'
    $local = New-Object System.Collections.ArrayList

    foreach ($scope in @('Machine','User')) {
        try {
            $vars = [Environment]::GetEnvironmentVariables($scope)
            foreach ($name in @($vars.Keys | Sort-Object)) {
                if ([string]$name -ieq 'Path') { continue }
                $value = [string]$vars[$name]
                if ([string]::IsNullOrWhiteSpace($value)) { continue }

                $parts = if ($value -like '*;*') { @($value -split ';') } else { @($value) }
                $partIndex = 0
                foreach ($raw in $parts) {
                    $partIndex++
                    $candidate = [Environment]::ExpandEnvironmentVariables($raw.Trim().Trim('"'))
                    if ([string]::IsNullOrWhiteSpace($candidate)) { continue }
                    if ($candidate -notmatch '^(?:[A-Za-z]:\\|\\\\)') { continue }
                    if ($candidate -match '[\*\?]') { continue }

                    $exists = Test-Path -LiteralPath $candidate -ErrorAction SilentlyContinue
                    if (-not $exists) {
                        $r = Add-Result 66 'EnvironmentVariable' ("{0}:{1}[{2}]" -f $scope,$name,$partIndex) 'Missing' `
                            ("Value={0} | Expanded={1}" -f $raw,$candidate) `
                            'Environment variables can be required by applications, SDKs and services. Verify ownership before editing them.'
                        [void]$local.Add($r)
                    }
                }
            }
        } catch {
            $r = Add-Result 66 'EnvironmentVariable' ("{0} environment" -f $scope) 'Error' $_.Exception.Message 'Review environment variables manually.'
            [void]$local.Add($r)
        }
    }

    if ($local.Count -eq 0) {
        $r = Add-Result 66 'EnvironmentVariable' 'Path-like environment values' 'Healthy' `
            'No missing absolute path-like value was found outside the PATH variable.' `
            'PATH itself is handled by the dedicated PATH Integrity Analyzer.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Environment variable integrity'
    return $local
}

# ---------------------------------------------------------------------------
# 67. Ghost USB / Storage Device Inventory
# ---------------------------------------------------------------------------
function Invoke-ScanGhostDevices {
    Write-Title '67. Ghost USB / Storage Device Inventory'
    $local = New-Object System.Collections.ArrayList

    if (-not (Test-CommandAvailable 'Get-PnpDevice')) {
        $r = Add-Result 67 'GhostDevice' 'PnP device inventory' 'Unavailable' 'Get-PnpDevice is unavailable.' 'No device was removed.'
        [void]$local.Add($r)
        Show-ResultTable -Data $local -Title 'Ghost USB / storage devices'
        return $local
    }

    try {
        $devices = @(Get-PnpDevice -ErrorAction Stop | Where-Object { $_.InstanceId -match '^(USB|USBSTOR|SCSI|SWD\\WPDBUSENUM)' })
        foreach ($d in $devices) {
            $present = $null
            if ($d.PSObject.Properties.Name -contains 'Present') { $present = [bool]$d.Present }
            $isGhost = if ($null -ne $present) { -not $present } else { ([string]$d.Status -in @('Unknown','Error')) }
            if (-not $isGhost) { continue }

            $name = if ([string]::IsNullOrWhiteSpace([string]$d.FriendlyName)) { [string]$d.InstanceId } else { [string]$d.FriendlyName }
            $r = Add-Result 67 'GhostDevice' $name 'Review' `
                ("Class={0} | Status={1} | Present={2} | InstanceId={3}" -f $d.Class,$d.Status,$present,$d.InstanceId) `
                'A non-present device can be legitimate historical hardware. This tool never removes PnP devices automatically.'
            [void]$local.Add($r)
        }
    } catch {
        $r = Add-Result 67 'GhostDevice' 'PnP device inventory' 'Error' $_.Exception.Message 'Administrator rights may be required for complete device inventory.'
        [void]$local.Add($r)
    }

    if ($local.Count -eq 0) {
        $r = Add-Result 67 'GhostDevice' 'USB / storage history' 'Healthy' 'No likely non-present USB/storage PnP device was found by this scan.' 'No action required.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Ghost USB / storage devices'
    return $local
}

# ---------------------------------------------------------------------------
# 68. Scheduled Task Orphan Actions
# ---------------------------------------------------------------------------
function Invoke-ScanTaskActionOrphans {
    Write-Title '68. Scheduled Task Orphan Actions'
    $local = New-Object System.Collections.ArrayList

    try {
        $tasks = @(Get-ScheduledTask -ErrorAction Stop)
        $step = 0
        foreach ($task in $tasks) {
            $step++
            if (($step % 50) -eq 0) {
                Write-SpinnerFrame -Activity ("Checking scheduled task actions ({0}/{1})" -f $step,$tasks.Count) -Step $step
            }

            foreach ($action in @($task.Actions)) {
                if ([string]::IsNullOrWhiteSpace([string]$action.Execute)) { continue }
                $target = Test-PathTargetFromCommand ([string]$action.Execute)
                if ([string]::IsNullOrWhiteSpace($target)) { continue }
                $exists = Test-ExecutableTargetExists $target
                if ($exists -eq $false) {
                    $r = Add-Result 68 'ScheduledTaskAction' ($task.TaskPath + $task.TaskName) 'Orphan?' `
                        ("Execute={0} | ResolvedTarget={1} | Arguments={2}" -f $action.Execute,$target,$action.Arguments) `
                        'A missing task executable can indicate an uninstalled application or intentionally unavailable resource. Verify before deleting/disabling the task.'
                    [void]$local.Add($r)
                }
            }
        }
        if ($tasks.Count -gt 0) { Complete-Spinner -Activity ("Checked {0} scheduled task(s)" -f $tasks.Count) }
    } catch {
        $r = Add-Result 68 'ScheduledTaskAction' 'Scheduled tasks' 'Error' $_.Exception.Message 'Administrator rights may be required for complete task inventory.'
        [void]$local.Add($r)
    }

    if ($local.Count -eq 0) {
        $r = Add-Result 68 'ScheduledTaskAction' 'Task action targets' 'Healthy' 'No scheduled task executable target was confirmed missing.' 'No action required.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Scheduled task orphan actions'
    return $local
}

# ---------------------------------------------------------------------------
# 69. Orphaned Windows Services
# ---------------------------------------------------------------------------
function Invoke-ScanOrphanServices {
    Write-Title '69. Orphaned Windows Services'
    $local = New-Object System.Collections.ArrayList

    try {
        $services = @(Get-CimInstance Win32_Service -ErrorAction Stop)
        $step = 0
        foreach ($svc in $services) {
            $step++
            if (($step % 50) -eq 0) {
                Write-SpinnerFrame -Activity ("Checking service executable paths ({0}/{1})" -f $step,$services.Count) -Step $step
            }

            $cmd = [string]$svc.PathName
            if ([string]::IsNullOrWhiteSpace($cmd)) { continue }
            if ($cmd -match '^\\SystemRoot\\') {
                $cmd = $env:SystemRoot + $cmd.Substring(11)
            }

            $target = Test-PathTargetFromCommand $cmd
            if ([string]::IsNullOrWhiteSpace($target)) { continue }
            $exists = Test-ExecutableTargetExists $target
            if ($exists -eq $false) {
                $r = Add-Result 69 'ServiceOrphan' $svc.Name 'Orphan?' `
                    ("DisplayName={0} | State={1} | StartMode={2} | PathName={3} | Target={4}" -f `
                        $svc.DisplayName,$svc.State,$svc.StartMode,$svc.PathName,$target) `
                    'Do not delete a service registry key manually. Confirm the software owner and use supported uninstall/service-management procedures.'
                [void]$local.Add($r)
            }
        }
        if ($services.Count -gt 0) { Complete-Spinner -Activity ("Checked {0} Windows service(s)" -f $services.Count) }
    } catch {
        $r = Add-Result 69 'ServiceOrphan' 'Windows services' 'Error' $_.Exception.Message 'Administrator rights may be required.'
        [void]$local.Add($r)
    }

    if ($local.Count -eq 0) {
        $r = Add-Result 69 'ServiceOrphan' 'Service executable paths' 'Healthy' 'No user-mode service executable target was confirmed missing.' 'No action required.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Orphaned Windows services'
    return $local
}

# ---------------------------------------------------------------------------
# 70. Reserved Storage Analyzer
# ---------------------------------------------------------------------------
function Invoke-ScanReservedStorage {
    Write-Title '70. Reserved Storage Analyzer'
    $local = New-Object System.Collections.ArrayList

    if (-not (Test-CommandAvailable 'dism.exe')) {
        $r = Add-Result 70 'ReservedStorage' 'DISM' 'Unavailable' 'dism.exe was not found.' 'No action performed.'
        [void]$local.Add($r)
        Show-ResultTable -Data $local -Title 'Reserved Storage'
        return $local
    }

    try {
        $raw = (& dism.exe /Online /Get-ReservedStorageState /English 2>&1) -join [Environment]::NewLine
        $status = if ($raw -match '(?i)Reserved storage is enabled') { 'Enabled' } elseif ($raw -match '(?i)Reserved storage is disabled') { 'Disabled' } else { 'Info' }
        $r = Add-Result 70 'ReservedStorage' 'Windows Reserved Storage' $status $raw `
            'Reserved Storage supports Windows servicing and updates. This module does not enable or disable it.'
        [void]$local.Add($r)
    } catch {
        $r = Add-Result 70 'ReservedStorage' 'Windows Reserved Storage' 'Error' $_.Exception.Message 'Run as administrator if DISM status cannot be queried.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Reserved Storage'
    return $local
}

# ---------------------------------------------------------------------------
# 71. Provisioned App Inventory
# ---------------------------------------------------------------------------
function Invoke-ScanProvisionedApps {
    Write-Title '71. Provisioned App Inventory'
    $local = New-Object System.Collections.ArrayList

    if (-not (Test-CommandAvailable 'Get-AppxProvisionedPackage')) {
        $r = Add-Result 71 'ProvisionedApp' 'Provisioned Appx packages' 'Unavailable' 'Get-AppxProvisionedPackage is unavailable.' 'No package was changed.'
        [void]$local.Add($r)
        Show-ResultTable -Data $local -Title 'Provisioned App packages'
        return $local
    }

    try {
        $packages = @(Get-AppxProvisionedPackage -Online -ErrorAction Stop | Sort-Object DisplayName)
        foreach ($p in $packages) {
            $r = Add-Result 71 'ProvisionedApp' ([string]$p.DisplayName) 'Provisioned' `
                ("Version={0} | PackageName={1}" -f $p.Version,$p.PackageName) `
                'Provisioned packages can be installed for new user profiles. Removal can affect future users and is not offered automatically.'
            [void]$local.Add($r)
        }
    } catch {
        $r = Add-Result 71 'ProvisionedApp' 'Provisioned Appx packages' 'Error' $_.Exception.Message 'Administrator rights may be required.'
        [void]$local.Add($r)
    }

    if ($local.Count -eq 0) {
        $r = Add-Result 71 'ProvisionedApp' 'Provisioned Appx packages' 'No data' 'No provisioned package was returned.' 'No action required.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Provisioned App packages'
    return $local
}

# ---------------------------------------------------------------------------
# 72. Local Account Hygiene
# ---------------------------------------------------------------------------
function Invoke-ScanLocalAccounts {
    Write-Title '72. Local Account Hygiene'
    $local = New-Object System.Collections.ArrayList

    if (Test-CommandAvailable 'Get-LocalUser') {
        try {
            foreach ($u in @(Get-LocalUser -ErrorAction Stop | Sort-Object Name)) {
                $age = $null
                if ($u.LastLogon) {
                    try { $age = [math]::Floor(((Get-Date) - [datetime]$u.LastLogon).TotalDays) } catch {}
                }

                $status = if (-not $u.Enabled) { 'Disabled' } elseif ($null -ne $age -and $age -ge 180) { 'Stale?' } else { 'Info' }
                $detail = "Enabled=$($u.Enabled) | SID=$($u.SID) | PasswordRequired=$($u.PasswordRequired)"
                if ($u.LastLogon) { $detail += " | LastLogon=$($u.LastLogon) | AgeDays=$age" }
                if ($u.PasswordLastSet) { $detail += " | PasswordLastSet=$($u.PasswordLastSet)" }

                $r = Add-Result 72 'LocalAccount' $u.Name $status $detail `
                    'Built-in, service and recovery accounts may be intentionally disabled or rarely used. Never delete an account without verifying profile/data ownership and recovery access.'
                [void]$local.Add($r)
            }
        } catch {
            $r = Add-Result 72 'LocalAccount' 'Local users' 'Error' $_.Exception.Message 'Administrator rights may be required.'
            [void]$local.Add($r)
        }
    } else {
        try {
            foreach ($u in @(Get-CimInstance Win32_UserAccount -Filter 'LocalAccount=True' -ErrorAction Stop | Sort-Object Name)) {
                $r = Add-Result 72 'LocalAccount' $u.Name $(if($u.Disabled){'Disabled'}else{'Info'}) `
                    ("Disabled={0} | Lockout={1} | SID={2}" -f $u.Disabled,$u.Lockout,$u.SID) `
                    'Fallback inventory does not include reliable last-logon data. No account is changed.'
                [void]$local.Add($r)
            }
        } catch {
            $r = Add-Result 72 'LocalAccount' 'Local users' 'Error' $_.Exception.Message 'Review local accounts manually.'
            [void]$local.Add($r)
        }
    }

    Show-ResultTable -Data $local -Title 'Local account hygiene'
    return $local
}

# ---------------------------------------------------------------------------
# Module dispatcher / scan orchestration
# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# 73. Icon & Thumbnail Database Cache
# ---------------------------------------------------------------------------
function Invoke-ScanIconThumbnailCache {
    Write-Title '73. Icon & Thumbnail Database Cache'
    $local = New-Object System.Collections.ArrayList
    $explorerDir = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Explorer'

    if (-not (Test-Path -LiteralPath $explorerDir)) {
        $r = Add-Result 73 'IconThumbnailCache' $explorerDir 'Not found' `
            'Windows Explorer cache directory was not found.' `
            'No action required.' 0L
        [void]$local.Add($r)
        Show-ResultTable -Data $local -Title 'Icon and thumbnail cache databases'
        return $local
    }

    $sets = @(
        @{Name='Thumbnail databases';Filter='thumbcache_*.db'},
        @{Name='Icon databases';Filter='iconcache_*.db'}
    )

    foreach ($set in $sets) {
        $files = @(Get-ChildItem -LiteralPath $explorerDir -File -Filter $set.Filter -Force -ErrorAction SilentlyContinue)
        $sum = [long](Get-SafePropertySum -InputObject $files -Property 'Length')
        $bytes = if ($null -eq $sum) { 0L } else { [long]$sum }
        $status = if ($bytes -gt 1GB) { 'Large' } elseif ($bytes -gt 300MB) { 'Review' } else { 'Info' }

        $r = Add-Result 73 'IconThumbnailCache' $set.Name $status `
            ("Files={0} | Path={1}" -f $files.Count,$explorerDir) `
            'Report-only. Windows can rebuild these databases; do not remove active Explorer cache databases blindly.' `
            $bytes
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Icon and thumbnail cache databases'
    return $local
}

# ---------------------------------------------------------------------------
# 74. Telemetry & Diagnostic Log Storage
# ---------------------------------------------------------------------------
function Invoke-ScanDiagnosticTelemetryStorage {
    Write-Title '74. Telemetry & Diagnostic Log Storage'
    $local = New-Object System.Collections.ArrayList

    $targets = @(
        @{Name='Microsoft Diagnosis Data';Path=(Join-Path $env:ProgramData 'Microsoft\Diagnosis')},
        @{Name='WMI AutoLogger';Path=(Join-Path $env:WINDIR 'System32\LogFiles\WMI\AutoLogger')},
        @{Name='WMI RtBackup';Path=(Join-Path $env:WINDIR 'System32\LogFiles\WMI\RtBackup')}
    )

    foreach ($target in $targets) {
        if (-not (Test-Path -LiteralPath $target.Path)) { continue }

        $size = Get-FolderSizeWithSpinner -Path $target.Path -Activity ("Measuring {0}" -f $target.Name)
        $status = if ($size -gt 2GB) { 'Large' } elseif ($size -gt 500MB) { 'Review' } else { 'Info' }
        $files = @(Get-ChildItem -LiteralPath $target.Path -File -Recurse -Force -ErrorAction SilentlyContinue)

        $r = Add-Result 74 'DiagnosticTelemetry' $target.Name $status `
            ("Path={0} | Files={1}" -f $target.Path,$files.Count) `
            'Report-only. Diagnostic/ETL data can be active or troubleshooting-relevant; this module does not delete it.' `
            $size
        [void]$local.Add($r)
    }

    if ($local.Count -eq 0) {
        $r = Add-Result 74 'DiagnosticTelemetry' 'Diagnostic log storage' 'No data' `
            'No common diagnostic/telemetry storage location was accessible.' `
            'No action required.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Diagnostic and telemetry storage'
    return $local
}

# ---------------------------------------------------------------------------
# 75. Large Duplicate Files Analyzer
# ---------------------------------------------------------------------------
function Invoke-ScanLargeDuplicateFiles {
    Write-Title '75. Large Duplicate Files Analyzer'
    $local = New-Object System.Collections.ArrayList
    $minSize = 50MB

    $roots = @(
        [Environment]::GetFolderPath('MyDocuments'),
        [Environment]::GetFolderPath('MyVideos'),
        [Environment]::GetFolderPath('MyPictures'),
        (Join-Path $env:USERPROFILE 'Downloads')
    ) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and (Test-Path -LiteralPath $_) } | Select-Object -Unique

    $largeFiles = New-Object System.Collections.ArrayList
    $rootStep = 0
    foreach ($root in $roots) {
        $rootStep++
        Write-SpinnerFrame -Activity ("Finding 50MB+ files: {0}" -f (Split-Path $root -Leaf)) -Step $rootStep
        foreach ($f in @(Get-ChildItem -LiteralPath $root -File -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { $_.Length -ge $minSize })) {
            [void]$largeFiles.Add($f)
        }
    }
    if ($roots.Count -gt 0) { Complete-Spinner -Activity 'Collecting large-file duplicate candidates' }

    $sizeGroups = @($largeFiles | Group-Object Length | Where-Object Count -gt 1)
    $candidateCount = @($sizeGroups | ForEach-Object { $_.Group }).Count
    $hashed = 0

    foreach ($sizeGroup in $sizeGroups) {
        $hashBuckets = @{}
        foreach ($file in $sizeGroup.Group) {
            $hashed++
            if (($hashed % 4) -eq 0 -or $candidateCount -le 10) {
                Write-ScanProgress -Current $hashed -Total ([math]::Max(1,$candidateCount)) `
                    -Activity ("Hashing: {0}" -f $file.Name) -Transient
            }

            try {
                $hash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256 -ErrorAction Stop).Hash
                if (-not $hashBuckets.ContainsKey($hash)) {
                    $hashBuckets[$hash] = New-Object System.Collections.ArrayList
                }
                $hashBuckets[$hash].Add($file)
            } catch {
                Write-Log ("Duplicate hash failed: {0} | {1}" -f $file.FullName,$_.Exception.Message) 'WARN'
            }
        }

        foreach ($entry in $hashBuckets.GetEnumerator()) {
            if ($entry.Value.Count -lt 2) { continue }
            $index = 0
            foreach ($file in $entry.Value) {
                $index++
                $status = if ($index -eq 1) { 'Reference' } else { 'Duplicate' }
                $recommendation = if ($index -eq 1) {
                    'Reference member of a content-identical duplicate set.'
                } else {
                    'Content-identical duplicate candidate. Compare location/purpose before manual deletion.'
                }

                $r = Add-Result 75 'DuplicateFile' $file.FullName $status `
                    ("SHA256={0}... | SetMembers={1}" -f $entry.Key.Substring(0,12),$entry.Value.Count) `
                    $recommendation `
                    ([long]$file.Length)
                [void]$local.Add($r)
            }
        }
    }

    if ($candidateCount -gt 0) {
        Write-ScanProgress -Current $candidateCount -Total $candidateCount -Activity 'Duplicate hashing complete'
    }

    if ($local.Count -eq 0) {
        $r = Add-Result 75 'DuplicateFile' 'Documents / Pictures / Videos / Downloads' 'Healthy' `
            ("No SHA256-confirmed duplicate set was found among files >= {0}." -f (Format-Bytes $minSize)) `
            'No action required.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'SHA256-confirmed large duplicate files'
    Write-Host 'Report-only: duplicate files are never automatically deleted.' -ForegroundColor Yellow
    return $local
}

# ---------------------------------------------------------------------------
# 76. Network Adapter Hygiene
# ---------------------------------------------------------------------------
function Invoke-ScanNetworkAdapterHygiene {
    Write-Title '76. Network Adapter Hygiene'
    $local = New-Object System.Collections.ArrayList

    if (-not (Test-CommandAvailable 'Get-NetAdapter')) {
        $r = Add-Result 76 'NetworkHygiene' 'Get-NetAdapter' 'Unavailable' `
            'Get-NetAdapter is not available in this PowerShell environment.' `
            'No adapter configuration was changed.'
        [void]$local.Add($r)
        Show-ResultTable -Data $local
        return $local
    }

    try {
        $adapters = @(Get-NetAdapter -IncludeHidden -ErrorAction Stop | Sort-Object Name)
        foreach ($a in $adapters) {
            $desc = [string]$a.InterfaceDescription
            $isVirtual = ($desc -match '(?i)virtual|hyper-v|vpn|tap|tun|wireguard|wsl|vmware|virtualbox')
            $inactive = ($a.Status -ne 'Up')

            if (-not $inactive -and -not $isVirtual) { continue }

            $status = if ($inactive -and $isVirtual) { 'Inactive virtual' } elseif ($inactive) { 'Inactive' } else { 'Virtual active' }
            $r = Add-Result 76 'NetworkHygiene' $a.Name $status `
                ("Status={0} | Description={1} | MAC={2} | IfIndex={3}" -f $a.Status,$a.InterfaceDescription,$a.MacAddress,$a.ifIndex) `
                'VPN, WSL, Hyper-V and virtualization software commonly create valid virtual adapters. Verify ownership before removal.'
            [void]$local.Add($r)
        }
    } catch {
        $r = Add-Result 76 'NetworkHygiene' 'Network adapter hygiene' 'Error' $_.Exception.Message `
            'Review Network Connections and Device Manager manually.'
        [void]$local.Add($r)
    }

    if ($local.Count -eq 0) {
        $r = Add-Result 76 'NetworkHygiene' 'Network adapters' 'Healthy' `
            'No inactive or recognizable virtual adapter required review.' `
            'No action required.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Inactive / virtual adapter review'
    return $local
}


# ---------------------------------------------------------------------------
# 77. Secure Boot Status
# ---------------------------------------------------------------------------
function Invoke-ScanSecureBoot {
    Write-Title '77. Secure Boot Status'
    $local = New-Object System.Collections.ArrayList

    if (-not (Test-CommandAvailable 'Confirm-SecureBootUEFI')) {
        $r = Add-Result 77 'SecureBoot' 'Secure Boot' 'Unavailable' `
            'Confirm-SecureBootUEFI is not available in this environment.' `
            'Secure Boot requires UEFI firmware and supported Windows hardware.'
        [void]$local.Add($r)
        Show-ResultTable -Data $local -Title 'Secure Boot status'
        return $local
    }

    try {
        $enabled = Confirm-SecureBootUEFI -ErrorAction Stop
        $status = if ($enabled) { 'Healthy' } else { 'Review' }
        $r = Add-Result 77 'SecureBoot' 'Secure Boot' $status `
            ("Enabled={0}" -f $enabled) `
            'Secure Boot helps protect the boot chain. Review firmware/compatibility requirements before changing it.'
        [void]$local.Add($r)
    } catch {
        $message = $_.Exception.Message
        $status = if ($message -match '(?i)not supported|unsupported') { 'Unavailable' } else { 'Error' }
        $r = Add-Result 77 'SecureBoot' 'Secure Boot' $status $message `
            'Run as administrator on a UEFI system to query Secure Boot.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Secure Boot status'
    return $local
}

# ---------------------------------------------------------------------------
# 78. TPM 2.0 Status
# ---------------------------------------------------------------------------
function Invoke-ScanTpm {
    Write-Title '78. TPM 2.0 Status'
    $local = New-Object System.Collections.ArrayList

    if (-not (Test-CommandAvailable 'Get-Tpm')) {
        $r = Add-Result 78 'TPM' 'Trusted Platform Module' 'Unavailable' `
            'Get-Tpm is not available in this environment.' `
            'TPM status can also be reviewed with tpm.msc or Windows Security.'
        [void]$local.Add($r)
        Show-ResultTable -Data $local -Title 'TPM status'
        return $local
    }

    try {
        $tpm = Get-Tpm -ErrorAction Stop
        $present = [bool]$tpm.TpmPresent
        $ready = [bool]$tpm.TpmReady
        $enabled = [bool]$tpm.TpmEnabled
        $activated = [bool]$tpm.TpmActivated
        $spec = ''
        try { $spec = [string]$tpm.ManufacturerVersionFull20 } catch {}
        if ([string]::IsNullOrWhiteSpace($spec)) {
            try { $spec = [string]$tpm.ManufacturerVersion } catch {}
        }

        $status = if ($present -and $ready -and $enabled) { 'Healthy' } elseif ($present) { 'Review' } else { 'Warning' }
        $r = Add-Result 78 'TPM' 'Trusted Platform Module' $status `
            ("Present={0} | Ready={1} | Enabled={2} | Activated={3} | ManufacturerId={4} | Version={5}" -f `
                $present,$ready,$enabled,$activated,$tpm.ManufacturerIdTxt,$spec) `
            'Windows 11 security features commonly rely on TPM 2.0. This module never clears or initializes the TPM.'
        [void]$local.Add($r)
    } catch {
        $r = Add-Result 78 'TPM' 'Trusted Platform Module' 'Error' $_.Exception.Message `
            'Do not clear the TPM as a troubleshooting step without recovery-key and data-protection planning.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'TPM status'
    return $local
}

# ---------------------------------------------------------------------------
# 79. Virtualization-Based Security (VBS)
# ---------------------------------------------------------------------------
function Invoke-ScanVbs {
    Write-Title '79. Virtualization-Based Security (VBS)'
    $local = New-Object System.Collections.ArrayList

    try {
        $dg = Get-CimInstance -Namespace 'root\Microsoft\Windows\DeviceGuard' `
            -ClassName 'Win32_DeviceGuard' -ErrorAction Stop

        $state = switch ([int]$dg.VirtualizationBasedSecurityStatus) {
            0 { 'Not enabled' }
            1 { 'Enabled but not running' }
            2 { 'Running' }
            default { "Unknown ($($dg.VirtualizationBasedSecurityStatus))" }
        }

        $status = if ([int]$dg.VirtualizationBasedSecurityStatus -eq 2) { 'Healthy' } else { 'Review' }
        $r = Add-Result 79 'VBS' 'Virtualization-Based Security' $status `
            ("State={0} | ServicesConfigured={1} | ServicesRunning={2} | RequiredProps={3} | AvailableProps={4}" -f `
                $state,($dg.SecurityServicesConfigured -join ','),($dg.SecurityServicesRunning -join ','),`
                ($dg.RequiredSecurityProperties -join ','),($dg.AvailableSecurityProperties -join ',')) `
            'VBS availability and configuration depend on hardware, edition, policy and application compatibility.'
        [void]$local.Add($r)
    } catch {
        $r = Add-Result 79 'VBS' 'Virtualization-Based Security' 'Error' $_.Exception.Message `
            'The DeviceGuard CIM provider may be unavailable on unsupported systems.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Virtualization-Based Security'
    return $local
}

# ---------------------------------------------------------------------------
# 80. Memory Integrity / HVCI
# ---------------------------------------------------------------------------
function Invoke-ScanMemoryIntegrity {
    Write-Title '80. Memory Integrity / HVCI'
    $local = New-Object System.Collections.ArrayList

    $path = 'HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity'
    $configured = $null

    if (Test-Path -LiteralPath $path) {
        try {
            $p = Get-ItemProperty -LiteralPath $path -ErrorAction Stop
            if ($p.PSObject.Properties.Name -contains 'Enabled') {
                $configured = ([int]$p.Enabled -ne 0)
            }
        } catch {}
    }

    $running = $null
    try {
        $dg = Get-CimInstance -Namespace 'root\Microsoft\Windows\DeviceGuard' `
            -ClassName 'Win32_DeviceGuard' -ErrorAction Stop
        $running = (@($dg.SecurityServicesRunning) -contains 2)
    } catch {}

    $status = if ($running -eq $true) {
        'Healthy'
    } elseif ($configured -eq $true) {
        'Review'
    } elseif ($configured -eq $false) {
        'Review'
    } else {
        'Info'
    }

    $r = Add-Result 80 'MemoryIntegrity' 'Memory Integrity (HVCI)' $status `
        ("Configured={0} | Running={1} | RegistryPath={2}" -f $configured,$running,$path) `
        'Memory Integrity can improve kernel protection but may be affected by incompatible drivers. This module does not change it.'
    [void]$local.Add($r)

    Show-ResultTable -Data $local -Title 'Memory Integrity / HVCI'
    return $local
}

# ---------------------------------------------------------------------------
# 81. Credential Guard
# ---------------------------------------------------------------------------
function Invoke-ScanCredentialGuard {
    Write-Title '81. Credential Guard'
    $local = New-Object System.Collections.ArrayList

    try {
        $dg = Get-CimInstance -Namespace 'root\Microsoft\Windows\DeviceGuard' `
            -ClassName 'Win32_DeviceGuard' -ErrorAction Stop
        $configured = (@($dg.SecurityServicesConfigured) -contains 1)
        $running = (@($dg.SecurityServicesRunning) -contains 1)

        $status = if ($running) { 'Healthy' } elseif ($configured) { 'Review' } else { 'Info' }
        $r = Add-Result 81 'CredentialGuard' 'Windows Defender Credential Guard' $status `
            ("Configured={0} | Running={1}" -f $configured,$running) `
            'Credential Guard support depends on Windows edition, hardware and organizational policy.'
        [void]$local.Add($r)
    } catch {
        $r = Add-Result 81 'CredentialGuard' 'Windows Defender Credential Guard' 'Error' $_.Exception.Message `
            'The DeviceGuard CIM provider may be unavailable on this system.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Credential Guard'
    return $local
}

# ---------------------------------------------------------------------------
# 82. LSA Protection
# ---------------------------------------------------------------------------
function Invoke-ScanLsaProtection {
    Write-Title '82. LSA Protection'
    $local = New-Object System.Collections.ArrayList
    $path = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'

    try {
        $p = Get-ItemProperty -LiteralPath $path -ErrorAction Stop
        $runAsPpl = if ($p.PSObject.Properties.Name -contains 'RunAsPPL') { $p.RunAsPPL } else { $null }
        $runAsPplBoot = if ($p.PSObject.Properties.Name -contains 'RunAsPPLBoot') { $p.RunAsPPLBoot } else { $null }

        $status = if ($runAsPpl -in @(1,2)) { 'Healthy' } elseif ($null -eq $runAsPpl) { 'Info' } else { 'Review' }
        $r = Add-Result 82 'LSAProtection' 'LSA protection / RunAsPPL' $status `
            ("RunAsPPL={0} | RunAsPPLBoot={1}" -f $runAsPpl,$runAsPplBoot) `
            'LSA protection configuration may be managed by Windows defaults or organizational policy. This module is report-only.'
        [void]$local.Add($r)
    } catch {
        $r = Add-Result 82 'LSAProtection' 'LSA protection / RunAsPPL' 'Error' $_.Exception.Message `
            'Review Windows Security and policy settings manually.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'LSA Protection'
    return $local
}

# ---------------------------------------------------------------------------
# 83. Microsoft Defender SmartScreen
# ---------------------------------------------------------------------------
function Invoke-ScanSmartScreen {
    Write-Title '83. Microsoft Defender SmartScreen'
    $local = New-Object System.Collections.ArrayList

    $checks = @(
        @{Name='Explorer SmartScreen';Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer';Value='SmartScreenEnabled'},
        @{Name='Policy SmartScreen';Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\System';Value='EnableSmartScreen'},
        @{Name='User AppHost Web Evaluation';Path='HKCU:\Software\Microsoft\Windows\CurrentVersion\AppHost';Value='EnableWebContentEvaluation'}
    )

    foreach ($check in $checks) {
        $value = $null
        if (Test-Path -LiteralPath $check.Path) {
            try {
                $p = Get-ItemProperty -LiteralPath $check.Path -ErrorAction Stop
                if ($p.PSObject.Properties.Name -contains $check.Value) {
                    $value = $p.PSObject.Properties[$check.Value].Value
                }
            } catch {}
        }

        $status = if ($null -eq $value) { 'Default/Not set' } elseif ([string]$value -match '^(?i:off|0|false)$') { 'Review' } else { 'Info' }
        $r = Add-Result 83 'SmartScreen' $check.Name $status `
            ("Value={0} | Registry={1}\{2}" -f $value,$check.Path,$check.Value) `
            'SmartScreen behavior can be controlled by Windows Security, browser settings and organizational policy.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'SmartScreen configuration'
    return $local
}

# ---------------------------------------------------------------------------
# 84. Attack Surface Reduction (ASR) Rules
# ---------------------------------------------------------------------------
function Invoke-ScanAsrRules {
    Write-Title '84. Attack Surface Reduction (ASR) Rules'
    $local = New-Object System.Collections.ArrayList

    if (-not (Test-CommandAvailable 'Get-MpPreference')) {
        $r = Add-Result 84 'ASR' 'Attack Surface Reduction rules' 'Unavailable' `
            'Get-MpPreference is unavailable.' `
            'Microsoft Defender may be disabled, unavailable or managed by another security product.'
        [void]$local.Add($r)
        Show-ResultTable -Data $local -Title 'ASR rules'
        return $local
    }

    try {
        $pref = Get-MpPreference -ErrorAction Stop
        $ids = @($pref.AttackSurfaceReductionRules_Ids)
        $actions = @($pref.AttackSurfaceReductionRules_Actions)

        if ($ids.Count -eq 0) {
            $r = Add-Result 84 'ASR' 'Attack Surface Reduction rules' 'Info' `
                'No explicit ASR rule configuration was returned.' `
                'ASR configuration may be absent, inherited, or managed through policy.'
            [void]$local.Add($r)
        } else {
            for ($i=0; $i -lt $ids.Count; $i++) {
                $action = if ($i -lt $actions.Count) { [int]$actions[$i] } else { -1 }
                $actionText = switch ($action) {
                    0 { 'Disabled' }
                    1 { 'Block' }
                    2 { 'Audit' }
                    6 { 'Warn' }
                    default { "Value $action" }
                }
                $status = if ($action -eq 0) { 'Review' } else { 'Info' }
                $r = Add-Result 84 'ASR' ([string]$ids[$i]) $status `
                    ("Action={0}" -f $actionText) `
                    'ASR rules should be evaluated against workload compatibility and organizational security policy.'
                [void]$local.Add($r)
            }
        }
    } catch {
        $r = Add-Result 84 'ASR' 'Attack Surface Reduction rules' 'Error' $_.Exception.Message `
            'Administrator rights or Defender availability may be required.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Attack Surface Reduction rules'
    return $local
}

# ---------------------------------------------------------------------------
# 85. Controlled Folder Access
# ---------------------------------------------------------------------------
function Invoke-ScanControlledFolderAccess {
    Write-Title '85. Controlled Folder Access'
    $local = New-Object System.Collections.ArrayList

    if (-not (Test-CommandAvailable 'Get-MpPreference')) {
        $r = Add-Result 85 'ControlledFolderAccess' 'Controlled Folder Access' 'Unavailable' `
            'Get-MpPreference is unavailable.' `
            'Microsoft Defender may be disabled or managed by another product.'
        [void]$local.Add($r)
        Show-ResultTable -Data $local -Title 'Controlled Folder Access'
        return $local
    }

    try {
        $pref = Get-MpPreference -ErrorAction Stop
        $mode = [int]$pref.EnableControlledFolderAccess
        $modeText = switch ($mode) {
            0 { 'Disabled' }
            1 { 'Enabled' }
            2 { 'Audit mode' }
            6 { 'Warn mode' }
            default { "Value $mode" }
        }
        $status = if ($mode -eq 1) { 'Healthy' } elseif ($mode -eq 0) { 'Info' } else { 'Review' }

        $r = Add-Result 85 'ControlledFolderAccess' 'Controlled Folder Access' $status `
            ("Mode={0} | ProtectedFolders={1} | AllowedApps={2}" -f `
                $modeText,@($pref.ControlledFolderAccessProtectedFolders).Count,@($pref.ControlledFolderAccessAllowedApplications).Count) `
            'Controlled Folder Access can block legitimate applications; enablement should be tested and policy-driven.'
        [void]$local.Add($r)
    } catch {
        $r = Add-Result 85 'ControlledFolderAccess' 'Controlled Folder Access' 'Error' $_.Exception.Message `
            'Administrator rights or Defender availability may be required.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Controlled Folder Access'
    return $local
}

# ---------------------------------------------------------------------------
# 86. Remote Desktop / NLA
# ---------------------------------------------------------------------------
function Invoke-ScanRemoteDesktop {
    Write-Title '86. Remote Desktop / NLA'
    $local = New-Object System.Collections.ArrayList

    $tsPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server'
    $rdpPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp'

    try {
        $ts = Get-ItemProperty -LiteralPath $tsPath -ErrorAction Stop
        $denyValue = Get-SafePropertyValue -InputObject $ts -Name 'fDenyTSConnections'
        if($null -eq $denyValue) {
            throw 'Remote Desktop fDenyTSConnections registry value is not available.'
        }
        $rdpEnabled = ([int]$denyValue -eq 0)

        $nla = $null
        if (Test-Path -LiteralPath $rdpPath) {
            $p = Get-ItemProperty -LiteralPath $rdpPath -ErrorAction SilentlyContinue
            if ($p -and $p.PSObject.Properties.Name -contains 'UserAuthentication') {
                $nla = ([int]$p.UserAuthentication -ne 0)
            }
        }

        $status = if (-not $rdpEnabled) { 'Healthy' } elseif ($nla -eq $true) { 'Review' } else { 'Warning' }
        $r = Add-Result 86 'RemoteDesktop' 'Remote Desktop' $status `
            ("Enabled={0} | NetworkLevelAuthentication={1}" -f $rdpEnabled,$nla) `
            'Remote Desktop can be legitimate. If enabled, restrict network exposure and prefer NLA plus strong authentication.'
        [void]$local.Add($r)
    } catch {
        $r = Add-Result 86 'RemoteDesktop' 'Remote Desktop' 'Error' $_.Exception.Message `
            'Review Settings > System > Remote Desktop manually.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Remote Desktop / NLA'
    return $local
}

# ---------------------------------------------------------------------------
# 87. WinRM / PowerShell Remoting
# ---------------------------------------------------------------------------
function Invoke-ScanWinRm {
    Write-Title '87. WinRM / PowerShell Remoting'
    $local = New-Object System.Collections.ArrayList

    try {
        $svc = Get-Service -Name WinRM -ErrorAction Stop
        $status = if ($svc.Status -eq 'Running') { 'Review' } else { 'Info' }
        $r = Add-Result 87 'WinRM' 'Windows Remote Management service' $status `
            ("Status={0} | StartType={1}" -f $svc.Status,$svc.StartType) `
            'Running WinRM may be required for administration. Verify firewall scope, listeners and authentication settings.'
        [void]$local.Add($r)
    } catch {
        $r = Add-Result 87 'WinRM' 'Windows Remote Management service' 'Error' $_.Exception.Message `
            'WinRM service status could not be queried.'
        [void]$local.Add($r)
    }

    if (Test-CommandAvailable 'winrm.cmd') {
        try {
            $raw = (& winrm.cmd enumerate winrm/config/listener 2>&1) -join [Environment]::NewLine
            $hasListener = ($raw -match '(?i)Listener')
            $r = Add-Result 87 'WinRM' 'WinRM listeners' $(if($hasListener){'Review'}else{'Info'}) `
                $raw `
                'Listener configuration should be reviewed when remote administration is not expected.'
            [void]$local.Add($r)
        } catch {}
    }

    Show-ResultTable -Data $local -Title 'WinRM / PowerShell Remoting'
    return $local
}

# ---------------------------------------------------------------------------
# 88. SMB1 and SMB Signing
# ---------------------------------------------------------------------------
function Invoke-ScanSmbSecurity {
    Write-Title '88. SMB1 and SMB Signing'
    $local = New-Object System.Collections.ArrayList

    if (Test-CommandAvailable 'Get-WindowsOptionalFeature') {
        try {
            $smb1 = Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -ErrorAction Stop
            $status = if ($smb1.State -eq 'Enabled') { 'Warning' } else { 'Healthy' }
            $r = Add-Result 88 'SMBSecurity' 'SMB1 Protocol' $status `
                ("State={0}" -f $smb1.State) `
                'SMB1 is legacy. Do not disable it blindly if a confirmed legacy dependency still exists.'
            [void]$local.Add($r)
        } catch {
            $r = Add-Result 88 'SMBSecurity' 'SMB1 Protocol' 'Error' $_.Exception.Message `
                'Administrator rights may be required.'
            [void]$local.Add($r)
        }
    }

    if (Test-CommandAvailable 'Get-SmbServerConfiguration') {
        try {
            $server = Get-SmbServerConfiguration -ErrorAction Stop
            $r = Add-Result 88 'SMBSecurity' 'SMB server signing' $(if($server.RequireSecuritySignature){'Healthy'}else{'Review'}) `
                ("EnableSecuritySignature={0} | RequireSecuritySignature={1} | EnableSMB1Protocol={2} | EnableSMB2Protocol={3}" -f `
                    $server.EnableSecuritySignature,$server.RequireSecuritySignature,$server.EnableSMB1Protocol,$server.EnableSMB2Protocol) `
                'SMB signing requirements should follow your network threat model and organizational policy.'
            [void]$local.Add($r)
        } catch {}
    }

    if (Test-CommandAvailable 'Get-SmbClientConfiguration') {
        try {
            $client = Get-SmbClientConfiguration -ErrorAction Stop
            $r = Add-Result 88 'SMBSecurity' 'SMB client signing' $(if($client.RequireSecuritySignature){'Healthy'}else{'Review'}) `
                ("EnableSecuritySignature={0} | RequireSecuritySignature={1} | EnableInsecureGuestLogons={2}" -f `
                    $client.EnableSecuritySignature,$client.RequireSecuritySignature,$client.EnableInsecureGuestLogons) `
                'Insecure guest access and unsigned SMB can increase network risk.'
            [void]$local.Add($r)
        } catch {}
    }

    if ($local.Count -eq 0) {
        $r = Add-Result 88 'SMBSecurity' 'SMB security configuration' 'No data' `
            'SMB configuration cmdlets did not return data.' `
            'No configuration was changed.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'SMB1 and SMB signing'
    return $local
}

# ---------------------------------------------------------------------------
# 89. DISM Component Health
# ---------------------------------------------------------------------------
function Invoke-ScanDismHealth {
    Write-Title '89. DISM Component Health'
    $local = New-Object System.Collections.ArrayList

    if (-not (Test-CommandAvailable 'dism.exe')) {
        $r = Add-Result 89 'DISMHealth' 'DISM Component Health' 'Unavailable' 'dism.exe was not found.' 'No action performed.'
        [void]$local.Add($r)
        Show-ResultTable -Data $local -Title 'DISM component health'
        return $local
    }

    try {
        $raw = @(
            Invoke-JobWithSpinner -Activity 'Running DISM CheckHealth' -ScriptBlock {
                & dism.exe /Online /Cleanup-Image /CheckHealth /English 2>&1
            }
        ) -join [Environment]::NewLine

        $status = if ($raw -match '(?i)No component store corruption detected') {
            'Healthy'
        } elseif ($raw -match '(?i)repairable') {
            'Warning'
        } elseif ($raw -match '(?i)corruption') {
            'Review'
        } else {
            'Info'
        }

        $r = Add-Result 89 'DISMHealth' 'DISM /CheckHealth' $status $raw `
            'This module performs CheckHealth only. It does not run RestoreHealth or modify the component store.'
        [void]$local.Add($r)
    } catch {
        $r = Add-Result 89 'DISMHealth' 'DISM /CheckHealth' 'Error' $_.Exception.Message `
            'Run as administrator and retry if DISM cannot query component health.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'DISM component health'
    return $local
}

# ---------------------------------------------------------------------------
# 90. SFC VerifyOnly
# ---------------------------------------------------------------------------
function Invoke-ScanSfcVerifyOnly {
    Write-Title '90. SFC VerifyOnly'
    $local = New-Object System.Collections.ArrayList

    if (-not (Test-CommandAvailable 'sfc.exe')) {
        $r = Add-Result 90 'SFC' 'System File Checker' 'Unavailable' 'sfc.exe was not found.' 'No action performed.'
        [void]$local.Add($r)
        Show-ResultTable -Data $local -Title 'System File Checker'
        return $local
    }

    try {
        $raw = @(
            Invoke-JobWithSpinner -Activity 'Running SFC verify-only scan' -ScriptBlock {
                & sfc.exe /verifyonly 2>&1
            }
        ) -join [Environment]::NewLine

        $status = if ($raw -match '(?i)did not find any integrity violations') {
            'Healthy'
        } elseif ($raw -match '(?i)integrity violations|corrupt') {
            'Warning'
        } elseif ($raw -match '(?i)administrator') {
            'Error'
        } else {
            'Info'
        }

        $r = Add-Result 90 'SFC' 'sfc /verifyonly' $status $raw `
            'VerifyOnly checks protected system files without repairing them. Repair is intentionally not automatic.'
        [void]$local.Add($r)
    } catch {
        $r = Add-Result 90 'SFC' 'sfc /verifyonly' 'Error' $_.Exception.Message `
            'Run PowerShell as administrator for a complete verification.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'System File Checker verify-only'
    return $local
}

# ---------------------------------------------------------------------------
# 91. Windows Update History
# ---------------------------------------------------------------------------
function Invoke-ScanWindowsUpdateHistory {
    Write-Title '91. Windows Update History'
    $local = New-Object System.Collections.ArrayList

    try {
        $session = New-Object -ComObject 'Microsoft.Update.Session'
        $searcher = $session.CreateUpdateSearcher()
        $count = [math]::Min(50,$searcher.GetTotalHistoryCount())
        $history = @($searcher.QueryHistory(0,$count))

        foreach ($h in $history) {
            $resultText = switch ([int]$h.ResultCode) {
                0 { 'Not Started' }
                1 { 'In Progress' }
                2 { 'Succeeded' }
                3 { 'Succeeded With Errors' }
                4 { 'Failed' }
                5 { 'Aborted' }
                default { "Code $($h.ResultCode)" }
            }

            $status = switch ([int]$h.ResultCode) {
                2 { 'Healthy' }
                3 { 'Review' }
                4 { 'Warning' }
                5 { 'Review' }
                default { 'Info' }
            }

            $r = Add-Result 91 'WindowsUpdateHistory' ([string]$h.Title) $status `
                ("Date={0} | Result={1} | Operation={2} | HResult={3}" -f `
                    $h.Date,$resultText,$h.Operation,$h.HResult) `
                'Repeated failures for the same update deserve Windows Update troubleshooting and servicing-log review.'
            [void]$local.Add($r)
        }

        if ($history.Count -eq 0) {
            $r = Add-Result 91 'WindowsUpdateHistory' 'Windows Update history' 'No data' `
                'No Windows Update history record was returned.' `
                'No action required based on this module.'
            [void]$local.Add($r)
        }
    } catch {
        $r = Add-Result 91 'WindowsUpdateHistory' 'Windows Update history' 'Error' $_.Exception.Message `
            'Windows Update COM history could not be queried.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Recent Windows Update history'
    return $local
}

# ---------------------------------------------------------------------------
# 92. Windows Recovery Environment (WinRE)
# ---------------------------------------------------------------------------
function Invoke-ScanWinRe {
    Write-Title '92. Windows Recovery Environment (WinRE)'
    $local = New-Object System.Collections.ArrayList

    if (-not (Test-CommandAvailable 'reagentc.exe')) {
        $r = Add-Result 92 'WinRE' 'Windows Recovery Environment' 'Unavailable' 'reagentc.exe was not found.' 'No action performed.'
        [void]$local.Add($r)
        Show-ResultTable -Data $local -Title 'Windows Recovery Environment'
        return $local
    }

    try {
        $raw = (& reagentc.exe /info 2>&1) -join [Environment]::NewLine
        $enabled = ($raw -match '(?i)Windows RE status:\s*Enabled')
        $disabled = ($raw -match '(?i)Windows RE status:\s*Disabled')
        $status = if ($enabled) { 'Healthy' } elseif ($disabled) { 'Review' } else { 'Info' }

        $r = Add-Result 92 'WinRE' 'Windows Recovery Environment' $status $raw `
            'WinRE is used for recovery and advanced startup. This module does not enable, disable or relocate it.'
        [void]$local.Add($r)
    } catch {
        $r = Add-Result 92 'WinRE' 'Windows Recovery Environment' 'Error' $_.Exception.Message `
            'Administrator rights may be required.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Windows Recovery Environment'
    return $local
}

# ---------------------------------------------------------------------------
# 93. BCD Configuration Analyzer
# ---------------------------------------------------------------------------
function Invoke-ScanBcd {
    Write-Title '93. BCD Configuration Analyzer'
    $local = New-Object System.Collections.ArrayList

    if (-not (Test-CommandAvailable 'bcdedit.exe')) {
        $r = Add-Result 93 'BCD' 'Boot Configuration Data' 'Unavailable' 'bcdedit.exe was not found.' 'No action performed.'
        [void]$local.Add($r)
        Show-ResultTable -Data $local -Title 'Boot Configuration Data'
        return $local
    }

    try {
        $current = (& bcdedit.exe /enum '{current}' 2>&1) -join [Environment]::NewLine
        $bootmgr = (& bcdedit.exe /enum '{bootmgr}' 2>&1) -join [Environment]::NewLine
        $raw = $current + [Environment]::NewLine + [Environment]::NewLine + $bootmgr

        $status = if ($raw -match '(?i)The boot configuration data store could not be opened|access is denied') { 'Error' } else { 'Info' }
        $r = Add-Result 93 'BCD' 'Current loader and boot manager' $status $raw `
            'BCD settings are shown for review only. This tool never modifies boot entries, recovery flags or timeout values.'
        [void]$local.Add($r)
    } catch {
        $r = Add-Result 93 'BCD' 'Boot Configuration Data' 'Error' $_.Exception.Message `
            'Run as administrator if BCD cannot be read.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Boot Configuration Data'
    return $local
}

# ---------------------------------------------------------------------------
# 94. Boot Performance Analyzer
# ---------------------------------------------------------------------------
function Invoke-ScanBootPerformance {
    Write-Title '94. Boot Performance Analyzer'
    $local = New-Object System.Collections.ArrayList
    $log = 'Microsoft-Windows-Diagnostics-Performance/Operational'

    try {
        $events = @(Get-WinEvent -FilterHashtable @{LogName=$log;Id=100} -MaxEvents 10 -ErrorAction Stop)
        foreach ($event in $events) {
            $data = @{}
            try {
                [xml]$xml = $event.ToXml()
                foreach ($node in @($xml.Event.EventData.Data)) {
                    $name = [string]$node.Name
                    if (-not [string]::IsNullOrWhiteSpace($name)) {
                        $data[$name] = [string]$node.'#text'
                    }
                }
            } catch {}

            $bootMs = $null
            if ($data.ContainsKey('BootTime')) {
                try { $bootMs = [long]$data['BootTime'] } catch {}
            }

            $status = if ($null -ne $bootMs -and $bootMs -gt 120000) {
                'Warning'
            } elseif ($null -ne $bootMs -and $bootMs -gt 60000) {
                'Review'
            } else {
                'Info'
            }

            $detail = "TimeCreated=$($event.TimeCreated)"
            if ($null -ne $bootMs) { $detail += " | BootTimeMs=$bootMs | BootTimeSeconds=$([math]::Round($bootMs/1000,1))" }
            if ($data.ContainsKey('MainPathBootTime')) { $detail += " | MainPathMs=$($data['MainPathBootTime'])" }
            if ($data.ContainsKey('BootPostBootTime')) { $detail += " | PostBootMs=$($data['BootPostBootTime'])" }

            $r = Add-Result 94 'BootPerformance' ("Boot event {0}" -f $event.RecordId) $status $detail `
                'Boot duration is workload-dependent. Use repeated slow boots plus startup/task/service findings to identify causes.'
            [void]$local.Add($r)
        }

        if ($events.Count -eq 0) {
            $r = Add-Result 94 'BootPerformance' 'Boot performance events' 'No data' `
                'No Event ID 100 boot-performance record was returned.' `
                'The Diagnostics-Performance log may be disabled or empty.'
            [void]$local.Add($r)
        }
    } catch {
        $r = Add-Result 94 'BootPerformance' 'Boot performance events' 'Error' $_.Exception.Message `
            'The Diagnostics-Performance Operational log could not be read.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Recent boot performance'
    return $local
}

# ---------------------------------------------------------------------------
# 95. TRIM / Delete Notification Status
# ---------------------------------------------------------------------------
function Invoke-ScanTrim {
    Write-Title '95. TRIM / Delete Notification Status'
    $local = New-Object System.Collections.ArrayList

    if (-not (Test-CommandAvailable 'fsutil.exe')) {
        $r = Add-Result 95 'TRIM' 'TRIM / DeleteNotify' 'Unavailable' 'fsutil.exe was not found.' 'No action performed.'
        [void]$local.Add($r)
        Show-ResultTable -Data $local -Title 'TRIM status'
        return $local
    }

    try {
        $raw = (& fsutil.exe behavior query DisableDeleteNotify 2>&1) -join [Environment]::NewLine
        $ntfsEnabled = ($raw -match '(?im)NTFS\s+DisableDeleteNotify\s*=\s*0')
        $ntfsDisabled = ($raw -match '(?im)NTFS\s+DisableDeleteNotify\s*=\s*1')
        $status = if ($ntfsEnabled) { 'Healthy' } elseif ($ntfsDisabled) { 'Review' } else { 'Info' }

        $r = Add-Result 95 'TRIM' 'Delete notification / TRIM' $status $raw `
            'DisableDeleteNotify=0 means delete notifications are enabled. Storage behavior still depends on the device and driver stack.'
        [void]$local.Add($r)
    } catch {
        $r = Add-Result 95 'TRIM' 'Delete notification / TRIM' 'Error' $_.Exception.Message `
            'Run as administrator if fsutil cannot query this state.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'TRIM / delete notification'
    return $local
}

# ---------------------------------------------------------------------------
# 96. Physical Disk Health
# ---------------------------------------------------------------------------
function Invoke-ScanPhysicalDiskHealth {
    Write-Title '96. Physical Disk Health'
    $local = New-Object System.Collections.ArrayList

    if (-not (Test-CommandAvailable 'Get-PhysicalDisk')) {
        $r = Add-Result 96 'PhysicalDisk' 'Physical disks' 'Unavailable' `
            'Get-PhysicalDisk is unavailable.' `
            'Storage provider support may vary by hardware and Windows edition.'
        [void]$local.Add($r)
        Show-ResultTable -Data $local -Title 'Physical disk health'
        return $local
    }

    try {
        $disks = @(Get-PhysicalDisk -ErrorAction Stop | Sort-Object FriendlyName)
        foreach ($disk in $disks) {
            $status = if ([string]$disk.HealthStatus -eq 'Healthy') { 'Healthy' } else { 'Warning' }
            $detail = "MediaType=$($disk.MediaType) | BusType=$($disk.BusType) | Health=$($disk.HealthStatus) | Operational=$($disk.OperationalStatus -join ',') | Size=$(Format-Bytes ([long]$disk.Size))"

            if (Test-CommandAvailable 'Get-StorageReliabilityCounter') {
                try {
                    $rc = Get-StorageReliabilityCounter -PhysicalDisk $disk -ErrorAction Stop
                    $detail += " | Temperature=$($rc.Temperature)C | Wear=$($rc.Wear) | ReadErrorsTotal=$($rc.ReadErrorsTotal) | WriteErrorsTotal=$($rc.WriteErrorsTotal)"
                } catch {}
            }

            $r = Add-Result 96 'PhysicalDisk' ([string]$disk.FriendlyName) $status $detail `
                'Health counters are hardware/driver dependent. Back up important data before troubleshooting a degraded disk.'
            [void]$local.Add($r)
        }
    } catch {
        $r = Add-Result 96 'PhysicalDisk' 'Physical disks' 'Error' $_.Exception.Message `
            'Storage provider or administrator access may be required.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Physical disk health'
    return $local
}

# ---------------------------------------------------------------------------
# 97. WHEA Hardware Error Analyzer
# ---------------------------------------------------------------------------
function Invoke-ScanWhea {
    Write-Title '97. WHEA Hardware Error Analyzer'
    $local = New-Object System.Collections.ArrayList
    $startTime = (Get-Date).AddDays(-30)

    try {
        $events = @(
            Get-WinEvent -FilterHashtable @{
                LogName='System'
                ProviderName='Microsoft-Windows-WHEA-Logger'
                StartTime=$startTime
            } -MaxEvents 100 -ErrorAction Stop
        )

        foreach ($event in $events) {
            $status = if ($event.Level -le 2) { 'Warning' } else { 'Review' }
            $message = [string]$event.Message
            if ($message.Length -gt 700) { $message = $message.Substring(0,700) + '...' }

            $r = Add-Result 97 'WHEA' ("Event ID {0} / Record {1}" -f $event.Id,$event.RecordId) $status `
                ("Time={0} | Level={1} | {2}" -f $event.TimeCreated,$event.LevelDisplayName,$message) `
                'Repeated WHEA events can indicate CPU, memory, PCIe, storage, firmware or power instability and deserve hardware-focused investigation.'
            [void]$local.Add($r)
        }

        if ($events.Count -eq 0) {
            $r = Add-Result 97 'WHEA' 'WHEA events (last 30 days)' 'Healthy' `
                'No WHEA-Logger event was found in the System log during the selected period.' `
                'No hardware error is proven by this result; it only reflects logged WHEA events.'
            [void]$local.Add($r)
        }
    } catch {
        $r = Add-Result 97 'WHEA' 'WHEA events' 'Error' $_.Exception.Message `
            'The System event log could not be queried for WHEA records.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'WHEA hardware errors'
    return $local
}

# ---------------------------------------------------------------------------
# 98. Reliability Monitor Analyzer
# ---------------------------------------------------------------------------
function Invoke-ScanReliability {
    Write-Title '98. Reliability Monitor Analyzer'
    $local = New-Object System.Collections.ArrayList
    $cutoff = (Get-Date).AddDays(-30)

    try {
        $records = @(
            Get-CimInstance -ClassName Win32_ReliabilityRecords -ErrorAction Stop |
                Where-Object {
                    $time = $_.TimeGenerated
                    if ($time) {
                        try { ([datetime]$time) -ge $cutoff } catch { $true }
                    } else { $true }
                } |
                Sort-Object TimeGenerated -Descending |
                Select-Object -First 50
        )

        foreach ($record in $records) {
            $source = if ($record.SourceName) { [string]$record.SourceName } elseif ($record.ProductName) { [string]$record.ProductName } else { 'Reliability record' }
            $message = [string]$record.Message
            if ($message.Length -gt 600) { $message = $message.Substring(0,600) + '...' }

            $status = if ($source -match '(?i)Windows Error Reporting|Application Error|Hardware') { 'Review' } else { 'Info' }
            $r = Add-Result 98 'Reliability' $source $status `
                ("Time={0} | EventId={1} | Product={2} | {3}" -f $record.TimeGenerated,$record.EventIdentifier,$record.ProductName,$message) `
                'Use recurring failures and correlated WER/EventLog findings to prioritize troubleshooting.'
            [void]$local.Add($r)
        }

        if ($records.Count -eq 0) {
            $r = Add-Result 98 'Reliability' 'Reliability history (last 30 days)' 'No data' `
                'No reliability record was returned for the selected period.' `
                'Reliability Monitor data may be disabled, unavailable or empty.'
            [void]$local.Add($r)
        }
    } catch {
        $r = Add-Result 98 'Reliability' 'Reliability Monitor data' 'Error' $_.Exception.Message `
            'Win32_ReliabilityRecords could not be queried.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Reliability Monitor records'
    return $local
}

# ---------------------------------------------------------------------------
# 99. Modern Standby Support
# ---------------------------------------------------------------------------
function Invoke-ScanModernStandby {
    Write-Title '99. Modern Standby Support'
    $local = New-Object System.Collections.ArrayList

    if (-not (Test-CommandAvailable 'powercfg.exe')) {
        $r = Add-Result 99 'ModernStandby' 'Modern Standby' 'Unavailable' 'powercfg.exe was not found.' 'No action performed.'
        [void]$local.Add($r)
        Show-ResultTable -Data $local -Title 'Modern Standby support'
        return $local
    }

    try {
        $raw = (& powercfg.exe /a 2>&1) -join [Environment]::NewLine
        $supported = ($raw -match '(?i)Standby \(S0 Low Power Idle\)')
        $status = if ($supported) { 'Supported' } else { 'Info' }

        $r = Add-Result 99 'ModernStandby' 'Modern Standby / S0 Low Power Idle' $status $raw `
            'Modern Standby availability is firmware/hardware dependent. Unsupported status is not automatically a fault.'
        [void]$local.Add($r)
    } catch {
        $r = Add-Result 99 'ModernStandby' 'Modern Standby' 'Error' $_.Exception.Message `
            'powercfg could not enumerate sleep states.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Modern Standby support'
    return $local
}

# ---------------------------------------------------------------------------
# 100. Power Requests
# ---------------------------------------------------------------------------
function Invoke-ScanPowerRequests {
    Write-Title '100. Power Requests'
    $local = New-Object System.Collections.ArrayList

    if (-not (Test-CommandAvailable 'powercfg.exe')) {
        $r = Add-Result 100 'PowerRequests' 'Active power requests' 'Unavailable' 'powercfg.exe was not found.' 'No action performed.'
        [void]$local.Add($r)
        Show-ResultTable -Data $local -Title 'Power requests'
        return $local
    }

    try {
        $raw = (& powercfg.exe /requests 2>&1) -join [Environment]::NewLine
        $interesting = @(
            $raw -split "`r?`n" |
                Where-Object {
                    $line = $_.Trim()
                    $line -and
                    $line -notmatch '^(?i)(DISPLAY:|SYSTEM:|AWAYMODE:|EXECUTION:|PERFBOOST:|ACTIVELOCKSCREEN:|None\.)$'
                }
        )

        $status = if ($interesting.Count -gt 0) { 'Review' } else { 'Healthy' }
        $r = Add-Result 100 'PowerRequests' 'Active power requests' $status $raw `
            'Active requests can intentionally prevent display-off or sleep. Correlate them with the owning process/driver before changing anything.'
        [void]$local.Add($r)
    } catch {
        $r = Add-Result 100 'PowerRequests' 'Active power requests' 'Error' $_.Exception.Message `
            'Administrator rights may be required for complete power-request information.'
        [void]$local.Add($r)
    }

    Show-ResultTable -Data $local -Title 'Power requests'
    return $local
}


# ---------------------------------------------------------------------------
# v2.0 Extended module framework (101-200)
# ---------------------------------------------------------------------------
function ConvertTo-DetoxDetailString {
    param(
        [AllowNull()]$Object,
        [string[]]$Properties = @()
    )

    if ($null -eq $Object) { return '' }
    if ($Object -is [string]) { return [string]$Object }

    $parts = New-Object System.Collections.ArrayList
    $props = if ($Properties.Count -gt 0) {
        @($Properties)
    } else {
        @($Object.PSObject.Properties | Where-Object { $_.MemberType -match 'Property' } | Select-Object -First 16 -ExpandProperty Name)
    }

    foreach ($name in $props) {
        if ($Object.PSObject.Properties.Name -contains $name) {
            $value = $Object.$name
            if ($value -is [System.Array]) { $value = ($value -join ', ') }
            [void]$parts.Add(("{0}={1}" -f $name,$value))
        }
    }
    return ($parts -join ' | ')
}

function Invoke-GenericCommandModule {
    param(
        [int]$Module,[string]$Category,[string]$Title,[string]$Item,
        [string]$Command,[string[]]$Arguments=@(),[string]$Recommendation='Report-only review.'
    )
    Write-Title $Title
    $local=New-Object System.Collections.ArrayList
    $cmd=Get-Command -Name $Command -ErrorAction SilentlyContinue
    if($null -eq $cmd){
        [void]$local.Add((Add-Result $Module $Category $Item 'Unavailable' "$Command is not available in this environment." $Recommendation))
    } else {
        try {
            $output=(& $Command @Arguments 2>&1 | Out-String -Width 240).Trim()
            if([string]::IsNullOrWhiteSpace($output)){ $output='Command completed with no textual output.' }
            [void]$local.Add((Add-Result $Module $Category $Item 'Info' $output $Recommendation))
        } catch {
            [void]$local.Add((Add-Result $Module $Category $Item 'Error' $_.Exception.Message $Recommendation))
        }
    }
    Show-ResultTable -Data $local -Title $Title
    return $local
}

function Invoke-GenericServiceModule {
    param([int]$Module,[string]$Category,[string]$Title,[string[]]$Services,[string]$Recommendation='Review service state before changing it.')
    Write-Title $Title
    $local=New-Object System.Collections.ArrayList
    foreach($name in $Services){
        try {
            $svc=Get-CimInstance Win32_Service -Filter ("Name='{0}'" -f ($name -replace "'","''")) -ErrorAction Stop
            if($null -eq $svc){
                [void]$local.Add((Add-Result $Module $Category $name 'Not found' 'Service is not installed.' $Recommendation))
            } else {
                $detail="DisplayName=$($svc.DisplayName) | State=$($svc.State) | StartMode=$($svc.StartMode) | StartName=$($svc.StartName) | PathName=$($svc.PathName)"
                $status=if($svc.State -eq 'Running'){'Running'}else{[string]$svc.State}
                [void]$local.Add((Add-Result $Module $Category $name $status $detail $Recommendation))
            }
        } catch {
            [void]$local.Add((Add-Result $Module $Category $name 'Error' $_.Exception.Message $Recommendation))
        }
    }
    Show-ResultTable -Data $local -Title $Title
    return $local
}

function Invoke-GenericRegistryModule {
    param([int]$Module,[string]$Category,[string]$Title,[object[]]$Checks,[string]$Recommendation='Report-only policy/configuration review.')
    Write-Title $Title
    $local=New-Object System.Collections.ArrayList
    foreach($check in $Checks){
        $path=[string]$check.Path
        $item=[string]$check.Item
        $names=@($check.Names)
        if(-not (Test-Path -LiteralPath $path)){
            [void]$local.Add((Add-Result $Module $Category $item 'Not configured' "Registry path not found: $path" $Recommendation))
            continue
        }
        try {
            $p=Get-ItemProperty -LiteralPath $path -ErrorAction Stop
            $lines=New-Object System.Collections.ArrayList
            if($names.Count -eq 0){
                $names=@($p.PSObject.Properties | Where-Object { $_.Name -notmatch '^PS' } | Select-Object -First 24 -ExpandProperty Name)
            }
            foreach($name in $names){
                if($p.PSObject.Properties.Name -contains $name){
                    $v=$p.$name
                    if($v -is [System.Array]){$v=$v -join ', '}
                    [void]$lines.Add(("{0}={1}" -f $name,$v))
                } else {
                    [void]$lines.Add(("{0}=<not set>" -f $name))
                }
            }
            [void]$local.Add((Add-Result $Module $Category $item 'Info' ("Path=$path | " + ($lines -join ' | ')) $Recommendation))
        } catch {
            [void]$local.Add((Add-Result $Module $Category $item 'Error' $_.Exception.Message $Recommendation))
        }
    }
    Show-ResultTable -Data $local -Title $Title
    return $local
}

function Invoke-GenericCmdletModule {
    param(
        [int]$Module,[string]$Category,[string]$Title,[string]$CommandName,
        [scriptblock]$Query,[string[]]$Properties=@(),[string]$Recommendation='Report-only inventory.'
    )
    Write-Title $Title
    $local=New-Object System.Collections.ArrayList
    if($CommandName -and -not (Test-CommandAvailable $CommandName)){
        [void]$local.Add((Add-Result $Module $Category $CommandName 'Unavailable' "$CommandName is not available in this environment." $Recommendation))
        Show-ResultTable -Data $local -Title $Title
        return $local
    }
    try {
        $rows=@(& $Query)
        if($rows.Count -eq 0){
            [void]$local.Add((Add-Result $Module $Category $Title 'No data' 'The query returned no records.' $Recommendation))
        } else {
            $i=0
            foreach($row in $rows | Select-Object -First 120){
                $i++
                $item=$null
                foreach($candidate in @('Name','FriendlyName','DeviceID','InterfaceAlias','DriveLetter','InstanceName','InstanceId','DestinationPrefix','LocalPath','FeatureName','CapabilityName','LogName','Path','Caption','Description')){
                    if($row.PSObject.Properties.Name -contains $candidate -and -not [string]::IsNullOrWhiteSpace([string]$row.$candidate)){
                        $item=[string]$row.$candidate; break
                    }
                }
                if([string]::IsNullOrWhiteSpace($item)){ $item=("{0} #{1}" -f $Title,$i) }
                $detail=ConvertTo-DetoxDetailString -Object $row -Properties $Properties
                if([string]::IsNullOrWhiteSpace($detail)){ $detail=($row | Out-String -Width 220).Trim() }
                [void]$local.Add((Add-Result $Module $Category $item 'Info' $detail $Recommendation))
            }
        }
    } catch {
        [void]$local.Add((Add-Result $Module $Category $Title 'Error' $_.Exception.Message $Recommendation))
    }
    Show-ResultTable -Data $local -Title $Title
    return $local
}

function Invoke-GenericEventModule {
    param(
        [int]$Module,[string]$Category,[string]$Title,[string]$LogName,
        [string]$ProviderName='',[int[]]$Ids=@(),[int]$Days=30,[int]$MaxEvents=40,
        [string]$Recommendation='Review recurring or high-severity events before remediation.'
    )
    Write-Title $Title
    $local=New-Object System.Collections.ArrayList
    try {
        $filter=@{LogName=$LogName;StartTime=(Get-Date).AddDays(-$Days)}
        if($ProviderName){$filter.ProviderName=$ProviderName}
        if($Ids.Count -gt 0){$filter.Id=$Ids}
        $events=@(Get-WinEvent -FilterHashtable $filter -ErrorAction SilentlyContinue | Select-Object -First $MaxEvents)
        [void]$local.Add((Add-Result $Module $Category $Title $(if($events.Count -gt 0){'Review'}else{'Healthy'}) ("Events in last {0} days: {1}" -f $Days,$events.Count) $Recommendation))
        foreach($e in $events){
            $msg=([string]$e.Message -replace "`r?`n",' ')
            if($msg.Length -gt 500){$msg=$msg.Substring(0,500)+'...'}
            $detail="Time=$($e.TimeCreated) | Id=$($e.Id) | Level=$($e.LevelDisplayName) | Provider=$($e.ProviderName) | $msg"
            [void]$local.Add((Add-Result $Module $Category ("Event {0}" -f $e.Id) 'Info' $detail $Recommendation))
        }
    } catch {
        [void]$local.Add((Add-Result $Module $Category $Title 'Error' $_.Exception.Message $Recommendation))
    }
    Show-ResultTable -Data $local -Title $Title
    return $local
}

function Invoke-GenericFolderModule {
    param([int]$Module,[string]$Category,[string]$Title,[object[]]$Targets,[string]$Recommendation='Report-only storage review.')
    Write-Title $Title
    $local=New-Object System.Collections.ArrayList
    foreach($t in $Targets){
        $path=[Environment]::ExpandEnvironmentVariables([string]$t.Path)
        $item=[string]$t.Item
        if(-not (Test-Path -LiteralPath $path)){
            [void]$local.Add((Add-Result $Module $Category $item 'Not found' "Path not found: $path" $Recommendation 0L))
            continue
        }
        $size=Get-FolderSizeSafe -Path $path
        [void]$local.Add((Add-Result $Module $Category $item 'Info' "Path=$path" $Recommendation $size))
    }
    Show-ResultTable -Data $local -Title $Title
    return $local
}

function Invoke-GenericFeatureModule {
    param([int]$Module,[string]$Category,[string]$Title,[string[]]$Features,[string]$Recommendation='Review Windows feature requirements before changing state.')
    Write-Title $Title
    $local=New-Object System.Collections.ArrayList
    if(-not (Test-CommandAvailable 'Get-WindowsOptionalFeature')){
        [void]$local.Add((Add-Result $Module $Category $Title 'Unavailable' 'Get-WindowsOptionalFeature is unavailable.' $Recommendation))
    } else {
        foreach($name in $Features){
            try {
                $f=Get-WindowsOptionalFeature -Online -FeatureName $name -ErrorAction Stop
                [void]$local.Add((Add-Result $Module $Category $name ([string]$f.State) ("State={0}" -f $f.State) $Recommendation))
            } catch {
                [void]$local.Add((Add-Result $Module $Category $name 'Unavailable' $_.Exception.Message $Recommendation))
            }
        }
    }
    Show-ResultTable -Data $local -Title $Title
    return $local
}

function Invoke-ExtendedModule {
    param([Parameter(Mandatory)][int]$ModuleNumber)
    switch($ModuleNumber) {
        101 { Write-Title '101. NTFS Dirty Bit Status'; $local=New-Object System.Collections.ArrayList; foreach($d in @(Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" -ErrorAction SilentlyContinue)){ $drive=[string]$d.DeviceID; try{$out=(& fsutil.exe dirty query $drive 2>&1 | Out-String).Trim(); $status=if($out -match 'is dirty'){'Review'}else{'Info'}; [void]$local.Add((Add-Result 101 'NTFS' $drive $status $out 'A dirty volume can indicate an unclean shutdown or pending file-system check.'))}catch{[void]$local.Add((Add-Result 101 'NTFS' $drive 'Error' $_.Exception.Message 'Review the volume manually.'))} }; Show-ResultTable $local 'NTFS dirty-bit status'; return $local }
        102 { Invoke-GenericCommandModule -Module 102 -Category 'NTFS' -Title '102. NTFS Compression State' -Item 'System drive compression' -Command 'compact.exe' -Arguments @('/Q',$env:SystemDrive+'\') -Recommendation 'Compression can be intentional; report-only.' }
        103 { Write-Title '103. NTFS Reparse Point Inventory'; $local=New-Object System.Collections.ArrayList; $roots=@($env:USERPROFILE,$env:ProgramData) | Where-Object {$_ -and (Test-Path -LiteralPath $_)}; $count=0; foreach($root in $roots){ foreach($x in @(Get-ChildItem -LiteralPath $root -Force -Recurse -Attributes ReparsePoint -ErrorAction SilentlyContinue | Select-Object -First 120)){ $count++; [void]$local.Add((Add-Result 103 'NTFS' $x.FullName 'Info' ("Attributes={0} | LinkType={1} | Target={2}" -f $x.Attributes,$x.LinkType,($x.Target -join ',')) 'Reparse points/junctions are frequently legitimate; review only.')) } }; if($count -eq 0){[void]$local.Add((Add-Result 103 'NTFS' 'Reparse points' 'No data' 'No reparse points were returned from the scoped scan.' 'No action required.'))}; Show-ResultTable $local 'NTFS reparse points'; return $local }
        104 { Invoke-GenericCmdletModule -Module 104 -Category 'Storage' -Title '104. Volume Mount Points' -CommandName 'Get-CimInstance' -Query { Get-CimInstance Win32_Volume -ErrorAction SilentlyContinue } -Properties @('DriveLetter','Label','FileSystem','Capacity','FreeSpace','DeviceID') -Recommendation 'Mount points and drive letters may be application dependencies.' }
        105 { Invoke-GenericCommandModule -Module 105 -Category 'NTFS' -Title '105. Disk Quota Configuration' -Item 'System drive quotas' -Command 'fsutil.exe' -Arguments @('quota','query',$env:SystemDrive) -Recommendation 'Disk quotas are usually managed by policy or administrators.' }
        106 { Invoke-GenericCmdletModule -Module 106 -Category 'StorageSpaces' -Title '106. Storage Spaces Pool Health' -CommandName 'Get-StoragePool' -Query { Get-StoragePool -ErrorAction SilentlyContinue } -Properties @('FriendlyName','HealthStatus','OperationalStatus','IsPrimordial','Size','AllocatedSize') -Recommendation 'Degraded pools require storage-specific investigation; no automatic repair is performed.' }
        107 { Invoke-GenericCmdletModule -Module 107 -Category 'StorageSpaces' -Title '107. Storage Spaces Virtual Disks' -CommandName 'Get-VirtualDisk' -Query { Get-VirtualDisk -ErrorAction SilentlyContinue } -Properties @('FriendlyName','HealthStatus','OperationalStatus','ResiliencySettingName','Size','FootprintOnPool') -Recommendation 'Virtual-disk changes are never automatic.' }
        108 { Invoke-GenericCmdletModule -Module 108 -Category 'StorageSpaces' -Title '108. Storage Spaces Physical Disks' -CommandName 'Get-PhysicalDisk' -Query { Get-PhysicalDisk -ErrorAction SilentlyContinue } -Properties @('FriendlyName','MediaType','HealthStatus','OperationalStatus','Size','CanPool','Usage') -Recommendation 'Review non-healthy disks before any pool operation.' }
        109 { Invoke-GenericCommandModule -Module 109 -Category 'VSS' -Title '109. Shadow Copy Providers' -Item 'VSS providers' -Command 'vssadmin.exe' -Arguments @('list','providers') -Recommendation 'Third-party VSS providers may be installed by backup software.' }
        110 { Invoke-GenericCommandModule -Module 110 -Category 'VSS' -Title '110. Shadow Copy Inventory' -Item 'VSS shadow copies' -Command 'vssadmin.exe' -Arguments @('list','shadows') -Recommendation 'Do not delete shadow copies until backup/recovery requirements are verified.' }
        111 { Invoke-GenericServiceModule -Module 111 -Category 'EFS' -Title '111. Encrypting File System (EFS) State' -Services @('EFS') -Recommendation 'EFS may protect encrypted user files; do not disable it without verifying encryption use.' }
        112 { Invoke-GenericCommandModule -Module 112 -Category 'Storage' -Title '112. CompactOS State' -Item 'CompactOS' -Command 'compact.exe' -Arguments @('/CompactOS:query') -Recommendation 'CompactOS can reduce Windows footprint and may be intentional.' }
        113 { Invoke-GenericCommandModule -Module 113 -Category 'NTFS' -Title '113. USN Journal Status' -Item 'System drive USN journal' -Command 'fsutil.exe' -Arguments @('usn','queryjournal',$env:SystemDrive) -Recommendation 'The NTFS USN journal is a normal file-system feature; report-only.' }
        114 { Invoke-GenericCmdletModule -Module 114 -Category 'Storage' -Title '114. ReFS Volume Inventory' -CommandName 'Get-Volume' -Query { Get-Volume -ErrorAction SilentlyContinue | Where-Object {$_.FileSystem -eq 'ReFS'} } -Properties @('DriveLetter','FileSystemLabel','FileSystem','HealthStatus','OperationalStatus','Size','SizeRemaining') -Recommendation 'ReFS volumes are reported only.' }
        115 { Invoke-GenericFeatureModule -Module 115 -Category 'Storage' -Title '115. Data Deduplication Feature Status' -Features @('Dedup-Core') -Recommendation 'Data Deduplication is edition/role dependent and should not be changed automatically.' }
        116 { Invoke-GenericServiceModule -Module 116 -Category 'Storage' -Title '116. Offline Files / CSC Status' -Services @('CscService') -Recommendation 'Offline Files can be required for enterprise file shares; report-only.' }
        117 { Invoke-GenericRegistryModule -Module 117 -Category 'WindowsUpdate' -Title '117. Windows Update Policy' -Checks @(@{Item='Windows Update policy';Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate';Names=@('DisableWindowsUpdateAccess','DoNotConnectToWindowsUpdateInternetLocations','SetDisableUXWUAccess','TargetReleaseVersion','TargetReleaseVersionInfo','ProductVersion')}) -Recommendation 'Policy values may be organization-managed.' }
        118 { Invoke-GenericRegistryModule -Module 118 -Category 'WindowsUpdate' -Title '118. WSUS Configuration' -Checks @(@{Item='WSUS server';Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate';Names=@('WUServer','WUStatusServer')},@{Item='Automatic Update policy';Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU';Names=@('UseWUServer','AUOptions','NoAutoUpdate')}) -Recommendation 'WSUS settings may be centrally managed.' }
        119 { Invoke-GenericServiceModule -Module 119 -Category 'WindowsUpdate' -Title '119. BITS Service Health' -Services @('BITS') -Recommendation 'Service state can be trigger-based; review before changing startup mode.' }
        120 { Invoke-GenericServiceModule -Module 120 -Category 'WindowsUpdate' -Title '120. Windows Update Service Health' -Services @('wuauserv') -Recommendation 'Service state can be trigger-based; review before changing startup mode.' }
        121 { Invoke-GenericServiceModule -Module 121 -Category 'WindowsUpdate' -Title '121. Update Orchestrator Service Health' -Services @('UsoSvc') -Recommendation 'Service state can be trigger-based; review before changing startup mode.' }
        122 { Invoke-GenericServiceModule -Module 122 -Category 'WindowsUpdate' -Title '122. Windows Modules Installer Health' -Services @('TrustedInstaller') -Recommendation 'Service state can be trigger-based; review before changing startup mode.' }
        123 { Invoke-GenericServiceModule -Module 123 -Category 'WindowsUpdate' -Title '123. Windows Update Medic Service Health' -Services @('WaaSMedicSvc') -Recommendation 'Service state can be trigger-based; review before changing startup mode.' }
        124 { Invoke-GenericRegistryModule -Module 124 -Category 'DeliveryOptimization' -Title '124. Delivery Optimization Configuration' -Checks @(@{Item='Delivery Optimization policy';Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization';Names=@('DODownloadMode','DOMaxCacheSize','DOMaxCacheAge','DOMinFileSizeToCache','DOMonthlyUploadDataCap')}) -Recommendation 'Delivery Optimization values may be policy-managed.' }
        125 { Invoke-GenericCmdletModule -Module 125 -Category 'Capabilities' -Title '125. Installed Windows Capabilities' -CommandName 'Get-WindowsCapability' -Query { Get-WindowsCapability -Online -ErrorAction SilentlyContinue | Where-Object {$_.State -eq 'Installed'} } -Properties @('Name','State') -Recommendation 'Capabilities are report-only; remove only when application/administrative requirements are known.' }
        126 { Invoke-GenericCmdletModule -Module 126 -Category 'Language' -Title '126. Language Pack Inventory' -CommandName 'Get-WinUserLanguageList' -Query { Get-WinUserLanguageList } -Properties @('LanguageTag','Autonym','EnglishName','LocalizedName','InputMethodTips') -Recommendation 'Language components may support speech, handwriting and input methods.' }
        127 { Invoke-GenericCmdletModule -Module 127 -Category 'WindowsUpdate' -Title '127. Installed Update Inventory' -CommandName 'Get-HotFix' -Query { Get-HotFix -ErrorAction SilentlyContinue | Sort-Object InstalledOn -Descending | Select-Object -First 120 } -Properties @('HotFixID','Description','InstalledBy','InstalledOn') -Recommendation 'Installed update history is report-only.' }
        128 { Invoke-GenericEventModule -Module 128 -Category 'WindowsUpdate' -Title '128. Failed Windows Update Event Summary' -LogName 'System' -ProviderName 'Microsoft-Windows-WindowsUpdateClient' -Days 90 -MaxEvents 40 -Recommendation 'Repeated update failures should be correlated with KB IDs and servicing logs.' }
        129 { Write-Title '129. Pending Servicing Files'; $local=New-Object System.Collections.ArrayList; foreach($p in @((Join-Path $env:WINDIR 'WinSxS\pending.xml'),(Join-Path $env:WINDIR 'WinSxS\reboot.xml'),(Join-Path $env:WINDIR 'WinSxS\cleanup.xml'))){$exists=Test-Path -LiteralPath $p; [void]$local.Add((Add-Result 129 'Servicing' (Split-Path $p -Leaf) $(if($exists){'Review'}else{'Clear'}) ("Present={0} | Path={1}" -f $exists,$p) 'Pending servicing artifacts can be normal during update/reboot cycles; never delete them manually.'))}; Show-ResultTable $local 'Pending servicing files'; return $local }
        130 { Invoke-GenericCmdletModule -Module 130 -Category 'Features' -Title '130. Optional Feature Payload State' -CommandName 'Get-WindowsOptionalFeature' -Query { Get-WindowsOptionalFeature -Online -ErrorAction SilentlyContinue | Where-Object {$_.State -match 'PayloadRemoved|DisabledWithPayloadRemoved'} } -Properties @('FeatureName','State') -Recommendation 'Removed payloads are normal for unused features; report-only.' }
        131 { Invoke-GenericCmdletModule -Module 131 -Category 'Recovery' -Title '131. Recovery Partition Inventory' -CommandName 'Get-Partition' -Query { Get-Partition -ErrorAction SilentlyContinue | Where-Object {$_.Type -match 'Recovery' -or $_.GptType -eq '{de94bba4-06d1-4d40-a16a-bfd50179d6ac}'} } -Properties @('DiskNumber','PartitionNumber','DriveLetter','Type','GptType','Size','IsHidden','IsReadOnly') -Recommendation 'Recovery partitions should not be deleted or resized casually.' }
        132 { Invoke-GenericCmdletModule -Module 132 -Category 'Recovery' -Title '132. Recovery Volume Capacity' -CommandName 'Get-CimInstance' -Query { Get-CimInstance Win32_Volume -ErrorAction SilentlyContinue | Where-Object {$_.Label -match 'Recovery|WinRE' -or $_.Name -match 'Recovery'} } -Properties @('Name','Label','FileSystem','Capacity','FreeSpace','BootVolume','SystemVolume') -Recommendation 'Recovery volume capacity is report-only.' }
        133 { Invoke-GenericCommandModule -Module 133 -Category 'Boot' -Title '133. Boot Manager Timeout' -Item 'Boot Manager' -Command 'bcdedit.exe' -Arguments @('/enum','{bootmgr}') -Recommendation 'BCD changes can make Windows unbootable; report-only.' }
        134 { Invoke-GenericCommandModule -Module 134 -Category 'Boot' -Title '134. BCD Boot Entry Inventory' -Item 'BCD entries' -Command 'bcdedit.exe' -Arguments @('/enum','all') -Recommendation 'BCD entries are reported only.' }
        135 { Invoke-GenericCommandModule -Module 135 -Category 'Boot' -Title '135. SafeBoot Configuration' -Item 'Current boot entry' -Command 'bcdedit.exe' -Arguments @('/enum','{current}') -Recommendation 'Review safeboot/debug flags; do not modify automatically.' }
        136 { Invoke-GenericCommandModule -Module 136 -Category 'Boot' -Title '136. Boot Logging State' -Item 'Current boot entry' -Command 'bcdedit.exe' -Arguments @('/enum','{current}') -Recommendation 'Boot logging is a troubleshooting option; report-only.' }
        137 { Invoke-GenericRegistryModule -Module 137 -Category 'Startup' -Title '137. Task Manager StartupApproved Inventory' -Checks @(@{Item='StartupApproved Run';Path='HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run';Names=@()},@{Item='StartupApproved StartupFolder';Path='HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\StartupFolder';Names=@()}) -Recommendation 'Binary StartupApproved values encode Task Manager startup state; report-only.' }
        138 { Invoke-GenericRegistryModule -Module 138 -Category 'CrashControl' -Title '138. Crash Dump Boot Configuration' -Checks @(@{Item='CrashControl';Path='HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl';Names=@('CrashDumpEnabled','DumpFile','MinidumpDir','Overwrite','AutoReboot','LogEvent')}) -Recommendation 'Crash-dump configuration affects post-crash diagnostics.' }
        139 { Invoke-GenericRegistryModule -Module 139 -Category 'CrashControl' -Title '139. Automatic Memory Dump Policy' -Checks @(@{Item='Automatic memory dump';Path='HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl';Names=@('CrashDumpEnabled','AlwaysKeepMemoryDump','IgnorePagefileSize','FilterPages')}) -Recommendation 'Do not change dump policy without considering incident-response and debugging needs.' }
        140 { Invoke-GenericEventModule -Module 140 -Category 'Boot' -Title '140. Shutdown and Unexpected Restart Summary' -LogName 'System' -Ids @(6005,6006,6008,1074) -Days 30 -MaxEvents 60 -Recommendation 'Unexpected shutdowns should be correlated with power, WHEA and crash data.' }
        141 { Invoke-GenericCmdletModule -Module 141 -Category 'DNS' -Title '141. DNS Server Configuration' -CommandName 'Get-DnsClientServerAddress' -Query { Get-DnsClientServerAddress -ErrorAction SilentlyContinue } -Properties @('InterfaceAlias','InterfaceIndex','AddressFamily','ServerAddresses') -Recommendation 'DNS server settings may be DHCP- or policy-managed.' }
        142 { Invoke-GenericCmdletModule -Module 142 -Category 'DNS' -Title '142. DNS-over-HTTPS Configuration' -CommandName 'Get-DnsClientDohServerAddress' -Query { Get-DnsClientDohServerAddress -ErrorAction SilentlyContinue } -Properties @('ServerAddress','DohTemplate','AllowFallbackToUdp','AutoUpgrade') -Recommendation 'DoH availability depends on Windows build and DNS configuration.' }
        143 { Invoke-GenericCmdletModule -Module 143 -Category 'NetworkProfile' -Title '143. Network Profile Categories' -CommandName 'Get-NetConnectionProfile' -Query { Get-NetConnectionProfile -ErrorAction SilentlyContinue } -Properties @('Name','InterfaceAlias','NetworkCategory','IPv4Connectivity','IPv6Connectivity') -Recommendation 'Public/Private/Domain profile selection affects firewall behavior.' }
        144 { Invoke-GenericCmdletModule -Module 144 -Category 'IPv6' -Title '144. IPv6 Binding Status' -CommandName 'Get-NetAdapterBinding' -Query { Get-NetAdapterBinding -ComponentID ms_tcpip6 -ErrorAction SilentlyContinue } -Properties @('Name','DisplayName','ComponentID','Enabled') -Recommendation 'Disabling IPv6 broadly can break Windows and application functionality.' }
        145 { Invoke-GenericCmdletModule -Module 145 -Category 'NetworkMetric' -Title '145. Interface Metric Analyzer' -CommandName 'Get-NetIPInterface' -Query { Get-NetIPInterface -ErrorAction SilentlyContinue | Sort-Object InterfaceMetric } -Properties @('InterfaceAlias','AddressFamily','ConnectionState','Dhcp','AutomaticMetric','InterfaceMetric','NlMtu') -Recommendation 'Interface metrics influence route selection; report-only.' }
        146 { Invoke-GenericCmdletModule -Module 146 -Category 'IPConfig' -Title '146. DHCP vs Static IP Inventory' -CommandName 'Get-NetIPInterface' -Query { Get-NetIPInterface -AddressFamily IPv4 -ErrorAction SilentlyContinue } -Properties @('InterfaceAlias','ConnectionState','Dhcp','AutomaticMetric','InterfaceMetric') -Recommendation 'Static addressing may be intentional for servers, labs, VPNs or appliances.' }
        147 { Invoke-GenericCmdletModule -Module 147 -Category 'DNS' -Title '147. NRPT Rules' -CommandName 'Get-DnsClientNrptPolicy' -Query { Get-DnsClientNrptPolicy -ErrorAction SilentlyContinue } -Properties @('Namespace','NameServers','DnsSecValidationRequired','DnsSecQueryIPsecRequired','DirectAccessDnsServers') -Recommendation 'NRPT rules may be created by DirectAccess, VPN or enterprise policy.' }
        148 { Invoke-GenericCommandModule -Module 148 -Category 'TCP' -Title '148. TCP Global Settings' -Item 'TCP global configuration' -Command 'netsh.exe' -Arguments @('interface','tcp','show','global') -Recommendation 'TCP global tuning should be changed only with evidence and workload context.' }
        149 { Invoke-GenericCommandModule -Module 149 -Category 'TCP' -Title '149. TCP Auto-Tuning State' -Item 'Receive Window Auto-Tuning' -Command 'netsh.exe' -Arguments @('interface','tcp','show','global') -Recommendation 'Normal auto-tuning is appropriate for most Windows 11 clients.' }
        150 { Invoke-GenericCommandModule -Module 150 -Category 'Network' -Title '150. PortProxy Rules' -Item 'netsh portproxy' -Command 'netsh.exe' -Arguments @('interface','portproxy','show','all') -Recommendation 'PortProxy rules can expose local services or redirect traffic; verify ownership.' }
        151 { Invoke-GenericCmdletModule -Module 151 -Category 'Network' -Title '151. Listening TCP Ports' -CommandName 'Get-NetTCPConnection' -Query { Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | Sort-Object LocalPort } -Properties @('LocalAddress','LocalPort','OwningProcess','AppliedSetting','CreationTime') -Recommendation 'A listening port is not automatically suspicious; correlate with the owning process/service.' }
        152 { Invoke-GenericCmdletModule -Module 152 -Category 'Network' -Title '152. Listening UDP Endpoints' -CommandName 'Get-NetUDPEndpoint' -Query { Get-NetUDPEndpoint -ErrorAction SilentlyContinue | Sort-Object LocalPort } -Properties @('LocalAddress','LocalPort','OwningProcess','CreationTime') -Recommendation 'UDP endpoints are reported for visibility only.' }
        153 { Invoke-GenericCmdletModule -Module 153 -Category 'SMB' -Title '153. SMB Client Configuration' -CommandName 'Get-SmbClientConfiguration' -Query { Get-SmbClientConfiguration } -Properties @('EnableSecuritySignature','RequireSecuritySignature','EnableInsecureGuestLogons','EnableMultiChannel','DirectoryCacheLifetime','FileInfoCacheLifetime') -Recommendation 'SMB client policy may be organization-managed.' }
        154 { Invoke-GenericCmdletModule -Module 154 -Category 'SMB' -Title '154. SMB Server Configuration' -CommandName 'Get-SmbServerConfiguration' -Query { Get-SmbServerConfiguration } -Properties @('EnableSMB1Protocol','EnableSMB2Protocol','EnableSecuritySignature','RequireSecuritySignature','EncryptData','EnableMultiChannel') -Recommendation 'SMB server changes can affect file sharing and domain workflows.' }
        155 { Invoke-GenericRegistryModule -Module 155 -Category 'DNS' -Title '155. LLMNR Policy' -Checks @(@{Item='LLMNR policy';Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient';Names=@('EnableMulticast')}) -Recommendation 'LLMNR policy is security-sensitive and may be centrally managed.' }
        156 { Invoke-GenericCmdletModule -Module 156 -Category 'NetBIOS' -Title '156. NetBIOS over TCP/IP State' -CommandName 'Get-CimInstance' -Query { Get-CimInstance Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=True' -ErrorAction SilentlyContinue } -Properties @('Description','MACAddress','DHCPEnabled','TcpipNetbiosOptions','DefaultIPGateway','DNSServerSearchOrder') -Recommendation 'NetBIOS settings can affect legacy name resolution and file-sharing compatibility.' }
        157 { Invoke-GenericServiceModule -Module 157 -Category 'Network' -Title '157. Internet Connection Sharing Status' -Services @('SharedAccess') -Recommendation 'Internet Connection Sharing may be intentional for lab/mobile-hotspot scenarios.' }
        158 { Invoke-GenericServiceModule -Module 158 -Category 'Network' -Title '158. Mobile Hotspot Service Status' -Services @('icssvc') -Recommendation 'Mobile Hotspot service state is reported only.' }
        159 { Invoke-GenericServiceModule -Module 159 -Category 'Network' -Title '159. Network Location Awareness Health' -Services @('NlaSvc') -Recommendation 'NLA affects network profile detection; do not disable it casually.' }
        160 { Invoke-GenericRegistryModule -Module 160 -Category 'NetworkPolicy' -Title '160. Windows Connection Manager Policy' -Checks @(@{Item='WCM policy';Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\WcmSvc\GroupPolicy';Names=@('fMinimizeConnections','fSoftDisconnectConnections','fBlockNonDomain','fBlockNonDomainPolicy')}) -Recommendation 'Connection Manager policy may be enterprise-managed.' }
        161 { Invoke-GenericRegistryModule -Module 161 -Category 'SecurityPolicy' -Title '161. User Account Control (UAC) Configuration' -Checks @(@{Item='UAC';Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System';Names=@('EnableLUA','ConsentPromptBehaviorAdmin','ConsentPromptBehaviorUser','PromptOnSecureDesktop','FilterAdministratorToken','EnableVirtualization')}) -Recommendation 'UAC is a core Windows security boundary; report-only.' }
        162 { Invoke-GenericRegistryModule -Module 162 -Category 'WindowsHello' -Title '162. Windows Hello Policy' -Checks @(@{Item='Passport for Work';Path='HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork';Names=@('Enabled','DisablePostLogonProvisioning','UseCertificateForOnPremAuth')}) -Recommendation 'Windows Hello policy may be MDM/domain-managed.' }
        163 { Invoke-GenericCommandModule -Module 163 -Category 'Accounts' -Title '163. Local Password Policy' -Item 'net accounts policy' -Command 'net.exe' -Arguments @('accounts') -Recommendation 'Password policy should be interpreted alongside domain/Entra/MDM controls.' }
        164 { Invoke-GenericCommandModule -Module 164 -Category 'Accounts' -Title '164. Account Lockout Policy' -Item 'Account lockout settings' -Command 'net.exe' -Arguments @('accounts') -Recommendation 'Lockout policy may be overridden by domain or cloud identity policy.' }
        165 { Write-Title '165. Built-in Guest Account Status'; $local=New-Object System.Collections.ArrayList; try{ if(Test-CommandAvailable 'Get-LocalUser'){ $u=Get-LocalUser -Name 'Guest' -ErrorAction Stop; [void]$local.Add((Add-Result 165 'Accounts' 'Guest' $(if($u.Enabled){'Review'}else{'Disabled'}) (ConvertTo-DetoxDetailString $u @('Name','Enabled','LastLogon','PasswordRequired','UserMayChangePassword','SID')) 'The built-in Guest account is normally disabled.')) } else {[void]$local.Add((Add-Result 165 'Accounts' 'Guest' 'Unavailable' 'Get-LocalUser is unavailable.' 'Review local accounts manually.'))} }catch{[void]$local.Add((Add-Result 165 'Accounts' 'Guest' 'Not found' $_.Exception.Message 'No change made.'))}; Show-ResultTable $local 'Built-in Guest account'; return $local }
        166 { Write-Title '166. Built-in Administrator Account Status'; $local=New-Object System.Collections.ArrayList; try{ if(Test-CommandAvailable 'Get-LocalUser'){ $u=Get-LocalUser -ErrorAction Stop | Where-Object {$_.SID.Value -match '-500$'} | Select-Object -First 1; if($u){[void]$local.Add((Add-Result 166 'Accounts' $u.Name $(if($u.Enabled){'Review'}else{'Disabled'}) (ConvertTo-DetoxDetailString $u @('Name','Enabled','LastLogon','PasswordRequired','SID')) 'Built-in Administrator status is security-sensitive; report-only.'))} } }catch{[void]$local.Add((Add-Result 166 'Accounts' 'Administrator' 'Error' $_.Exception.Message 'Review local accounts manually.'))}; if($local.Count -eq 0){[void]$local.Add((Add-Result 166 'Accounts' 'Administrator' 'No data' 'Built-in Administrator account could not be resolved.' 'No change made.'))}; Show-ResultTable $local 'Built-in Administrator account'; return $local }
        167 { Invoke-GenericRegistryModule -Module 167 -Category 'Accounts' -Title '167. AutoLogon Configuration' -Checks @(@{Item='Winlogon AutoLogon';Path='HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon';Names=@('AutoAdminLogon','DefaultUserName','DefaultDomainName')}) -Recommendation 'Automatic logon can weaken physical-access security. Password values are intentionally not read.' }
        168 { Invoke-GenericRegistryModule -Module 168 -Category 'Accounts' -Title '168. Cached Interactive Logons Policy' -Checks @(@{Item='Cached logons';Path='HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon';Names=@('CachedLogonsCount')}) -Recommendation 'Cached logon behavior matters for offline domain sign-in and credential exposure.' }
        169 { Invoke-GenericCommandModule -Module 169 -Category 'AuditPolicy' -Title '169. Advanced Audit Policy Summary' -Item 'Audit policy' -Command 'auditpol.exe' -Arguments @('/get','/category:*') -Recommendation 'Audit policy may be domain-managed; report-only.' }
        170 { Invoke-GenericRegistryModule -Module 170 -Category 'PowerShellSecurity' -Title '170. PowerShell Script Block Logging' -Checks @(@{Item='Script Block Logging';Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging';Names=@('EnableScriptBlockLogging','EnableScriptBlockInvocationLogging')}) -Recommendation 'Script Block Logging improves PowerShell audit visibility but may increase log volume.' }
        171 { Invoke-GenericRegistryModule -Module 171 -Category 'PowerShellSecurity' -Title '171. PowerShell Transcription Logging' -Checks @(@{Item='Transcription';Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription';Names=@('EnableTranscripting','EnableInvocationHeader','OutputDirectory')}) -Recommendation 'Transcription can capture sensitive command output; protect transcript locations appropriately.' }
        172 { Invoke-GenericRegistryModule -Module 172 -Category 'PowerShellSecurity' -Title '172. PowerShell Module Logging' -Checks @(@{Item='Module Logging';Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging';Names=@('EnableModuleLogging')}) -Recommendation 'Module logging is reported only.' }
        173 { Write-Title '173. AppLocker Policy Status'; $local=New-Object System.Collections.ArrayList; if(Test-CommandAvailable 'Get-AppLockerPolicy'){try{$p=Get-AppLockerPolicy -Effective -ErrorAction Stop; foreach($c in $p.RuleCollections){[void]$local.Add((Add-Result 173 'AppLocker' $c.RuleCollectionType ([string]$c.EnforcementMode) ("Rules={0} | Enforcement={1}" -f $c.Count,$c.EnforcementMode) 'AppLocker policy is report-only.'))}}catch{[void]$local.Add((Add-Result 173 'AppLocker' 'Effective policy' 'Error' $_.Exception.Message 'No policy changes made.'))}}else{[void]$local.Add((Add-Result 173 'AppLocker' 'Get-AppLockerPolicy' 'Unavailable' 'Cmdlet unavailable.' 'Edition or RSAT components may affect availability.'))}; Show-ResultTable $local 'AppLocker policy'; return $local }
        174 { Invoke-GenericCmdletModule -Module 174 -Category 'CodeIntegrity' -Title '174. WDAC / Code Integrity Policy State' -CommandName 'Get-CimInstance' -Query { Get-CimInstance -Namespace 'root\Microsoft\Windows\DeviceGuard' -ClassName Win32_DeviceGuard -ErrorAction SilentlyContinue } -Properties @('VirtualizationBasedSecurityStatus','CodeIntegrityPolicyEnforcementStatus','UsermodeCodeIntegrityPolicyEnforcementStatus','SecurityServicesConfigured','SecurityServicesRunning') -Recommendation 'WDAC/Code Integrity policies are security-critical and report-only.' }
        175 { Invoke-GenericFeatureModule -Module 175 -Category 'Sandbox' -Title '175. Windows Sandbox Feature' -Features @('Containers-DisposableClientVM') -Recommendation 'Windows Sandbox availability depends on edition and virtualization support.' }
        176 { Invoke-GenericFeatureModule -Module 176 -Category 'ApplicationGuard' -Title '176. Microsoft Defender Application Guard' -Features @('Windows-Defender-ApplicationGuard') -Recommendation 'Application Guard availability depends on Windows edition/build.' }
        177 { Invoke-GenericRegistryModule -Module 177 -Category 'RemoteAccess' -Title '177. Remote Assistance Status' -Checks @(@{Item='Remote Assistance';Path='HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance';Names=@('fAllowToGetHelp','fAllowFullControl')}) -Recommendation 'Remote Assistance increases remote-support capability; verify organizational need.' }
        178 { Invoke-GenericServiceModule -Module 178 -Category 'RemoteAccess' -Title '178. OpenSSH Server Status' -Services @('sshd') -Recommendation 'An SSH server may expose remote administration; verify firewall and authentication policy.' }
        179 { Invoke-GenericServiceModule -Module 179 -Category 'RemoteAccess' -Title '179. Remote Registry Status' -Services @('RemoteRegistry') -Recommendation 'Remote Registry is commonly disabled on clients unless administration requires it.' }
        180 { Write-Title '180. Credential Manager Target Count'; $local=New-Object System.Collections.ArrayList; try{$raw=(& cmdkey.exe /list 2>&1 | Out-String); $count=([regex]::Matches($raw,'(?im)^\s*Target:')).Count; [void]$local.Add((Add-Result 180 'Credentials' 'Credential Manager' 'Info' ("Stored credential targets: {0}" -f $count) 'Target names and secrets are intentionally not displayed by this module.'))}catch{[void]$local.Add((Add-Result 180 'Credentials' 'Credential Manager' 'Error' $_.Exception.Message 'No credentials were changed.'))}; Show-ResultTable $local 'Credential Manager target count'; return $local }
        181 { Invoke-GenericRegistryModule -Module 181 -Category 'NTLM' -Title '181. NTLM Restriction Policy' -Checks @(@{Item='NTLM policy';Path='HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0';Names=@('RestrictSendingNTLMTraffic','RestrictReceivingNTLMTraffic','AuditReceivingNTLMTraffic','AuditOutgoingNTLMTraffic')}) -Recommendation 'NTLM restrictions can affect legacy authentication; report-only.' }
        182 { Invoke-GenericRegistryModule -Module 182 -Category 'NTLM' -Title '182. LAN Manager Authentication Level' -Checks @(@{Item='LmCompatibilityLevel';Path='HKLM:\SYSTEM\CurrentControlSet\Control\Lsa';Names=@('LmCompatibilityLevel')}) -Recommendation 'LAN Manager authentication level affects NTLM compatibility and security.' }
        183 { Invoke-GenericRegistryModule -Module 183 -Category 'SMB' -Title '183. SMB Guest Logon Policy' -Checks @(@{Item='Insecure guest logons';Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation';Names=@('AllowInsecureGuestAuth')}) -Recommendation 'Insecure SMB guest logons reduce authentication protections.' }
        184 { Invoke-GenericRegistryModule -Module 184 -Category 'SecurityPolicy' -Title '184. Anonymous Access Restrictions' -Checks @(@{Item='Anonymous access';Path='HKLM:\SYSTEM\CurrentControlSet\Control\Lsa';Names=@('RestrictAnonymous','RestrictAnonymousSAM','EveryoneIncludesAnonymous')}) -Recommendation 'Anonymous access controls may affect legacy applications and file sharing.' }
        185 { Invoke-GenericRegistryModule -Module 185 -Category 'AutoPlay' -Title '185. AutoRun / AutoPlay Policy' -Checks @(@{Item='Explorer AutoRun policy';Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer';Names=@('NoDriveTypeAutoRun','NoAutorun')},@{Item='User AutoRun policy';Path='HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer';Names=@('NoDriveTypeAutoRun','NoAutorun')}) -Recommendation 'AutoRun policy is security-relevant for removable media.' }
        186 { Invoke-GenericRegistryModule -Module 186 -Category 'DevicePolicy' -Title '186. Removable Storage Policy' -Checks @(@{Item='Removable storage policy';Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\RemovableStorageDevices';Names=@('Deny_All')}) -Recommendation 'Removable-storage restrictions may be enterprise-managed.' }
        187 { Invoke-GenericRegistryModule -Module 187 -Category 'DevicePolicy' -Title '187. Device Installation Restriction Policy' -Checks @(@{Item='Device installation restrictions';Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions';Names=@('DenyDeviceIDs','DenyDeviceClasses','DenyUnspecified','AllowAdminInstall')}) -Recommendation 'Device-installation policy can block drivers/peripherals; report-only.' }
        188 { Invoke-GenericRegistryModule -Module 188 -Category 'SecurityPolicy' -Title '188. Windows Security Options Snapshot' -Checks @(@{Item='System security options';Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System';Names=@('DontDisplayLastUserName','DisableCAD','InactivityTimeoutSecs','LegalNoticeCaption')},@{Item='LSA options';Path='HKLM:\SYSTEM\CurrentControlSet\Control\Lsa';Names=@('NoLMHash','LimitBlankPasswordUse','RestrictAnonymousSAM')}) -Recommendation 'Security Options should be interpreted against your organization baseline.' }
        189 { Write-Title '189. Local Privileged Group Membership Review'; $local=New-Object System.Collections.ArrayList; if(Test-CommandAvailable 'Get-LocalGroupMember'){ foreach($g in @('Administrators','Remote Desktop Users')){try{foreach($m in @(Get-LocalGroupMember -Group $g -ErrorAction Stop)){ [void]$local.Add((Add-Result 189 'Accounts' $g 'Review' ("Member={0} | Type={1} | Source={2}" -f $m.Name,$m.ObjectClass,$m.PrincipalSource) 'Privileged group membership should be explicitly justified.')) }}catch{[void]$local.Add((Add-Result 189 'Accounts' $g 'Unavailable' $_.Exception.Message 'Group name may be localized or cmdlet unavailable.'))}} } else {[void]$local.Add((Add-Result 189 'Accounts' 'Local groups' 'Unavailable' 'Get-LocalGroupMember is unavailable.' 'Review local groups manually.'))}; Show-ResultTable $local 'Privileged local groups'; return $local }
        190 { Write-Title '190. User Rights Assignment Snapshot'; $local=New-Object System.Collections.ArrayList; $tmp=Join-Path $env:TEMP ("detox_secpol_{0}.inf" -f ([guid]::NewGuid().ToString('N'))); try{& secedit.exe /export /cfg $tmp /areas USER_RIGHTS /quiet | Out-Null; if(Test-Path -LiteralPath $tmp){foreach($line in @(Get-Content -LiteralPath $tmp -ErrorAction SilentlyContinue | Where-Object {$_ -match '^Se[^=]+='} | Select-Object -First 80)){ $parts=$line -split '=',2; [void]$local.Add((Add-Result 190 'UserRights' $parts[0].Trim() 'Info' $parts[1].Trim() 'User-right assignments are report-only and may be domain-managed.')) }}}catch{[void]$local.Add((Add-Result 190 'UserRights' 'secedit export' 'Error' $_.Exception.Message 'No policy changes made.'))}finally{try { [System.IO.File]::Delete($tmp) } catch {}}; if($local.Count -eq 0){[void]$local.Add((Add-Result 190 'UserRights' 'User rights' 'No data' 'No user-right assignment lines were exported.' 'No action required.'))}; Show-ResultTable $local 'User rights assignment'; return $local }
        191 { Invoke-GenericServiceModule -Module 191 -Category 'Diagnostics' -Title '191. Windows Event Log Service Health' -Services @('EventLog') -Recommendation 'The Windows Event Log service is core OS infrastructure.' }
        192 { Invoke-GenericRegistryModule -Module 192 -Category 'WER' -Title '192. Windows Error Reporting Policy' -Checks @(@{Item='WER policy';Path='HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting';Names=@('Disabled','DontSendAdditionalData','LoggingDisabled','ForceQueue')},@{Item='WER user policy';Path='HKCU:\SOFTWARE\Microsoft\Windows\Windows Error Reporting';Names=@('Disabled','DontShowUI')}) -Recommendation 'WER settings affect diagnostic data and crash troubleshooting.' }
        193 { Invoke-GenericRegistryModule -Module 193 -Category 'CrashControl' -Title '193. Kernel Crash Dump Configuration' -Checks @(@{Item='CrashControl';Path='HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl';Names=@('CrashDumpEnabled','DumpFile','MinidumpDir','AutoReboot','LogEvent','Overwrite','AlwaysKeepMemoryDump')}) -Recommendation 'Crash dump settings are essential for kernel debugging and incident response.' }
        194 { Invoke-GenericEventModule -Module 194 -Category 'MemoryDiagnostics' -Title '194. Windows Memory Diagnostic Results' -LogName 'System' -ProviderName 'Microsoft-Windows-MemoryDiagnostics-Results' -Days 365 -MaxEvents 30 -Recommendation 'Memory diagnostic failures can indicate RAM or platform instability.' }
        195 { Invoke-GenericFolderModule -Module 195 -Category 'KernelReports' -Title '195. LiveKernelReports Footprint' -Targets @(@{Item='LiveKernelReports';Path='%WINDIR%\LiveKernelReports'}) -Recommendation 'Live kernel dumps are useful for GPU/driver/hardware troubleshooting; report-only.' }
        196 { Invoke-GenericCmdletModule -Module 196 -Category 'Reliability' -Title '196. Reliability Critical Event Summary' -CommandName 'Get-CimInstance' -Query { Get-CimInstance Win32_ReliabilityRecords -ErrorAction SilentlyContinue | Where-Object {$_.TimeGenerated -gt (Get-Date).AddDays(-30)} | Sort-Object TimeGenerated -Descending | Select-Object -First 80 } -Properties @('TimeGenerated','SourceName','ProductName','EventIdentifier','Message') -Recommendation 'Use recurring reliability events to prioritize root-cause analysis.' }
        197 { Invoke-GenericEventModule -Module 197 -Category 'DiskCheck' -Title '197. Last Disk Check Results' -LogName 'Application' -ProviderName 'Microsoft-Windows-Wininit' -Ids @(1001) -Days 365 -MaxEvents 20 -Recommendation 'CHKDSK results can reveal file-system repairs or disk-related problems.' }
        198 { Invoke-GenericEventModule -Module 198 -Category 'Defender' -Title '198. Microsoft Defender Operational Event Summary' -LogName 'Microsoft-Windows-Windows Defender/Operational' -Days 30 -MaxEvents 60 -Recommendation 'Review Defender warnings/detections with security context; this module does not remediate threats.' }
        199 { Invoke-GenericEventModule -Module 199 -Category 'Firewall' -Title '199. Windows Firewall Operational Event Summary' -LogName 'Microsoft-Windows-Windows Firewall With Advanced Security/Firewall' -Days 30 -MaxEvents 60 -Recommendation 'Firewall events are reported for troubleshooting and security visibility.' }
        200 { Invoke-GenericEventModule -Module 200 -Category 'WindowsUpdate' -Title '200. Windows Update Operational Event Summary' -LogName 'Microsoft-Windows-WindowsUpdateClient/Operational' -Days 30 -MaxEvents 60 -Recommendation 'Use Windows Update operational events to correlate update failures and restarts.' }
        default { throw "Unknown extended module number: $ModuleNumber" }
    }
}


# ---------------------------------------------------------------------------
# v2.1 Windows 11 Deep Extension Layer (201-300)
# All modules in this layer are REPORT-ONLY.
# ---------------------------------------------------------------------------
function Invoke-ExtendedModuleV21 {
    param([Parameter(Mandatory)][int]$ModuleNumber)

    switch($ModuleNumber) {
        # -------------------------------------------------------------------
        # Certificates & Trust (201-210)
        # -------------------------------------------------------------------
        201 { Invoke-GenericCmdletModule -Module 201 -Category 'Certificates' -Title '201. Local Machine Root CA Store' -CommandName 'Get-ChildItem' -Query { Get-ChildItem -Path 'Cert:\LocalMachine\Root' -ErrorAction SilentlyContinue | Sort-Object NotAfter } -Properties @('Subject','Issuer','NotBefore','NotAfter','Thumbprint','HasPrivateKey') -Recommendation 'Trusted root certificates affect system-wide trust. Review unexpected roots before any trust-store change.' }
        202 { Invoke-GenericCmdletModule -Module 202 -Category 'Certificates' -Title '202. Local Machine Personal Certificates' -CommandName 'Get-ChildItem' -Query { Get-ChildItem -Path 'Cert:\LocalMachine\My' -ErrorAction SilentlyContinue | Sort-Object NotAfter } -Properties @('Subject','Issuer','NotBefore','NotAfter','Thumbprint','HasPrivateKey') -Recommendation 'Machine personal certificates may be required by services, VPN, Wi-Fi, TLS or enterprise management.' }
        203 { Invoke-GenericCmdletModule -Module 203 -Category 'Certificates' -Title '203. Current User Personal Certificates' -CommandName 'Get-ChildItem' -Query { Get-ChildItem -Path 'Cert:\CurrentUser\My' -ErrorAction SilentlyContinue | Sort-Object NotAfter } -Properties @('Subject','Issuer','NotBefore','NotAfter','Thumbprint','HasPrivateKey') -Recommendation 'User certificates can be required for authentication, encryption and signing.' }
        204 { Invoke-GenericCmdletModule -Module 204 -Category 'Certificates' -Title '204. Expired Machine Certificates' -CommandName 'Get-ChildItem' -Query { Get-ChildItem -Path 'Cert:\LocalMachine' -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.NotAfter -and $_.NotAfter -lt (Get-Date) } | Sort-Object NotAfter | Select-Object -First 120 } -Properties @('Subject','Issuer','NotAfter','Thumbprint','PSParentPath') -Recommendation 'Expired certificates may remain for historical validation or application compatibility. Review ownership before removal.' }
        205 { Invoke-GenericCmdletModule -Module 205 -Category 'Certificates' -Title '205. Untrusted Certificate Store' -CommandName 'Get-ChildItem' -Query { Get-ChildItem -Path 'Cert:\LocalMachine\Disallowed' -ErrorAction SilentlyContinue } -Properties @('Subject','Issuer','NotAfter','Thumbprint') -Recommendation 'The Disallowed store explicitly blocks certificates and should normally be managed by Windows or policy.' }
        206 { Invoke-GenericCmdletModule -Module 206 -Category 'Certificates' -Title '206. Code Signing Certificate Inventory' -CommandName 'Get-ChildItem' -Query { @(Get-ChildItem -Path 'Cert:\CurrentUser\My','Cert:\LocalMachine\My' -ErrorAction SilentlyContinue) | Where-Object { $_.EnhancedKeyUsageList.ObjectId.Value -contains '1.3.6.1.5.5.7.3.3' } } -Properties @('Subject','Issuer','NotAfter','Thumbprint','HasPrivateKey') -Recommendation 'Code-signing certificates with private keys are security-sensitive. This module never exports private key material.' }
        207 { Invoke-GenericCmdletModule -Module 207 -Category 'Certificates' -Title '207. Trusted Publishers Store' -CommandName 'Get-ChildItem' -Query { Get-ChildItem -Path 'Cert:\LocalMachine\TrustedPublisher' -ErrorAction SilentlyContinue | Sort-Object NotAfter } -Properties @('Subject','Issuer','NotAfter','Thumbprint') -Recommendation 'Trusted Publisher certificates can influence software trust decisions.' }
        208 { Invoke-GenericCmdletModule -Module 208 -Category 'Certificates' -Title '208. Enterprise Trust Store' -CommandName 'Get-ChildItem' -Query { Get-ChildItem -Path 'Cert:\LocalMachine\Trust' -ErrorAction SilentlyContinue | Sort-Object NotAfter } -Properties @('Subject','Issuer','NotAfter','Thumbprint') -Recommendation 'Enterprise trust entries are frequently managed by Active Directory or device management.' }
        209 { Invoke-GenericRegistryModule -Module 209 -Category 'Certificates' -Title '209. Certificate Auto-Enrollment Policy' -Checks @(@{Item='Machine auto-enrollment';Path='HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\AutoEnrollment';Names=@('AEPolicy','OfflineExpirationPercent','OfflineExpirationStoreNames')},@{Item='User auto-enrollment';Path='HKCU:\SOFTWARE\Policies\Microsoft\Cryptography\AutoEnrollment';Names=@('AEPolicy','OfflineExpirationPercent')}) -Recommendation 'Certificate auto-enrollment policy is often domain or MDM managed.' }
        210 { Invoke-GenericServiceModule -Module 210 -Category 'Certificates' -Title '210. Cryptographic Services Health' -Services @('CryptSvc') -Recommendation 'Cryptographic Services supports certificates, signatures and Windows servicing.' }

        # -------------------------------------------------------------------
        # Defender Advanced Security (211-220)
        # -------------------------------------------------------------------
        211 { Invoke-GenericCmdletModule -Module 211 -Category 'DefenderAdvanced' -Title '211. Defender Network Protection' -CommandName 'Get-MpPreference' -Query { Get-MpPreference -ErrorAction SilentlyContinue | Select-Object EnableNetworkProtection } -Properties @('EnableNetworkProtection') -Recommendation 'Network Protection helps block connections to malicious or low-reputation destinations.' }
        212 { Invoke-GenericCmdletModule -Module 212 -Category 'DefenderAdvanced' -Title '212. Defender PUA Protection' -CommandName 'Get-MpPreference' -Query { Get-MpPreference -ErrorAction SilentlyContinue | Select-Object PUAProtection } -Properties @('PUAProtection') -Recommendation 'Potentially unwanted application protection can reduce unwanted software exposure.' }
        213 { Invoke-GenericCmdletModule -Module 213 -Category 'DefenderAdvanced' -Title '213. Defender Cloud Protection' -CommandName 'Get-MpPreference' -Query { Get-MpPreference -ErrorAction SilentlyContinue | Select-Object MAPSReporting,CloudBlockLevel,CloudExtendedTimeout } -Properties @('MAPSReporting','CloudBlockLevel','CloudExtendedTimeout') -Recommendation 'Cloud-delivered protection improves reputation and rapid-response detection when permitted by policy.' }
        214 { Invoke-GenericCmdletModule -Module 214 -Category 'DefenderAdvanced' -Title '214. Defender Sample Submission Policy' -CommandName 'Get-MpPreference' -Query { Get-MpPreference -ErrorAction SilentlyContinue | Select-Object SubmitSamplesConsent } -Properties @('SubmitSamplesConsent') -Recommendation 'Sample submission settings affect Defender cloud analysis and organizational privacy requirements.' }
        215 { Invoke-GenericCmdletModule -Module 215 -Category 'DefenderAdvanced' -Title '215. Defender Scan Schedule' -CommandName 'Get-MpPreference' -Query { Get-MpPreference -ErrorAction SilentlyContinue | Select-Object ScanScheduleDay,ScanScheduleTime,ScanParameters,RandomizeScheduleTaskTimes,DisableCatchupFullScan,DisableCatchupQuickScan } -Properties @('ScanScheduleDay','ScanScheduleTime','ScanParameters','RandomizeScheduleTaskTimes','DisableCatchupFullScan','DisableCatchupQuickScan') -Recommendation 'Scheduled scan configuration should match endpoint-management policy and device usage.' }
        216 { Invoke-GenericCmdletModule -Module 216 -Category 'DefenderAdvanced' -Title '216. Defender Scan CPU Limit' -CommandName 'Get-MpPreference' -Query { Get-MpPreference -ErrorAction SilentlyContinue | Select-Object ScanAvgCPULoadFactor,EnableLowCpuPriority } -Properties @('ScanAvgCPULoadFactor','EnableLowCpuPriority') -Recommendation 'Scan CPU settings affect performance and scan completion time.' }
        217 { Invoke-GenericCmdletModule -Module 217 -Category 'DefenderAdvanced' -Title '217. Defender Exclusion Extensions' -CommandName 'Get-MpPreference' -Query { $p=Get-MpPreference -ErrorAction SilentlyContinue; foreach($x in @($p.ExclusionExtension)){ [pscustomobject]@{Name=$x;Type='Extension'} } } -Properties @('Name','Type') -Recommendation 'Broad extension exclusions reduce malware scanning coverage. Validate every exclusion against a documented requirement.' }
        218 { Invoke-GenericCmdletModule -Module 218 -Category 'DefenderAdvanced' -Title '218. Defender Exclusion Processes' -CommandName 'Get-MpPreference' -Query { $p=Get-MpPreference -ErrorAction SilentlyContinue; foreach($x in @($p.ExclusionProcess)){ [pscustomobject]@{Name=$x;Type='Process'} } } -Properties @('Name','Type') -Recommendation 'Process exclusions can materially reduce Defender inspection coverage.' }
        219 { Invoke-GenericCmdletModule -Module 219 -Category 'DefenderAdvanced' -Title '219. Controlled Folder Access Protected Folders' -CommandName 'Get-MpPreference' -Query { $p=Get-MpPreference -ErrorAction SilentlyContinue; foreach($x in @($p.ControlledFolderAccessProtectedFolders)){ [pscustomobject]@{Name=$x;Type='ProtectedFolder'} } } -Properties @('Name','Type') -Recommendation 'Protected folders are ransomware-protection scope. Review only.' }
        220 { Invoke-GenericCmdletModule -Module 220 -Category 'DefenderAdvanced' -Title '220. Defender Quarantine and Retention Settings' -CommandName 'Get-MpPreference' -Query { Get-MpPreference -ErrorAction SilentlyContinue | Select-Object QuarantinePurgeItemsAfterDelay,RemediationScheduleDay,RemediationScheduleTime } -Properties @('QuarantinePurgeItemsAfterDelay','RemediationScheduleDay','RemediationScheduleTime') -Recommendation 'Quarantine retention should balance investigation requirements and storage usage.' }

        # -------------------------------------------------------------------
        # Device Security & Driver Integrity (221-230)
        # -------------------------------------------------------------------
        221 { Invoke-GenericCommandModule -Module 221 -Category 'DriverSecurity' -Title '221. Boot Integrity Flags' -Item 'Current BCD integrity flags' -Command 'bcdedit.exe' -Arguments @('/enum','{current}') -Recommendation 'Review testsigning, nointegritychecks and debug-related BCD settings. No BCD value is changed.' }
        222 { Invoke-GenericRegistryModule -Module 222 -Category 'DriverSecurity' -Title '222. Kernel Driver Blocklist Policy' -Checks @(@{Item='Vulnerable driver blocklist';Path='HKLM:\SYSTEM\CurrentControlSet\Control\CI\Config';Names=@('VulnerableDriverBlocklistEnable')}) -Recommendation 'The Microsoft vulnerable driver blocklist is part of Windows kernel security posture.' }
        223 { Invoke-GenericCmdletModule -Module 223 -Category 'DeviceGuard' -Title '223. Device Guard Security Properties' -CommandName 'Get-CimInstance' -Query { Get-CimInstance -Namespace 'root\Microsoft\Windows\DeviceGuard' -ClassName Win32_DeviceGuard -ErrorAction SilentlyContinue } -Properties @('AvailableSecurityProperties','RequiredSecurityProperties','SecurityServicesConfigured','SecurityServicesRunning','VirtualizationBasedSecurityStatus','CodeIntegrityPolicyEnforcementStatus','UsermodeCodeIntegrityPolicyEnforcementStatus') -Recommendation 'Device Guard properties summarize platform capabilities and active virtualization-based protections.' }
        224 { Invoke-GenericCmdletModule -Module 224 -Category 'DriverSecurity' -Title '224. Unsigned PnP Driver Inventory' -CommandName 'Get-CimInstance' -Query { Get-CimInstance Win32_PnPSignedDriver -ErrorAction SilentlyContinue | Where-Object { $_.IsSigned -eq $false } | Select-Object -First 120 } -Properties @('DeviceName','DriverProviderName','DriverVersion','DriverDate','InfName','IsSigned','Signer') -Recommendation 'Unsigned drivers can indicate legacy software, test drivers or security risk. Verify vendor and provenance.' }
        225 { Invoke-GenericCmdletModule -Module 225 -Category 'DriverSecurity' -Title '225. Problem PnP Devices' -CommandName 'Get-PnpDevice' -Query { Get-PnpDevice -ErrorAction SilentlyContinue | Where-Object { $_.Status -notin @('OK','Unknown') } | Select-Object -First 120 } -Properties @('Class','FriendlyName','InstanceId','Status') -Recommendation 'Problem devices can indicate driver, firmware, hardware or resource conflicts.' }
        226 { Invoke-GenericCommandModule -Module 226 -Category 'DriverSecurity' -Title '226. Driver Verifier Configuration' -Item 'Driver Verifier settings' -Command 'verifier.exe' -Arguments @('/querysettings') -Recommendation 'Driver Verifier can intentionally stress drivers and should only be enabled for troubleshooting.' }
        227 { Invoke-GenericCommandModule -Module 227 -Category 'DriverSecurity' -Title '227. Third-Party Driver Package Inventory' -Item 'PnP driver packages' -Command 'pnputil.exe' -Arguments @('/enum-drivers') -Recommendation 'Third-party driver packages should be removed only with supported PnP tooling after hardware ownership is confirmed.' }
        228 { Invoke-GenericRegistryModule -Module 228 -Category 'DriverSecurity' -Title '228. Driver Search and Update Policy' -Checks @(@{Item='Driver searching policy';Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching';Names=@('SearchOrderConfig','DontSearchWindowsUpdate')},@{Item='Windows Update driver policy';Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate';Names=@('ExcludeWUDriversInQualityUpdate')}) -Recommendation 'Driver update policy can be organization-managed and should be interpreted with endpoint-management settings.' }
        229 { Invoke-GenericCmdletModule -Module 229 -Category 'DriverSecurity' -Title '229. Kernel PnP Error Events' -CommandName 'Get-WinEvent' -Query { Get-WinEvent -FilterHashtable @{LogName='System';ProviderName='Microsoft-Windows-Kernel-PnP';StartTime=(Get-Date).AddDays(-30)} -ErrorAction SilentlyContinue | Where-Object {$_.Level -le 3} | Select-Object -First 80 } -Properties @('TimeCreated','Id','LevelDisplayName','ProviderName','Message') -Recommendation 'Recurring Kernel-PnP errors can indicate driver, firmware or hardware instability.' }
        230 { Invoke-GenericRegistryModule -Module 230 -Category 'DriverSecurity' -Title '230. Device Metadata Retrieval Policy' -Checks @(@{Item='Device metadata';Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata';Names=@('PreventDeviceMetadataFromNetwork')},@{Item='Device installation';Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata';Names=@('PreventDeviceMetadataFromNetwork')}) -Recommendation 'Device metadata policy controls network retrieval of device information and artwork.' }

        # -------------------------------------------------------------------
        # Group Policy & Enterprise Configuration (231-240)
        # -------------------------------------------------------------------
        231 { Invoke-GenericCommandModule -Module 231 -Category 'GroupPolicy' -Title '231. Applied Computer Group Policy Summary' -Item 'Computer policy result' -Command 'gpresult.exe' -Arguments @('/Scope','Computer','/R') -Recommendation 'Applied Group Policy is authoritative for many Windows settings. Report-only.' }
        232 { Invoke-GenericCommandModule -Module 232 -Category 'GroupPolicy' -Title '232. Applied User Group Policy Summary' -Item 'User policy result' -Command 'gpresult.exe' -Arguments @('/Scope','User','/R') -Recommendation 'Applied user policy can explain settings that differ from local registry defaults.' }
        233 { Invoke-GenericRegistryModule -Module 233 -Category 'EnterprisePolicy' -Title '233. Windows Update for Business Policy' -Checks @(@{Item='WUfB policy';Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate';Names=@('DeferFeatureUpdates','DeferFeatureUpdatesPeriodInDays','DeferQualityUpdates','DeferQualityUpdatesPeriodInDays','PauseFeatureUpdatesStartTime','PauseQualityUpdatesStartTime','ManagePreviewBuilds','BranchReadinessLevel')}) -Recommendation 'Windows Update for Business policy should be reviewed against organizational servicing rings.' }
        234 { Invoke-GenericRegistryModule -Module 234 -Category 'EnterprisePolicy' -Title '234. OneDrive Enterprise Policy' -Checks @(@{Item='OneDrive policy';Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive';Names=@('DisableFileSyncNGSC','FilesOnDemandEnabled','KFMSilentOptIn','KFMSilentOptInWithNotification','DisablePersonalSync')}) -Recommendation 'OneDrive policy may govern Known Folder Move, Files On-Demand and enterprise sync behavior.' }
        235 { Invoke-GenericRegistryModule -Module 235 -Category 'EnterprisePolicy' -Title '235. Microsoft Edge Policy Snapshot' -Checks @(@{Item='Edge machine policy';Path='HKLM:\SOFTWARE\Policies\Microsoft\Edge';Names=@('SmartScreenEnabled','PasswordManagerEnabled','BrowserSignin','SyncDisabled','ExtensionInstallBlocklist','ExtensionInstallAllowlist','HomepageLocation')}) -Recommendation 'Browser policies can be centrally managed and should not be changed without ownership confirmation.' }
        236 { Invoke-GenericRegistryModule -Module 236 -Category 'EnterprisePolicy' -Title '236. Defender Policy Registry Snapshot' -Checks @(@{Item='Defender policy';Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender';Names=@('DisableAntiSpyware','DisableAntiVirus','PUAProtection','DisableRealtimeMonitoring')},@{Item='Defender real-time policy';Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection';Names=@('DisableRealtimeMonitoring','DisableBehaviorMonitoring','DisableIOAVProtection','DisableOnAccessProtection')}) -Recommendation 'Local policy registry values may be overridden or managed by Defender for Endpoint, Intune or Group Policy.' }
        237 { Invoke-GenericRegistryModule -Module 237 -Category 'EnterprisePolicy' -Title '237. Windows Hello for Business Policy' -Checks @(@{Item='PassportForWork policy';Path='HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork';Names=@('Enabled','DisablePostLogonProvisioning','UseCertificateForOnPremAuth','RequireSecurityDevice')}) -Recommendation 'Windows Hello for Business policy is commonly enterprise-managed.' }
        238 { Invoke-GenericRegistryModule -Module 238 -Category 'EnterprisePolicy' -Title '238. Remote Desktop Group Policy' -Checks @(@{Item='Terminal Services policy';Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services';Names=@('fDenyTSConnections','UserAuthentication','SecurityLayer','MinEncryptionLevel','MaxIdleTime','MaxDisconnectionTime')}) -Recommendation 'Remote Desktop policy can affect remote administration and attack surface.' }
        239 { Invoke-GenericCmdletModule -Module 239 -Category 'EnterprisePolicy' -Title '239. MDM Enrollment Registry Inventory' -CommandName 'Get-ChildItem' -Query { Get-ChildItem -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Enrollments' -ErrorAction SilentlyContinue | Select-Object -First 80 } -Properties @('PSChildName','Name') -Recommendation 'Enrollment identifiers are reported without attempting to expose enrollment secrets or certificates.' }
        240 { Invoke-GenericRegistryModule -Module 240 -Category 'EnterprisePolicy' -Title '240. Windows PolicyManager Device Policy Snapshot' -Checks @(@{Item='PolicyManager current device';Path='HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device';Names=@()}) -Recommendation 'PolicyManager contains MDM-applied Windows policy state. This snapshot is informational and limited to top-level values.' }

        # -------------------------------------------------------------------
        # File System & Data Protection (241-250)
        # -------------------------------------------------------------------
        241 { Invoke-GenericRegistryModule -Module 241 -Category 'FileSystemPolicy' -Title '241. Win32 Long Path Support' -Checks @(@{Item='LongPathsEnabled';Path='HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem';Names=@('LongPathsEnabled')}) -Recommendation 'Long path support can affect application compatibility and modern development tools.' }
        242 { Invoke-GenericCommandModule -Module 242 -Category 'FileSystemPolicy' -Title '242. NTFS 8.3 Name Creation State' -Item '8dot3 name creation' -Command 'fsutil.exe' -Arguments @('behavior','query','Disable8dot3') -Recommendation '8.3 name creation affects legacy compatibility and file-system metadata behavior.' }
        243 { Invoke-GenericCommandModule -Module 243 -Category 'FileSystemPolicy' -Title '243. NTFS Last Access Timestamp Policy' -Item 'Last access timestamp policy' -Command 'fsutil.exe' -Arguments @('behavior','query','disablelastaccess') -Recommendation 'Last-access timestamp policy affects metadata writes and some forensic/legacy workflows.' }
        244 { Invoke-GenericCommandModule -Module 244 -Category 'FileSystemPolicy' -Title '244. NTFS Symlink Evaluation Policy' -Item 'Symbolic link evaluation' -Command 'fsutil.exe' -Arguments @('behavior','query','SymlinkEvaluation') -Recommendation 'Symlink evaluation policy affects local and remote symbolic-link behavior.' }
        245 { Invoke-GenericCommandModule -Module 245 -Category 'DataProtection' -Title '245. EFS Current User Certificate Status' -Item 'EFS certificate' -Command 'cipher.exe' -Arguments @('/Y') -Recommendation 'EFS certificate availability is critical before encrypted files are moved, recovered or accounts are retired.' }
        246 { Invoke-GenericServiceModule -Module 246 -Category 'DataProtection' -Title '246. File History Service Status' -Services @('fhsvc') -Recommendation 'File History may provide user-file recovery and should be reviewed before backup settings are changed.' }
        247 { Invoke-GenericServiceModule -Module 247 -Category 'DataProtection' -Title '247. Work Folders Service Status' -Services @('workfolderssvc') -Recommendation 'Work Folders can be enterprise-managed and may synchronize corporate data.' }
        248 { Invoke-GenericRegistryModule -Module 248 -Category 'DataProtection' -Title '248. Offline Files Configuration' -Checks @(@{Item='Offline Files policy';Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\NetCache';Names=@('Enabled','SilentForcedAutoReconnect','SlowLinkSpeed')}) -Recommendation 'Offline Files configuration can affect enterprise shares and disconnected work.' }
        249 { Invoke-GenericRegistryModule -Module 249 -Category 'DataProtection' -Title '249. System Restore Configuration' -Checks @(@{Item='System Restore policy';Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\SystemRestore';Names=@('DisableSR','DisableConfig')},@{Item='System Restore settings';Path='HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore';Names=@('RPSessionInterval','SystemRestorePointCreationFrequency')}) -Recommendation 'System Restore supports recovery from configuration changes. This module does not enable, disable or delete restore points.' }
        250 { Invoke-GenericEventModule -Module 250 -Category 'DataProtection' -Title '250. Windows Backup Operational Events' -LogName 'Microsoft-Windows-Backup' -Days 90 -MaxEvents 50 -Recommendation 'Backup events can reveal failed or incomplete Windows backup operations.' }

        # -------------------------------------------------------------------
        # Advanced Networking & Remote Access (251-260)
        # -------------------------------------------------------------------
        251 { Invoke-GenericCmdletModule -Module 251 -Category 'FirewallAdvanced' -Title '251. Windows Firewall Logging Configuration' -CommandName 'Get-NetFirewallProfile' -Query { Get-NetFirewallProfile -ErrorAction SilentlyContinue } -Properties @('Name','Enabled','LogFileName','LogMaxSizeKilobytes','LogAllowed','LogBlocked','LogIgnored') -Recommendation 'Firewall logging can support troubleshooting and incident response while consuming disk space.' }
        252 { Invoke-GenericCmdletModule -Module 252 -Category 'IPsec' -Title '252. IPsec Rule Inventory' -CommandName 'Get-NetIPsecRule' -Query { Get-NetIPsecRule -PolicyStore ActiveStore -ErrorAction SilentlyContinue | Select-Object -First 120 } -Properties @('DisplayName','Enabled','Profile','Direction','Action','PolicyStoreSourceType') -Recommendation 'IPsec rules can enforce authentication and encryption. Review before changing network security policy.' }
        253 { Invoke-GenericCmdletModule -Module 253 -Category 'IPsec' -Title '253. IPsec Main Mode Rule Inventory' -CommandName 'Get-NetIPsecMainModeRule' -Query { Get-NetIPsecMainModeRule -PolicyStore ActiveStore -ErrorAction SilentlyContinue | Select-Object -First 120 } -Properties @('DisplayName','Enabled','Profile','Phase1AuthSet','MainModeCryptoSet','PolicyStoreSourceType') -Recommendation 'Main Mode settings affect IPsec peer authentication and cryptography.' }
        254 { Invoke-GenericServiceModule -Module 254 -Category 'DNS' -Title '254. DNS Client Service Health' -Services @('Dnscache') -Recommendation 'The DNS Client service supports name resolution and DNS caching.' }
        255 { Invoke-GenericRegistryModule -Module 255 -Category 'Proxy' -Title '255. WPAD and Proxy Auto-Discovery Policy' -Checks @(@{Item='WinHTTP AutoProxy';Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp';Names=@('DisableWpad')},@{Item='User Internet Settings';Path='HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings';Names=@('AutoDetect','AutoConfigURL','ProxyEnable','ProxyServer')}) -Recommendation 'Proxy auto-discovery and PAC configuration should be reviewed in the context of enterprise network design.' }
        256 { Invoke-GenericCommandModule -Module 256 -Category 'HTTPsys' -Title '256. HTTP.sys URL Reservations' -Item 'HTTP URL ACLs' -Command 'netsh.exe' -Arguments @('http','show','urlacl') -Recommendation 'URL reservations can expose local HTTP listeners or support legitimate Windows/services.' }
        257 { Invoke-GenericCommandModule -Module 257 -Category 'HTTPsys' -Title '257. HTTP.sys SSL Certificate Bindings' -Item 'HTTP SSL bindings' -Command 'netsh.exe' -Arguments @('http','show','sslcert') -Recommendation 'SSL bindings associate ports/endpoints with certificates. Review unexpected bindings.' }
        258 { Invoke-GenericCommandModule -Module 258 -Category 'WinRM' -Title '258. WinRM Listener Inventory' -Item 'WinRM listeners' -Command 'winrm.cmd' -Arguments @('enumerate','winrm/config/listener') -Recommendation 'WinRM listeners enable remote management. Validate transport, addresses and authentication requirements.' }
        259 { Invoke-GenericCmdletModule -Module 259 -Category 'RDP' -Title '259. Remote Desktop Firewall Rules' -CommandName 'Get-NetFirewallRule' -Query { Get-NetFirewallRule -ErrorAction SilentlyContinue | Where-Object { $_.DisplayGroup -match 'Remote Desktop' } } -Properties @('DisplayName','Enabled','Direction','Action','Profile','PolicyStoreSourceType') -Recommendation 'Remote Desktop firewall rules should match intended remote-access exposure.' }
        260 { Invoke-GenericCommandModule -Module 260 -Category 'RDP' -Title '260. Terminal Session Inventory' -Item 'Terminal sessions' -Command 'qwinsta.exe' -Arguments @() -Recommendation 'Terminal session state is informational; this module does not disconnect users.' }

        # -------------------------------------------------------------------
        # Windows Apps & Runtime Components (261-270)
        # -------------------------------------------------------------------
        261 { Invoke-GenericCommandModule -Module 261 -Category 'Runtime' -Title '261. Installed .NET Runtimes' -Item '.NET runtimes' -Command 'dotnet.exe' -Arguments @('--list-runtimes') -Recommendation 'Multiple .NET runtime versions can be required by installed applications.' }
        262 { Invoke-GenericCommandModule -Module 262 -Category 'Runtime' -Title '262. Installed .NET SDKs' -Item '.NET SDKs' -Command 'dotnet.exe' -Arguments @('--list-sdks') -Recommendation 'Multiple SDK versions can be intentional for development and build compatibility.' }
        263 { Invoke-GenericCmdletModule -Module 263 -Category 'Runtime' -Title '263. Visual C++ Redistributable Inventory' -CommandName 'Get-ItemProperty' -Query { @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*') | ForEach-Object { Get-ItemProperty $_ -ErrorAction SilentlyContinue } | Where-Object { $_.DisplayName -match 'Microsoft Visual C\+\+' } | Sort-Object DisplayName } -Properties @('DisplayName','DisplayVersion','Publisher','InstallDate','InstallLocation') -Recommendation 'Visual C++ redistributables are shared application dependencies and should not be removed based only on age.' }
        264 { Invoke-GenericCmdletModule -Module 264 -Category 'Runtime' -Title '264. Microsoft Edge WebView2 Runtime Inventory' -CommandName 'Get-ItemProperty' -Query { @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*','HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*') | ForEach-Object { Get-ItemProperty $_ -ErrorAction SilentlyContinue } | Where-Object { $_.DisplayName -match 'WebView2' } | Sort-Object DisplayName } -Properties @('DisplayName','DisplayVersion','Publisher','InstallDate','InstallLocation') -Recommendation 'WebView2 is used by many Windows and third-party applications.' }
        265 { Invoke-GenericCmdletModule -Module 265 -Category 'Runtime' -Title '265. Installed PowerShell Editions' -CommandName 'Get-ChildItem' -Query { $rows=@(); $rows += [pscustomobject]@{Name='Windows PowerShell';Path="$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe";Version=$PSVersionTable.PSVersion.ToString()}; $pwsh=Get-Command pwsh.exe -ErrorAction SilentlyContinue; if($pwsh){$rows += [pscustomobject]@{Name='PowerShell';Path=$pwsh.Source;Version=((& $pwsh.Source -NoLogo -NoProfile -Command '$PSVersionTable.PSVersion.ToString()' 2>$null | Select-Object -First 1))}}; $rows } -Properties @('Name','Path','Version') -Recommendation 'Multiple PowerShell editions can coexist and serve different compatibility requirements.' }
        266 { Invoke-GenericCmdletModule -Module 266 -Category 'Runtime' -Title '266. Windows Terminal Package Status' -CommandName 'Get-AppxPackage' -Query { Get-AppxPackage -Name 'Microsoft.WindowsTerminal' -ErrorAction SilentlyContinue } -Properties @('Name','Version','Publisher','InstallLocation','Status') -Recommendation 'Windows Terminal package state is informational.' }
        267 { Invoke-GenericCommandModule -Module 267 -Category 'Runtime' -Title '267. Windows Package Manager Version' -Item 'winget' -Command 'winget.exe' -Arguments @('--version') -Recommendation 'Windows Package Manager availability can support supported application lifecycle management.' }
        268 { Invoke-GenericCmdletModule -Module 268 -Category 'Runtime' -Title '268. OpenSSH Client Capability' -CommandName 'Get-WindowsCapability' -Query { Get-WindowsCapability -Online -Name 'OpenSSH.Client*' -ErrorAction SilentlyContinue } -Properties @('Name','State','DisplayName','Description') -Recommendation 'OpenSSH Client is a Windows capability and may be required for administration or development.' }
        269 { Invoke-GenericCmdletModule -Module 269 -Category 'Runtime' -Title '269. OpenSSH Server Capability' -CommandName 'Get-WindowsCapability' -Query { Get-WindowsCapability -Online -Name 'OpenSSH.Server*' -ErrorAction SilentlyContinue } -Properties @('Name','State','DisplayName','Description') -Recommendation 'OpenSSH Server increases remote-access capability and should be enabled only when needed.' }
        270 { Invoke-GenericCmdletModule -Module 270 -Category 'Runtime' -Title '270. App Installer Package Health' -CommandName 'Get-AppxPackage' -Query { Get-AppxPackage -Name 'Microsoft.DesktopAppInstaller' -ErrorAction SilentlyContinue } -Properties @('Name','Version','Publisher','InstallLocation','Status','IsFramework') -Recommendation 'App Installer provides MSIX/App Installer and winget components on modern Windows.' }

        # -------------------------------------------------------------------
        # System Services & Management (271-280)
        # -------------------------------------------------------------------
        271 { Invoke-GenericServiceModule -Module 271 -Category 'CoreServices' -Title '271. Windows Management Instrumentation Health' -Services @('Winmgmt') -Recommendation 'WMI is core management infrastructure for Windows and many administration tools.' }
        272 { Invoke-GenericServiceModule -Module 272 -Category 'CoreServices' -Title '272. Remote Procedure Call Service Health' -Services @('RpcSs','RpcEptMapper','DcomLaunch') -Recommendation 'RPC/DCOM services are core Windows infrastructure and should not be disabled.' }
        273 { Invoke-GenericRegistryModule -Module 273 -Category 'CoreServices' -Title '273. DCOM Security Configuration' -Checks @(@{Item='DCOM machine settings';Path='HKLM:\SOFTWARE\Microsoft\Ole';Names=@('EnableDCOM','LegacyAuthenticationLevel','LegacyImpersonationLevel','MachineAccessRestriction','MachineLaunchRestriction')}) -Recommendation 'DCOM security settings can affect Windows components and distributed applications.' }
        274 { Invoke-GenericServiceModule -Module 274 -Category 'CoreServices' -Title '274. Task Scheduler Service Health' -Services @('Schedule') -Recommendation 'Task Scheduler is used broadly by Windows servicing, maintenance and applications.' }
        275 { Invoke-GenericServiceModule -Module 275 -Category 'CoreServices' -Title '275. Background Intelligent Transfer Service Health' -Services @('BITS') -Recommendation 'BITS supports Windows Update, Store and many background-transfer workflows.' }
        276 { Invoke-GenericServiceModule -Module 276 -Category 'CoreServices' -Title '276. Windows Installer Service Health' -Services @('msiserver') -Recommendation 'Windows Installer may run on demand and can legitimately be stopped when idle.' }
        277 { Invoke-GenericServiceModule -Module 277 -Category 'CoreServices' -Title '277. COM+ Event System Health' -Services @('EventSystem','COMSysApp') -Recommendation 'COM+ services support legacy and current Windows components; startup state can be demand-based.' }
        278 { Invoke-GenericServiceModule -Module 278 -Category 'CoreServices' -Title '278. User Profile Service Health' -Services @('ProfSvc','UserManager') -Recommendation 'User profile and account-management services are fundamental to interactive logon.' }
        279 { Invoke-GenericServiceModule -Module 279 -Category 'CoreServices' -Title '279. Application Information Service Health' -Services @('Appinfo') -Recommendation 'Application Information supports UAC elevation and application launch scenarios.' }
        280 { Invoke-GenericServiceModule -Module 280 -Category 'CoreServices' -Title '280. Windows Licensing Service Health' -Services @('sppsvc','ClipSVC','LicenseManager') -Recommendation 'Licensing services can be trigger-started. Interpret stopped state together with activation/application health.' }

        # -------------------------------------------------------------------
        # User Experience & Privacy (281-290)
        # -------------------------------------------------------------------
        281 { Invoke-GenericRegistryModule -Module 281 -Category 'UXPrivacy' -Title '281. File Explorer Search History Policy' -Checks @(@{Item='Explorer search policy';Path='HKCU:\Software\Policies\Microsoft\Windows\Explorer';Names=@('DisableSearchBoxSuggestions')},@{Item='Explorer WordWheelQuery';Path='HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\WordWheelQuery';Names=@()}) -Recommendation 'Search history is user-experience/privacy data. This module only reports configuration presence.' }
        282 { Invoke-GenericRegistryModule -Module 282 -Category 'UXPrivacy' -Title '282. Recent Documents Policy' -Checks @(@{Item='Recent documents policy';Path='HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer';Names=@('NoRecentDocsHistory','ClearRecentDocsOnExit','NoRecentDocsMenu')}) -Recommendation 'Recent-document policy affects usability and local activity traces.' }
        283 { Invoke-GenericServiceModule -Module 283 -Category 'UXPrivacy' -Title '283. Windows Location Service Status' -Services @('lfsvc') -Recommendation 'Location services can be required by Windows and applications; privacy policy should guide configuration.' }
        284 { Invoke-GenericRegistryModule -Module 284 -Category 'UXPrivacy' -Title '284. Camera Consent Configuration' -Checks @(@{Item='Camera capability';Path='HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam';Names=@('Value','LastUsedTimeStart','LastUsedTimeStop')}) -Recommendation 'Camera access is privacy-sensitive and can be controlled per application in Windows Settings.' }
        285 { Invoke-GenericRegistryModule -Module 285 -Category 'UXPrivacy' -Title '285. Microphone Consent Configuration' -Checks @(@{Item='Microphone capability';Path='HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone';Names=@('Value','LastUsedTimeStart','LastUsedTimeStop')}) -Recommendation 'Microphone access is privacy-sensitive and can be controlled per application in Windows Settings.' }
        286 { Invoke-GenericRegistryModule -Module 286 -Category 'UXPrivacy' -Title '286. Windows Notification Configuration' -Checks @(@{Item='Push notifications';Path='HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications';Names=@('ToastEnabled')},@{Item='Explorer notifications policy';Path='HKCU:\Software\Policies\Microsoft\Windows\Explorer';Names=@('DisableNotificationCenter')}) -Recommendation 'Notification settings affect user experience and alert visibility.' }
        287 { Invoke-GenericCmdletModule -Module 287 -Category 'UXPrivacy' -Title '287. Windows Web Experience Pack Status' -CommandName 'Get-AppxPackage' -Query { Get-AppxPackage -Name 'MicrosoftWindows.Client.WebExperience' -ErrorAction SilentlyContinue } -Properties @('Name','Version','Publisher','InstallLocation','Status') -Recommendation 'The Web Experience Pack can provide Windows widgets and web-backed shell experiences.' }
        288 { Invoke-GenericRegistryModule -Module 288 -Category 'UXPrivacy' -Title '288. Windows Copilot Policy' -Checks @(@{Item='Windows Copilot policy';Path='HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot';Names=@('TurnOffWindowsCopilot')},@{Item='Machine Copilot policy';Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot';Names=@('TurnOffWindowsCopilot')}) -Recommendation 'Copilot availability varies by Windows release, region, account and management policy.' }
        289 { Invoke-GenericRegistryModule -Module 289 -Category 'UXPrivacy' -Title '289. Windows AI / Recall Policy Snapshot' -Checks @(@{Item='Windows AI policy';Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI';Names=@('DisableAIDataAnalysis','AllowRecallEnablement','DisableRecall')},@{Item='User Windows AI policy';Path='HKCU:\Software\Policies\Microsoft\Windows\WindowsAI';Names=@('DisableAIDataAnalysis','AllowRecallEnablement','DisableRecall')}) -Recommendation 'Windows AI and Recall controls vary by hardware, build and policy. Missing values do not imply feature availability.' }
        290 { Invoke-GenericRegistryModule -Module 290 -Category 'UXPrivacy' -Title '290. Consumer Experiences and Suggested Content' -Checks @(@{Item='Cloud content policy';Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent';Names=@('DisableWindowsConsumerFeatures','DisableTailoredExperiencesWithDiagnosticData','DisableThirdPartySuggestions','DisableWindowsSpotlightFeatures')},@{Item='User ContentDeliveryManager';Path='HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager';Names=@('SystemPaneSuggestionsEnabled','SubscribedContent-338389Enabled','SilentInstalledAppsEnabled')}) -Recommendation 'Consumer-content settings affect suggestions, promotions and personalized shell experiences.' }

        # -------------------------------------------------------------------
        # Advanced Diagnostics & Performance (291-300)
        # -------------------------------------------------------------------
        291 { Invoke-GenericCmdletModule -Module 291 -Category 'PerformanceDeep' -Title '291. Processor Topology Inventory' -CommandName 'Get-CimInstance' -Query { Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue } -Properties @('Name','Manufacturer','NumberOfCores','NumberOfLogicalProcessors','MaxClockSpeed','CurrentClockSpeed','VirtualizationFirmwareEnabled','SecondLevelAddressTranslationExtensions') -Recommendation 'Processor topology is baseline information for performance and virtualization troubleshooting.' }
        292 { Invoke-GenericCmdletModule -Module 292 -Category 'PerformanceDeep' -Title '292. Hypervisor Presence' -CommandName 'Get-CimInstance' -Query { Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue | Select-Object Name,Manufacturer,Model,HypervisorPresent,TotalPhysicalMemory } -Properties @('Name','Manufacturer','Model','HypervisorPresent','TotalPhysicalMemory') -Recommendation 'Hypervisor presence can affect virtualization, VBS and some low-level performance characteristics.' }
        293 { Invoke-GenericCmdletModule -Module 293 -Category 'PerformanceDeep' -Title '293. System Uptime and Last Boot' -CommandName 'Get-CimInstance' -Query { Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue | Select-Object Caption,Version,BuildNumber,LastBootUpTime,LocalDateTime,FreePhysicalMemory,TotalVisibleMemorySize } -Properties @('Caption','Version','BuildNumber','LastBootUpTime','LocalDateTime','FreePhysicalMemory','TotalVisibleMemorySize') -Recommendation 'Long uptime can explain pending updates or accumulated resource state; frequent reboots can indicate instability.' }
        294 { Invoke-GenericCmdletModule -Module 294 -Category 'PerformanceDeep' -Title '294. Memory Device Inventory' -CommandName 'Get-CimInstance' -Query { Get-CimInstance Win32_PhysicalMemory -ErrorAction SilentlyContinue } -Properties @('BankLabel','DeviceLocator','Capacity','Speed','ConfiguredClockSpeed','Manufacturer','PartNumber') -Recommendation 'Memory topology supports capacity, channel and hardware troubleshooting.' }
        295 { Invoke-GenericCmdletModule -Module 295 -Category 'PerformanceDeep' -Title '295. Disk Performance Snapshot' -CommandName 'Get-Counter' -Query { (Get-Counter '\PhysicalDisk(*)\Avg. Disk Queue Length','\PhysicalDisk(*)\% Disk Time' -SampleInterval 1 -MaxSamples 1 -ErrorAction SilentlyContinue).CounterSamples | Select-Object -First 80 } -Properties @('Path','InstanceName','CookedValue','Timestamp') -Recommendation 'A single counter snapshot is not a performance diagnosis; use trends and workload context.' }
        296 { Invoke-GenericCmdletModule -Module 296 -Category 'PerformanceDeep' -Title '296. Top Memory Processes Snapshot' -CommandName 'Get-Process' -Query { Get-Process -ErrorAction SilentlyContinue | Sort-Object WorkingSet64 -Descending | Select-Object -First 25 Name,Id,WorkingSet64,PrivateMemorySize64,VirtualMemorySize64,Handles,Threads } -Properties @('Name','Id','WorkingSet64','PrivateMemorySize64','VirtualMemorySize64','Handles') -Recommendation 'High memory use can be legitimate. Compare with application workload and sustained behavior.' }
        297 { Invoke-GenericCmdletModule -Module 297 -Category 'PerformanceDeep' -Title '297. Top CPU Processes Snapshot' -CommandName 'Get-Process' -Query { Get-Process -ErrorAction SilentlyContinue | Sort-Object CPU -Descending | Select-Object -First 25 Name,Id,CPU,WorkingSet64,Handles,StartTime } -Properties @('Name','Id','CPU','WorkingSet64','Handles','StartTime') -Recommendation 'Cumulative CPU time is not instantaneous utilization; use this as a triage snapshot.' }
        298 { Invoke-GenericCmdletModule -Module 298 -Category 'PerformanceDeep' -Title '298. System Error Event Summary' -CommandName 'Get-WinEvent' -Query { Get-WinEvent -FilterHashtable @{LogName='System';StartTime=(Get-Date).AddDays(-14)} -ErrorAction SilentlyContinue | Where-Object { $_.Level -le 3 } | Select-Object -First 80 } -Properties @('TimeCreated','Id','LevelDisplayName','ProviderName','Message') -Recommendation 'Review recurring Error/Critical system events by provider and event ID before remediation.' }
        299 { Invoke-GenericCmdletModule -Module 299 -Category 'PerformanceDeep' -Title '299. Application Error Event Summary' -CommandName 'Get-WinEvent' -Query { Get-WinEvent -FilterHashtable @{LogName='Application';StartTime=(Get-Date).AddDays(-14)} -ErrorAction SilentlyContinue | Where-Object { $_.Level -le 3 } | Select-Object -First 80 } -Properties @('TimeCreated','Id','LevelDisplayName','ProviderName','Message') -Recommendation 'Recurring application errors can reveal crashing software, runtime failures or component problems.' }
        300 { Invoke-GenericEventModule -Module 300 -Category 'PerformanceDeep' -Title '300. Device Setup Manager Event Summary' -LogName 'Microsoft-Windows-DeviceSetupManager/Admin' -Days 30 -MaxEvents 80 -Recommendation 'Device Setup Manager events can help explain driver/device provisioning failures.' }

        default { throw "Unknown v2.1 extension module number: $ModuleNumber" }
    }
}

function Invoke-ModuleByNumber {
    param(
        [Parameter(Mandatory)][int]$Number,
        [switch]$ReportOnly
    )

    # Safe Audit contract: compatibility modules are always report-only.
    $ReportOnly = $true

    switch ($Number) {
        1  { Invoke-ScanStartupZombies | Out-Null }
        2  { Invoke-ScanContextMenu | Out-Null }
        3  { Invoke-ScanRecentItems -ReportOnly:$ReportOnly | Out-Null }
        4  { Invoke-ScanTemp -ReportOnly:$ReportOnly | Out-Null }
        5  { Invoke-ScanCaches | Out-Null }
        6  { Invoke-ScanHibernation -ReportOnly:$ReportOnly | Out-Null }
        7  { Invoke-ScanPagefile | Out-Null }
        8  { Invoke-ScanDrivers | Out-Null }
        9  { Invoke-ScanOptionalFeatures | Out-Null }
        10 { Invoke-ScanWifiProfiles -ReportOnly:$ReportOnly | Out-Null }
        11 { Invoke-ScanBluetooth | Out-Null }
        12 { Invoke-ScanDefenderExclusions -ReportOnly:$ReportOnly | Out-Null }
        13 { Invoke-ScanScheduledTasks | Out-Null }
        14 { Invoke-ScanServices | Out-Null }
        15 { Invoke-ScanInvalidClsid | Out-Null }
        16 { Invoke-ScanDotNetFramework | Out-Null }
        17 { Invoke-ScanAppx | Out-Null }
        18 { Invoke-ScanWindowsOld | Out-Null }
        19 { Invoke-ScanEventLogs | Out-Null }
        20 { Invoke-ScanHosts -ReportOnly:$ReportOnly | Out-Null }
        21 { Invoke-ScanLargeFiles | Out-Null }
        22 { Invoke-ScanDownloads -ReportOnly:$ReportOnly | Out-Null }
        23 { Invoke-ScanRecycleBin -ReportOnly:$ReportOnly | Out-Null }
        24 { Invoke-ScanCrashDumps -ReportOnly:$ReportOnly | Out-Null }
        25 { Invoke-ScanWER -ReportOnly:$ReportOnly | Out-Null }
        26 { Invoke-ScanBrowserCaches | Out-Null }
        27 { Invoke-ScanStartupFolders | Out-Null }
        28 { Invoke-ScanVpnProxy | Out-Null }
        29 { Invoke-ScanComponentStore -ReportOnly:$ReportOnly | Out-Null }
        30 { Invoke-ScanRestorePoints | Out-Null }
        31 { Invoke-ScanStorageSense | Out-Null }
        32 { Invoke-ScanDeliveryOptimization | Out-Null }
        33 { Invoke-ScanSearchIndex | Out-Null }
        34 { Invoke-ScanOneDriveStorage | Out-Null }
        35 { Invoke-ScanOfficeCache | Out-Null }
        36 { Invoke-ScanStoreCache | Out-Null }
        37 { Invoke-ScanBrokenShortcuts | Out-Null }
        38 { Invoke-ScanStaticRoutes | Out-Null }
        39 { Invoke-ScanNetworkAdapters | Out-Null }
        40 { Invoke-ScanPrintQueue | Out-Null }
        41 { Invoke-ScanPrivacySettings | Out-Null }
        42 { Invoke-ScanHistoryPrivacy | Out-Null }
        43 { Invoke-ScanWindowsUpdateCache | Out-Null }
        44 { Invoke-ScanPendingReboot | Out-Null }
        45 { Invoke-ScanMaintenanceLogs | Out-Null }
        46 { Invoke-ScanVolumeHealth | Out-Null }
        47 { Invoke-ScanPowerConfiguration | Out-Null }
        48 { Invoke-ScanPathIntegrity | Out-Null }
        49 { Invoke-ScanMappedDrives | Out-Null }
        50 { Invoke-ScanSmbShares | Out-Null }
        51 { Invoke-ScanXboxCapture | Out-Null }
        52 { Invoke-ScanPowerShellModules | Out-Null }
        53 { Invoke-ScanInstallerCache | Out-Null }
        54 { Invoke-ScanUserProfiles | Out-Null }
        55 { Invoke-ScanBatteryHealth | Out-Null }
        56 { Invoke-ScanBitLockerStatus | Out-Null }
        57 { Invoke-ScanFirewallProfiles | Out-Null }
        58 { Invoke-ScanOrphanFirewallRules | Out-Null }
        59 { Invoke-ScanDefenderHealth | Out-Null }
        60 { Invoke-ScanTimeSync | Out-Null }
        61 { Invoke-ScanWslFootprint | Out-Null }
        62 { Invoke-ScanHyperVDisks | Out-Null }
        63 { Invoke-ScanOutlookDataFiles | Out-Null }
        64 { Invoke-ScanTeamsCache | Out-Null }
        65 { Invoke-ScanBrowserProfiles | Out-Null }
        66 { Invoke-ScanEnvironmentVariables | Out-Null }
        67 { Invoke-ScanGhostDevices | Out-Null }
        68 { Invoke-ScanTaskActionOrphans | Out-Null }
        69 { Invoke-ScanOrphanServices | Out-Null }
        70 { Invoke-ScanReservedStorage | Out-Null }
        71 { Invoke-ScanProvisionedApps | Out-Null }
        72 { Invoke-ScanLocalAccounts | Out-Null }
        73 { Invoke-ScanIconThumbnailCache | Out-Null }
        74 { Invoke-ScanDiagnosticTelemetryStorage | Out-Null }
        75 { Invoke-ScanLargeDuplicateFiles | Out-Null }
        76 { Invoke-ScanNetworkAdapterHygiene | Out-Null }
        77 { Invoke-ScanSecureBoot | Out-Null }
        78 { Invoke-ScanTpm | Out-Null }
        79 { Invoke-ScanVbs | Out-Null }
        80 { Invoke-ScanMemoryIntegrity | Out-Null }
        81 { Invoke-ScanCredentialGuard | Out-Null }
        82 { Invoke-ScanLsaProtection | Out-Null }
        83 { Invoke-ScanSmartScreen | Out-Null }
        84 { Invoke-ScanAsrRules | Out-Null }
        85 { Invoke-ScanControlledFolderAccess | Out-Null }
        86 { Invoke-ScanRemoteDesktop | Out-Null }
        87 { Invoke-ScanWinRm | Out-Null }
        88 { Invoke-ScanSmbSecurity | Out-Null }
        89 { Invoke-ScanDismHealth | Out-Null }
        90 { Invoke-ScanSfcVerifyOnly | Out-Null }
        91 { Invoke-ScanWindowsUpdateHistory | Out-Null }
        92 { Invoke-ScanWinRe | Out-Null }
        93 { Invoke-ScanBcd | Out-Null }
        94 { Invoke-ScanBootPerformance | Out-Null }
        95 { Invoke-ScanTrim | Out-Null }
        96 { Invoke-ScanPhysicalDiskHealth | Out-Null }
        97 { Invoke-ScanWhea | Out-Null }
        98 { Invoke-ScanReliability | Out-Null }
        99 { Invoke-ScanModernStandby | Out-Null }
        100 { Invoke-ScanPowerRequests | Out-Null }
        101 { Invoke-ExtendedModule -ModuleNumber 101 | Out-Null }
        102 { Invoke-ExtendedModule -ModuleNumber 102 | Out-Null }
        103 { Invoke-ExtendedModule -ModuleNumber 103 | Out-Null }
        104 { Invoke-ExtendedModule -ModuleNumber 104 | Out-Null }
        105 { Invoke-ExtendedModule -ModuleNumber 105 | Out-Null }
        106 { Invoke-ExtendedModule -ModuleNumber 106 | Out-Null }
        107 { Invoke-ExtendedModule -ModuleNumber 107 | Out-Null }
        108 { Invoke-ExtendedModule -ModuleNumber 108 | Out-Null }
        109 { Invoke-ExtendedModule -ModuleNumber 109 | Out-Null }
        110 { Invoke-ExtendedModule -ModuleNumber 110 | Out-Null }
        111 { Invoke-ExtendedModule -ModuleNumber 111 | Out-Null }
        112 { Invoke-ExtendedModule -ModuleNumber 112 | Out-Null }
        113 { Invoke-ExtendedModule -ModuleNumber 113 | Out-Null }
        114 { Invoke-ExtendedModule -ModuleNumber 114 | Out-Null }
        115 { Invoke-ExtendedModule -ModuleNumber 115 | Out-Null }
        116 { Invoke-ExtendedModule -ModuleNumber 116 | Out-Null }
        117 { Invoke-ExtendedModule -ModuleNumber 117 | Out-Null }
        118 { Invoke-ExtendedModule -ModuleNumber 118 | Out-Null }
        119 { Invoke-ExtendedModule -ModuleNumber 119 | Out-Null }
        120 { Invoke-ExtendedModule -ModuleNumber 120 | Out-Null }
        121 { Invoke-ExtendedModule -ModuleNumber 121 | Out-Null }
        122 { Invoke-ExtendedModule -ModuleNumber 122 | Out-Null }
        123 { Invoke-ExtendedModule -ModuleNumber 123 | Out-Null }
        124 { Invoke-ExtendedModule -ModuleNumber 124 | Out-Null }
        125 { Invoke-ExtendedModule -ModuleNumber 125 | Out-Null }
        126 { Invoke-ExtendedModule -ModuleNumber 126 | Out-Null }
        127 { Invoke-ExtendedModule -ModuleNumber 127 | Out-Null }
        128 { Invoke-ExtendedModule -ModuleNumber 128 | Out-Null }
        129 { Invoke-ExtendedModule -ModuleNumber 129 | Out-Null }
        130 { Invoke-ExtendedModule -ModuleNumber 130 | Out-Null }
        131 { Invoke-ExtendedModule -ModuleNumber 131 | Out-Null }
        132 { Invoke-ExtendedModule -ModuleNumber 132 | Out-Null }
        133 { Invoke-ExtendedModule -ModuleNumber 133 | Out-Null }
        134 { Invoke-ExtendedModule -ModuleNumber 134 | Out-Null }
        135 { Invoke-ExtendedModule -ModuleNumber 135 | Out-Null }
        136 { Invoke-ExtendedModule -ModuleNumber 136 | Out-Null }
        137 { Invoke-ExtendedModule -ModuleNumber 137 | Out-Null }
        138 { Invoke-ExtendedModule -ModuleNumber 138 | Out-Null }
        139 { Invoke-ExtendedModule -ModuleNumber 139 | Out-Null }
        140 { Invoke-ExtendedModule -ModuleNumber 140 | Out-Null }
        141 { Invoke-ExtendedModule -ModuleNumber 141 | Out-Null }
        142 { Invoke-ExtendedModule -ModuleNumber 142 | Out-Null }
        143 { Invoke-ExtendedModule -ModuleNumber 143 | Out-Null }
        144 { Invoke-ExtendedModule -ModuleNumber 144 | Out-Null }
        145 { Invoke-ExtendedModule -ModuleNumber 145 | Out-Null }
        146 { Invoke-ExtendedModule -ModuleNumber 146 | Out-Null }
        147 { Invoke-ExtendedModule -ModuleNumber 147 | Out-Null }
        148 { Invoke-ExtendedModule -ModuleNumber 148 | Out-Null }
        149 { Invoke-ExtendedModule -ModuleNumber 149 | Out-Null }
        150 { Invoke-ExtendedModule -ModuleNumber 150 | Out-Null }
        151 { Invoke-ExtendedModule -ModuleNumber 151 | Out-Null }
        152 { Invoke-ExtendedModule -ModuleNumber 152 | Out-Null }
        153 { Invoke-ExtendedModule -ModuleNumber 153 | Out-Null }
        154 { Invoke-ExtendedModule -ModuleNumber 154 | Out-Null }
        155 { Invoke-ExtendedModule -ModuleNumber 155 | Out-Null }
        156 { Invoke-ExtendedModule -ModuleNumber 156 | Out-Null }
        157 { Invoke-ExtendedModule -ModuleNumber 157 | Out-Null }
        158 { Invoke-ExtendedModule -ModuleNumber 158 | Out-Null }
        159 { Invoke-ExtendedModule -ModuleNumber 159 | Out-Null }
        160 { Invoke-ExtendedModule -ModuleNumber 160 | Out-Null }
        161 { Invoke-ExtendedModule -ModuleNumber 161 | Out-Null }
        162 { Invoke-ExtendedModule -ModuleNumber 162 | Out-Null }
        163 { Invoke-ExtendedModule -ModuleNumber 163 | Out-Null }
        164 { Invoke-ExtendedModule -ModuleNumber 164 | Out-Null }
        165 { Invoke-ExtendedModule -ModuleNumber 165 | Out-Null }
        166 { Invoke-ExtendedModule -ModuleNumber 166 | Out-Null }
        167 { Invoke-ExtendedModule -ModuleNumber 167 | Out-Null }
        168 { Invoke-ExtendedModule -ModuleNumber 168 | Out-Null }
        169 { Invoke-ExtendedModule -ModuleNumber 169 | Out-Null }
        170 { Invoke-ExtendedModule -ModuleNumber 170 | Out-Null }
        171 { Invoke-ExtendedModule -ModuleNumber 171 | Out-Null }
        172 { Invoke-ExtendedModule -ModuleNumber 172 | Out-Null }
        173 { Invoke-ExtendedModule -ModuleNumber 173 | Out-Null }
        174 { Invoke-ExtendedModule -ModuleNumber 174 | Out-Null }
        175 { Invoke-ExtendedModule -ModuleNumber 175 | Out-Null }
        176 { Invoke-ExtendedModule -ModuleNumber 176 | Out-Null }
        177 { Invoke-ExtendedModule -ModuleNumber 177 | Out-Null }
        178 { Invoke-ExtendedModule -ModuleNumber 178 | Out-Null }
        179 { Invoke-ExtendedModule -ModuleNumber 179 | Out-Null }
        180 { Invoke-ExtendedModule -ModuleNumber 180 | Out-Null }
        181 { Invoke-ExtendedModule -ModuleNumber 181 | Out-Null }
        182 { Invoke-ExtendedModule -ModuleNumber 182 | Out-Null }
        183 { Invoke-ExtendedModule -ModuleNumber 183 | Out-Null }
        184 { Invoke-ExtendedModule -ModuleNumber 184 | Out-Null }
        185 { Invoke-ExtendedModule -ModuleNumber 185 | Out-Null }
        186 { Invoke-ExtendedModule -ModuleNumber 186 | Out-Null }
        187 { Invoke-ExtendedModule -ModuleNumber 187 | Out-Null }
        188 { Invoke-ExtendedModule -ModuleNumber 188 | Out-Null }
        189 { Invoke-ExtendedModule -ModuleNumber 189 | Out-Null }
        190 { Invoke-ExtendedModule -ModuleNumber 190 | Out-Null }
        191 { Invoke-ExtendedModule -ModuleNumber 191 | Out-Null }
        192 { Invoke-ExtendedModule -ModuleNumber 192 | Out-Null }
        193 { Invoke-ExtendedModule -ModuleNumber 193 | Out-Null }
        194 { Invoke-ExtendedModule -ModuleNumber 194 | Out-Null }
        195 { Invoke-ExtendedModule -ModuleNumber 195 | Out-Null }
        196 { Invoke-ExtendedModule -ModuleNumber 196 | Out-Null }
        197 { Invoke-ExtendedModule -ModuleNumber 197 | Out-Null }
        198 { Invoke-ExtendedModule -ModuleNumber 198 | Out-Null }
        199 { Invoke-ExtendedModule -ModuleNumber 199 | Out-Null }
        200 { Invoke-ExtendedModule -ModuleNumber 200 | Out-Null }
        201 { Invoke-ExtendedModuleV21 -ModuleNumber 201 | Out-Null }
        202 { Invoke-ExtendedModuleV21 -ModuleNumber 202 | Out-Null }
        203 { Invoke-ExtendedModuleV21 -ModuleNumber 203 | Out-Null }
        204 { Invoke-ExtendedModuleV21 -ModuleNumber 204 | Out-Null }
        205 { Invoke-ExtendedModuleV21 -ModuleNumber 205 | Out-Null }
        206 { Invoke-ExtendedModuleV21 -ModuleNumber 206 | Out-Null }
        207 { Invoke-ExtendedModuleV21 -ModuleNumber 207 | Out-Null }
        208 { Invoke-ExtendedModuleV21 -ModuleNumber 208 | Out-Null }
        209 { Invoke-ExtendedModuleV21 -ModuleNumber 209 | Out-Null }
        210 { Invoke-ExtendedModuleV21 -ModuleNumber 210 | Out-Null }
        211 { Invoke-ExtendedModuleV21 -ModuleNumber 211 | Out-Null }
        212 { Invoke-ExtendedModuleV21 -ModuleNumber 212 | Out-Null }
        213 { Invoke-ExtendedModuleV21 -ModuleNumber 213 | Out-Null }
        214 { Invoke-ExtendedModuleV21 -ModuleNumber 214 | Out-Null }
        215 { Invoke-ExtendedModuleV21 -ModuleNumber 215 | Out-Null }
        216 { Invoke-ExtendedModuleV21 -ModuleNumber 216 | Out-Null }
        217 { Invoke-ExtendedModuleV21 -ModuleNumber 217 | Out-Null }
        218 { Invoke-ExtendedModuleV21 -ModuleNumber 218 | Out-Null }
        219 { Invoke-ExtendedModuleV21 -ModuleNumber 219 | Out-Null }
        220 { Invoke-ExtendedModuleV21 -ModuleNumber 220 | Out-Null }
        221 { Invoke-ExtendedModuleV21 -ModuleNumber 221 | Out-Null }
        222 { Invoke-ExtendedModuleV21 -ModuleNumber 222 | Out-Null }
        223 { Invoke-ExtendedModuleV21 -ModuleNumber 223 | Out-Null }
        224 { Invoke-ExtendedModuleV21 -ModuleNumber 224 | Out-Null }
        225 { Invoke-ExtendedModuleV21 -ModuleNumber 225 | Out-Null }
        226 { Invoke-ExtendedModuleV21 -ModuleNumber 226 | Out-Null }
        227 { Invoke-ExtendedModuleV21 -ModuleNumber 227 | Out-Null }
        228 { Invoke-ExtendedModuleV21 -ModuleNumber 228 | Out-Null }
        229 { Invoke-ExtendedModuleV21 -ModuleNumber 229 | Out-Null }
        230 { Invoke-ExtendedModuleV21 -ModuleNumber 230 | Out-Null }
        231 { Invoke-ExtendedModuleV21 -ModuleNumber 231 | Out-Null }
        232 { Invoke-ExtendedModuleV21 -ModuleNumber 232 | Out-Null }
        233 { Invoke-ExtendedModuleV21 -ModuleNumber 233 | Out-Null }
        234 { Invoke-ExtendedModuleV21 -ModuleNumber 234 | Out-Null }
        235 { Invoke-ExtendedModuleV21 -ModuleNumber 235 | Out-Null }
        236 { Invoke-ExtendedModuleV21 -ModuleNumber 236 | Out-Null }
        237 { Invoke-ExtendedModuleV21 -ModuleNumber 237 | Out-Null }
        238 { Invoke-ExtendedModuleV21 -ModuleNumber 238 | Out-Null }
        239 { Invoke-ExtendedModuleV21 -ModuleNumber 239 | Out-Null }
        240 { Invoke-ExtendedModuleV21 -ModuleNumber 240 | Out-Null }
        241 { Invoke-ExtendedModuleV21 -ModuleNumber 241 | Out-Null }
        242 { Invoke-ExtendedModuleV21 -ModuleNumber 242 | Out-Null }
        243 { Invoke-ExtendedModuleV21 -ModuleNumber 243 | Out-Null }
        244 { Invoke-ExtendedModuleV21 -ModuleNumber 244 | Out-Null }
        245 { Invoke-ExtendedModuleV21 -ModuleNumber 245 | Out-Null }
        246 { Invoke-ExtendedModuleV21 -ModuleNumber 246 | Out-Null }
        247 { Invoke-ExtendedModuleV21 -ModuleNumber 247 | Out-Null }
        248 { Invoke-ExtendedModuleV21 -ModuleNumber 248 | Out-Null }
        249 { Invoke-ExtendedModuleV21 -ModuleNumber 249 | Out-Null }
        250 { Invoke-ExtendedModuleV21 -ModuleNumber 250 | Out-Null }
        251 { Invoke-ExtendedModuleV21 -ModuleNumber 251 | Out-Null }
        252 { Invoke-ExtendedModuleV21 -ModuleNumber 252 | Out-Null }
        253 { Invoke-ExtendedModuleV21 -ModuleNumber 253 | Out-Null }
        254 { Invoke-ExtendedModuleV21 -ModuleNumber 254 | Out-Null }
        255 { Invoke-ExtendedModuleV21 -ModuleNumber 255 | Out-Null }
        256 { Invoke-ExtendedModuleV21 -ModuleNumber 256 | Out-Null }
        257 { Invoke-ExtendedModuleV21 -ModuleNumber 257 | Out-Null }
        258 { Invoke-ExtendedModuleV21 -ModuleNumber 258 | Out-Null }
        259 { Invoke-ExtendedModuleV21 -ModuleNumber 259 | Out-Null }
        260 { Invoke-ExtendedModuleV21 -ModuleNumber 260 | Out-Null }
        261 { Invoke-ExtendedModuleV21 -ModuleNumber 261 | Out-Null }
        262 { Invoke-ExtendedModuleV21 -ModuleNumber 262 | Out-Null }
        263 { Invoke-ExtendedModuleV21 -ModuleNumber 263 | Out-Null }
        264 { Invoke-ExtendedModuleV21 -ModuleNumber 264 | Out-Null }
        265 { Invoke-ExtendedModuleV21 -ModuleNumber 265 | Out-Null }
        266 { Invoke-ExtendedModuleV21 -ModuleNumber 266 | Out-Null }
        267 { Invoke-ExtendedModuleV21 -ModuleNumber 267 | Out-Null }
        268 { Invoke-ExtendedModuleV21 -ModuleNumber 268 | Out-Null }
        269 { Invoke-ExtendedModuleV21 -ModuleNumber 269 | Out-Null }
        270 { Invoke-ExtendedModuleV21 -ModuleNumber 270 | Out-Null }
        271 { Invoke-ExtendedModuleV21 -ModuleNumber 271 | Out-Null }
        272 { Invoke-ExtendedModuleV21 -ModuleNumber 272 | Out-Null }
        273 { Invoke-ExtendedModuleV21 -ModuleNumber 273 | Out-Null }
        274 { Invoke-ExtendedModuleV21 -ModuleNumber 274 | Out-Null }
        275 { Invoke-ExtendedModuleV21 -ModuleNumber 275 | Out-Null }
        276 { Invoke-ExtendedModuleV21 -ModuleNumber 276 | Out-Null }
        277 { Invoke-ExtendedModuleV21 -ModuleNumber 277 | Out-Null }
        278 { Invoke-ExtendedModuleV21 -ModuleNumber 278 | Out-Null }
        279 { Invoke-ExtendedModuleV21 -ModuleNumber 279 | Out-Null }
        280 { Invoke-ExtendedModuleV21 -ModuleNumber 280 | Out-Null }
        281 { Invoke-ExtendedModuleV21 -ModuleNumber 281 | Out-Null }
        282 { Invoke-ExtendedModuleV21 -ModuleNumber 282 | Out-Null }
        283 { Invoke-ExtendedModuleV21 -ModuleNumber 283 | Out-Null }
        284 { Invoke-ExtendedModuleV21 -ModuleNumber 284 | Out-Null }
        285 { Invoke-ExtendedModuleV21 -ModuleNumber 285 | Out-Null }
        286 { Invoke-ExtendedModuleV21 -ModuleNumber 286 | Out-Null }
        287 { Invoke-ExtendedModuleV21 -ModuleNumber 287 | Out-Null }
        288 { Invoke-ExtendedModuleV21 -ModuleNumber 288 | Out-Null }
        289 { Invoke-ExtendedModuleV21 -ModuleNumber 289 | Out-Null }
        290 { Invoke-ExtendedModuleV21 -ModuleNumber 290 | Out-Null }
        291 { Invoke-ExtendedModuleV21 -ModuleNumber 291 | Out-Null }
        292 { Invoke-ExtendedModuleV21 -ModuleNumber 292 | Out-Null }
        293 { Invoke-ExtendedModuleV21 -ModuleNumber 293 | Out-Null }
        294 { Invoke-ExtendedModuleV21 -ModuleNumber 294 | Out-Null }
        295 { Invoke-ExtendedModuleV21 -ModuleNumber 295 | Out-Null }
        296 { Invoke-ExtendedModuleV21 -ModuleNumber 296 | Out-Null }
        297 { Invoke-ExtendedModuleV21 -ModuleNumber 297 | Out-Null }
        298 { Invoke-ExtendedModuleV21 -ModuleNumber 298 | Out-Null }
        299 { Invoke-ExtendedModuleV21 -ModuleNumber 299 | Out-Null }
        300 { Invoke-ExtendedModuleV21 -ModuleNumber 300 | Out-Null }
        default { throw "Unknown module number: $Number" }
    }
}

$Script:ModuleCatalog = @(

    # Disk & Storage
    [pscustomobject]@{No=3;Group='Disk & Storage';Name='File Explorer Recent Items';Flags='[C]';Description='Finds old Recent-item shortcuts and previews them before cleanup.'},
    [pscustomobject]@{No=4;Group='Disk & Storage';Name='Temporary Files';Flags='[C]';Description='Finds old temp files and previews every deletion candidate.'},
    [pscustomobject]@{No=5;Group='Disk & Storage';Name='Windows Cache Usage';Flags='[R]';Description='Measures important Windows cache locations.'},
    [pscustomobject]@{No=18;Group='Disk & Storage';Name='Previous Windows Installation';Flags='[R]';Description='Reports Windows.old and its estimated disk usage.'},
    [pscustomobject]@{No=21;Group='Disk & Storage';Name='Large Files Analyzer';Flags='[R]';Description='Searches user data for very large, old files without deleting them.'},
    [pscustomobject]@{No=22;Group='Disk & Storage';Name='Downloads Folder Cleanup';Flags='[C]';Description='Finds old Downloads files, shows them, then asks before deletion.'},
    [pscustomobject]@{No=23;Group='Disk & Storage';Name='Recycle Bin Analyzer';Flags='[C][!]';Description='Reports Recycle Bin usage and asks before emptying it.'},
    [pscustomobject]@{No=31;Group='Disk & Storage';Name='Storage Sense Configuration';Flags='[R]';Description='Reports the current-user Storage Sense configuration.'},
    [pscustomobject]@{No=46;Group='Disk & Storage';Name='Volume Space and File System Health';Flags='[R]';Description='Reports free-space percentage and Windows volume health information.'},
    [pscustomobject]@{No=53;Group='Disk & Storage';Name='Windows Installer Cache Analyzer';Flags='[R][A][!]';Description='Measures C:\Windows\Installer and shows the largest MSI/MSP files; never auto-deletes them.'},
    [pscustomobject]@{No=75;Group='Disk & Storage';Name='Large Duplicate Files Analyzer';Flags='[R]';Description='Uses size grouping plus SHA256 to confirm content-identical 50MB+ files.'},
    [pscustomobject]@{No=95;Group='Disk & Storage';Name='TRIM / Delete Notification Status';Flags='[R][A]';Description='Reports NTFS/ReFS delete-notification state used by modern storage stacks.'},

    # Windows Update & Servicing
    [pscustomobject]@{No=9;Group='Windows Update & Servicing';Name='Windows Optional Features';Flags='[R][A]';Description='Lists Windows optional features that may deserve review.'},
    [pscustomobject]@{No=29;Group='Windows Update & Servicing';Name='Component Store (WinSxS) Analyzer';Flags='[C][A]';Description='Uses DISM to analyze WinSxS and offers supported component cleanup.'},
    [pscustomobject]@{No=32;Group='Windows Update & Servicing';Name='Delivery Optimization Cache';Flags='[R][A]';Description='Measures Windows Delivery Optimization cache locations.'},
    [pscustomobject]@{No=43;Group='Windows Update & Servicing';Name='Windows Update Download Cache';Flags='[R][A]';Description='Measures SoftwareDistribution download-cache usage without manual deletion.'},
    [pscustomobject]@{No=44;Group='Windows Update & Servicing';Name='Pending Reboot and Servicing State';Flags='[R][A]';Description='Checks common Windows servicing and reboot-pending indicators.'},
    [pscustomobject]@{No=70;Group='Windows Update & Servicing';Name='Reserved Storage Analyzer';Flags='[R][A]';Description='Reports Windows Reserved Storage state through DISM without changing it.'},
    [pscustomobject]@{No=71;Group='Windows Update & Servicing';Name='Provisioned App Inventory';Flags='[R][A]';Description='Lists Appx packages provisioned for future/new user profiles.'},
    [pscustomobject]@{No=89;Group='Windows Update & Servicing';Name='DISM Component Health';Flags='[R][A]';Description='Runs DISM CheckHealth only; no RestoreHealth or servicing repair is performed.'},
    [pscustomobject]@{No=90;Group='Windows Update & Servicing';Name='SFC VerifyOnly';Flags='[R][A]';Description='Runs System File Checker in verify-only mode and performs no automatic repair.'},
    [pscustomobject]@{No=91;Group='Windows Update & Servicing';Name='Windows Update History';Flags='[R]';Description='Shows recent Windows Update results and repeated failure candidates.'},

    # Boot & Recovery
    [pscustomobject]@{No=30;Group='Boot & Recovery';Name='Restore Points and VSS Analyzer';Flags='[R][A]';Description='Reports restore points and VSS shadow-storage usage.'},
    [pscustomobject]@{No=92;Group='Boot & Recovery';Name='Windows Recovery Environment (WinRE)';Flags='[R][A]';Description='Reports WinRE status and recovery configuration using reagentc /info.'},
    [pscustomobject]@{No=93;Group='Boot & Recovery';Name='BCD Configuration Analyzer';Flags='[R][A][!]';Description='Reads current BCD loader/boot-manager configuration without changing boot data.'},

    # Startup & Shell
    [pscustomobject]@{No=1;Group='Startup & Shell';Name='Startup Registry Orphans';Flags='[R]';Description='Validates Run entries and reports missing or unresolved executable targets.'},
    [pscustomobject]@{No=2;Group='Startup & Shell';Name='Context Menu Orphans';Flags='[R]';Description='Checks context-menu handlers with literal registry paths and validates targets.'},
    [pscustomobject]@{No=13;Group='Startup & Shell';Name='Failed Scheduled Tasks';Flags='[R]';Description='Reports scheduled tasks whose last run returned a non-zero result.'},
    [pscustomobject]@{No=14;Group='Startup & Shell';Name='Service Review';Flags='[R]';Description='Highlights selected services for manual role-based review.'},
    [pscustomobject]@{No=15;Group='Startup & Shell';Name='Invalid CLSID / COM Registrations';Flags='[R]';Description='Finds COM registrations whose InprocServer32 target appears missing.'},
    [pscustomobject]@{No=27;Group='Startup & Shell';Name='Startup Folder Analyzer';Flags='[R]';Description='Checks current-user and common Startup folders for shortcut targets.'},
    [pscustomobject]@{No=37;Group='Startup & Shell';Name='Broken Shortcuts';Flags='[R]';Description='Checks Desktop and Start Menu .lnk files for missing targets.'},
    [pscustomobject]@{No=48;Group='Startup & Shell';Name='PATH Integrity Analyzer';Flags='[R]';Description='Shows missing and duplicate user/machine PATH entries.'},
    [pscustomobject]@{No=68;Group='Startup & Shell';Name='Scheduled Task Orphan Actions';Flags='[R][A]';Description='Finds scheduled-task executable targets that are confirmed missing.'},
    [pscustomobject]@{No=69;Group='Startup & Shell';Name='Orphaned Windows Services';Flags='[R][A][!]';Description='Finds user-mode Windows services whose executable target appears missing.'},

    # Applications & Caches
    [pscustomobject]@{No=16;Group='Applications & Caches';Name='.NET Framework Inventory';Flags='[R]';Description='Reports installed .NET Framework registrations.'},
    [pscustomobject]@{No=17;Group='Applications & Caches';Name='Appx Package Health';Flags='[R][A]';Description='Checks Appx package health without touching WindowsApps directly.'},
    [pscustomobject]@{No=26;Group='Applications & Caches';Name='Browser Cache Analyzer';Flags='[R]';Description='Measures Edge, Chrome and Firefox cache locations.'},
    [pscustomobject]@{No=34;Group='Applications & Caches';Name='OneDrive Local Storage';Flags='[R]';Description='Measures common OneDrive local sync folders without deleting synchronized files.'},
    [pscustomobject]@{No=35;Group='Applications & Caches';Name='Microsoft Office Document Cache';Flags='[R]';Description='Measures common Office document-cache locations.'},
    [pscustomobject]@{No=36;Group='Applications & Caches';Name='Microsoft Store Cache';Flags='[R]';Description='Measures Microsoft Store cache locations without deleting package data.'},
    [pscustomobject]@{No=51;Group='Applications & Caches';Name='Xbox Game Bar and Capture Storage';Flags='[R]';Description='Reports Game DVR state and the local Videos\Captures footprint.'},
    [pscustomobject]@{No=63;Group='Applications & Caches';Name='Outlook OST/PST Analyzer';Flags='[R]';Description='Reports large or old Outlook OST/PST files in common current-user locations.'},
    [pscustomobject]@{No=64;Group='Applications & Caches';Name='Microsoft Teams Cache Analyzer';Flags='[R]';Description='Measures classic and new Teams local cache/data locations.'},
    [pscustomobject]@{No=65;Group='Applications & Caches';Name='Browser Profile Analyzer';Flags='[R]';Description='Measures and dates Edge, Chrome and Firefox profiles separately from cache analysis.'},
    [pscustomobject]@{No=73;Group='Applications & Caches';Name='Icon & Thumbnail Database Cache';Flags='[R]';Description='Measures Explorer iconcache/thumbcache database footprint without deleting active databases.'},

    # Network & Connectivity
    [pscustomobject]@{No=10;Group='Network & Connectivity';Name='Saved Wi-Fi Profiles';Flags='[C][!]';Description='Lists saved Wi-Fi profiles and allows one-at-a-time deletion after preview.'},
    [pscustomobject]@{No=20;Group='Network & Connectivity';Name='Hosts File and DNS Cache';Flags='[C]';Description='Reviews hosts entries and shows DNS cache records before optional flush.'},
    [pscustomobject]@{No=28;Group='Network & Connectivity';Name='VPN and Proxy Analyzer';Flags='[R]';Description='Reports saved VPN connections plus WinINET and WinHTTP proxy configuration.'},
    [pscustomobject]@{No=38;Group='Network & Connectivity';Name='Persistent / Static Routes';Flags='[R][A]';Description='Reports persistent/static routes for manual validation.'},
    [pscustomobject]@{No=39;Group='Network & Connectivity';Name='Network Adapter Inventory';Flags='[R]';Description='Lists active, disabled and hidden network adapters.'},
    [pscustomobject]@{No=49;Group='Network & Connectivity';Name='Mapped Network Drives';Flags='[R]';Description='Reports current SMB/file-system drive mappings.'},
    [pscustomobject]@{No=50;Group='Network & Connectivity';Name='SMB Shares Inventory';Flags='[R][A]';Description='Reports local SMB shares and highlights non-system shares for review.'},
    [pscustomobject]@{No=60;Group='Network & Connectivity';Name='Time Synchronization / NTP Health';Flags='[R]';Description='Reports Windows Time service, time source and w32tm synchronization status.'},
    [pscustomobject]@{No=76;Group='Network & Connectivity';Name='Network Adapter Hygiene';Flags='[R]';Description='Focuses on inactive and recognizable virtual/VPN/WSL/Hyper-V adapters for manual review.'},

    # Windows Security
    [pscustomobject]@{No=12;Group='Windows Security';Name='Defender Exclusion Orphans';Flags='[C][A][!]';Description='Finds Defender exclusion paths that no longer exist and previews removal.'},
    [pscustomobject]@{No=56;Group='Windows Security';Name='BitLocker and Device Encryption Status';Flags='[R][A]';Description='Reports encryption, protection and lock status without changing BitLocker.'},
    [pscustomobject]@{No=57;Group='Windows Security';Name='Windows Firewall Profile Health';Flags='[R]';Description='Reports Domain, Private and Public firewall profile state.'},
    [pscustomobject]@{No=58;Group='Windows Security';Name='Orphaned Firewall Application Rules';Flags='[R][A]';Description='Finds firewall application filters that reference missing executable paths.'},
    [pscustomobject]@{No=59;Group='Windows Security';Name='Microsoft Defender Health';Flags='[R]';Description='Reports real-time protection, signature age, engine and scan information.'},
    [pscustomobject]@{No=77;Group='Windows Security';Name='Secure Boot Status';Flags='[R][A]';Description='Reports UEFI Secure Boot status without modifying firmware settings.'},
    [pscustomobject]@{No=78;Group='Windows Security';Name='TPM 2.0 Status';Flags='[R][A][!]';Description='Reports TPM presence/readiness without initializing or clearing the TPM.'},
    [pscustomobject]@{No=79;Group='Windows Security';Name='Virtualization-Based Security (VBS)';Flags='[R]';Description='Reports Device Guard VBS state and configured/running security services.'},
    [pscustomobject]@{No=80;Group='Windows Security';Name='Memory Integrity / HVCI';Flags='[R]';Description='Reports HVCI/Memory Integrity configuration and runtime state.'},
    [pscustomobject]@{No=81;Group='Windows Security';Name='Credential Guard';Flags='[R]';Description='Reports Credential Guard configuration and runtime state through DeviceGuard CIM.'},
    [pscustomobject]@{No=82;Group='Windows Security';Name='LSA Protection';Flags='[R][A]';Description='Reports RunAsPPL/LSA protection registry state without changing it.'},
    [pscustomobject]@{No=83;Group='Windows Security';Name='Microsoft Defender SmartScreen';Flags='[R]';Description='Reports common SmartScreen policy and user configuration values.'},
    [pscustomobject]@{No=84;Group='Windows Security';Name='Attack Surface Reduction (ASR) Rules';Flags='[R][A]';Description='Lists Defender ASR rule IDs and enforcement modes.'},
    [pscustomobject]@{No=85;Group='Windows Security';Name='Controlled Folder Access';Flags='[R][A]';Description='Reports Defender Controlled Folder Access mode and configured lists.'},
    [pscustomobject]@{No=86;Group='Windows Security';Name='Remote Desktop / NLA';Flags='[R][A]';Description='Reports RDP enablement and Network Level Authentication state.'},
    [pscustomobject]@{No=87;Group='Windows Security';Name='WinRM / PowerShell Remoting';Flags='[R][A]';Description='Reports WinRM service and listener exposure for remote administration review.'},
    [pscustomobject]@{No=88;Group='Windows Security';Name='SMB1 and SMB Signing';Flags='[R][A]';Description='Reports SMB1 plus SMB client/server signing and insecure guest settings.'},

    # Privacy
    [pscustomobject]@{No=41;Group='Privacy';Name='Advertising ID and Diagnostic Data';Flags='[R]';Description='Reports Advertising ID and diagnostic-data policy values without changing them.'},
    [pscustomobject]@{No=42;Group='Privacy';Name='Clipboard and Activity History';Flags='[R]';Description='Reports clipboard-history and activity-history related configuration.'},
    [pscustomobject]@{No=74;Group='Privacy';Name='Telemetry & Diagnostic Log Storage';Flags='[R][A]';Description='Measures common Windows diagnostic, WMI AutoLogger and ETL storage locations.'},

    # Devices & Drivers
    [pscustomobject]@{No=8;Group='Devices & Drivers';Name='DriverStore / OEM Drivers';Flags='[R][A]';Description='Reports DriverStore size and PnP driver inventory without deleting drivers.'},
    [pscustomobject]@{No=11;Group='Devices & Drivers';Name='Bluetooth Device Inventory';Flags='[R]';Description='Lists Bluetooth PnP devices for manual review.'},
    [pscustomobject]@{No=40;Group='Devices & Drivers';Name='Print Queue and Spooler';Flags='[R][A]';Description='Reports printers, Print Spooler state and queued spool-file usage.'},
    [pscustomobject]@{No=67;Group='Devices & Drivers';Name='Ghost USB / Storage Device Inventory';Flags='[R][A]';Description='Reports likely non-present USB/storage PnP devices without removing them.'},
    [pscustomobject]@{No=96;Group='Devices & Drivers';Name='Physical Disk Health';Flags='[R][A]';Description='Reports physical-disk health and available storage reliability counters.'},

    # Performance & Memory
    [pscustomobject]@{No=7;Group='Performance & Memory';Name='Pagefile Size and Usage';Flags='[R]';Description='Reports pagefile allocation, current use and peak use.'},
    [pscustomobject]@{No=33;Group='Performance & Memory';Name='Windows Search Index';Flags='[R]';Description='Reports Windows Search database size and service status.'},

    # Power & Sleep
    [pscustomobject]@{No=6;Group='Power & Sleep';Name='Hibernation / hiberfil.sys';Flags='[C][A][!]';Description='Reports hibernation state and hiberfil.sys size; optional disable after confirmation.'},
    [pscustomobject]@{No=47;Group='Power & Sleep';Name='Power Plan and Sleep Configuration';Flags='[R]';Description='Reports the active power plan and available sleep states.'},
    [pscustomobject]@{No=55;Group='Power & Sleep';Name='Battery Health and Capacity Analyzer';Flags='[R]';Description='Estimates battery wear from Windows firmware-reported design/full-charge capacity.'},
    [pscustomobject]@{No=99;Group='Power & Sleep';Name='Modern Standby Support';Flags='[R]';Description='Reports S0 Low Power Idle / Modern Standby support from powercfg.'},
    [pscustomobject]@{No=100;Group='Power & Sleep';Name='Power Requests';Flags='[R][A]';Description='Reports active process/driver requests that can prevent sleep or display-off.'},

    # Diagnostics & Reliability
    [pscustomobject]@{No=19;Group='Diagnostics & Reliability';Name='Large Event Logs';Flags='[R][A]';Description='Finds unusually large Windows event logs.'},
    [pscustomobject]@{No=24;Group='Diagnostics & Reliability';Name='Crash Dump Analyzer';Flags='[C]';Description='Finds old application crash dumps and previews cleanup candidates.'},
    [pscustomobject]@{No=25;Group='Diagnostics & Reliability';Name='Windows Error Reporting';Flags='[C][A]';Description='Measures old WER reports and previews removable report files.'},
    [pscustomobject]@{No=45;Group='Diagnostics & Reliability';Name='Windows Maintenance Logs';Flags='[R][A]';Description='Measures CBS, DISM, MoSetup and Panther servicing/setup logs.'},
    [pscustomobject]@{No=94;Group='Diagnostics & Reliability';Name='Boot Performance Analyzer';Flags='[R]';Description='Reads recent Diagnostics-Performance boot events and boot-duration metrics.'},
    [pscustomobject]@{No=97;Group='Diagnostics & Reliability';Name='WHEA Hardware Error Analyzer';Flags='[R][A]';Description='Reviews recent WHEA-Logger hardware-error events from the System log.'},
    [pscustomobject]@{No=98;Group='Diagnostics & Reliability';Name='Reliability Monitor Analyzer';Flags='[R]';Description='Shows recent Windows reliability records for recurring application/hardware failures.'},

    # Accounts & Access
    [pscustomobject]@{No=54;Group='Accounts & Access';Name='User Profile Inventory';Flags='[R][A][!]';Description='Reports local profiles and flags long-unused, unloaded profiles for manual review.'},
    [pscustomobject]@{No=72;Group='Accounts & Access';Name='Local Account Hygiene';Flags='[R][A][!]';Description='Reports local account state and flags long-unused enabled accounts for manual review.'},

    # Developer & Virtualization
    [pscustomobject]@{No=52;Group='Developer & Virtualization';Name='PowerShell Module Footprint';Flags='[R]';Description='Shows the largest PowerShell module folders and multiple-version footprints.'},
    [pscustomobject]@{No=61;Group='Developer & Virtualization';Name='WSL Distribution and VHDX Footprint';Flags='[R]';Description='Lists WSL distributions and reports common ext4.vhdx disk footprints.'},
    [pscustomobject]@{No=62;Group='Developer & Virtualization';Name='Hyper-V Virtual Disk Footprint';Flags='[R][A]';Description='Reports Hyper-V/common VHD/VHDX files without deleting virtual disks.'},
    [pscustomobject]@{No=66;Group='Developer & Virtualization';Name='Environment Variable Integrity';Flags='[R]';Description='Finds missing absolute path-like user/machine environment-variable values outside PATH.'},

    # v2.0 Extended Windows 11 modules (101-200)
    [pscustomobject]@{No=101;Group='Storage Internals';Name='NTFS Dirty Bit Status';Flags='[R]';Description='Checks fixed volumes for the NTFS dirty bit.'},
    [pscustomobject]@{No=102;Group='Storage Internals';Name='NTFS Compression State';Flags='[R]';Description='Reports compression state on the system drive.'},
    [pscustomobject]@{No=103;Group='Storage Internals';Name='NTFS Reparse Point Inventory';Flags='[R]';Description='Inventories junctions, symbolic links and other reparse points in scoped paths.'},
    [pscustomobject]@{No=104;Group='Storage Internals';Name='Volume Mount Points';Flags='[R]';Description='Reports Windows volume mount points and volume metadata.'},
    [pscustomobject]@{No=105;Group='Storage Internals';Name='Disk Quota Configuration';Flags='[R][A]';Description='Reports NTFS quota configuration for the system volume.'},
    [pscustomobject]@{No=106;Group='Storage Internals';Name='Storage Spaces Pool Health';Flags='[R]';Description='Reports Storage Spaces pool health and allocation.'},
    [pscustomobject]@{No=107;Group='Storage Internals';Name='Storage Spaces Virtual Disks';Flags='[R]';Description='Reports virtual disks, resiliency and health.'},
    [pscustomobject]@{No=108;Group='Storage Internals';Name='Storage Spaces Physical Disks';Flags='[R]';Description='Reports physical disks participating in Storage Spaces.'},
    [pscustomobject]@{No=109;Group='Storage Internals';Name='Shadow Copy Providers';Flags='[R][A]';Description='Lists registered VSS providers.'},
    [pscustomobject]@{No=110;Group='Storage Internals';Name='Shadow Copy Inventory';Flags='[R][A]';Description='Lists current VSS shadow copies without deleting them.'},
    [pscustomobject]@{No=111;Group='Storage Internals';Name='Encrypting File System (EFS) State';Flags='[R]';Description='Reports EFS service state.'},
    [pscustomobject]@{No=112;Group='Storage Internals';Name='CompactOS State';Flags='[R]';Description='Reports whether CompactOS is active.'},
    [pscustomobject]@{No=113;Group='Storage Internals';Name='USN Journal Status';Flags='[R][A]';Description='Reports the NTFS change journal state on the system volume.'},
    [pscustomobject]@{No=114;Group='Storage Internals';Name='ReFS Volume Inventory';Flags='[R]';Description='Reports any ReFS volumes.'},
    [pscustomobject]@{No=115;Group='Storage Internals';Name='Data Deduplication Feature Status';Flags='[R]';Description='Reports Data Deduplication feature availability/state.'},
    [pscustomobject]@{No=116;Group='Storage Internals';Name='Offline Files / CSC Status';Flags='[R]';Description='Reports Offline Files service state.'},
    [pscustomobject]@{No=117;Group='Windows Update & Servicing';Name='Windows Update Policy';Flags='[R]';Description='Reports Windows Update policy values.'},
    [pscustomobject]@{No=118;Group='Windows Update & Servicing';Name='WSUS Configuration';Flags='[R]';Description='Reports WSUS and Automatic Update policy configuration.'},
    [pscustomobject]@{No=119;Group='Windows Update & Servicing';Name='BITS Service Health';Flags='[R]';Description='Reports Background Intelligent Transfer Service health.'},
    [pscustomobject]@{No=120;Group='Windows Update & Servicing';Name='Windows Update Service Health';Flags='[R]';Description='Reports Windows Update service health.'},
    [pscustomobject]@{No=121;Group='Windows Update & Servicing';Name='Update Orchestrator Service Health';Flags='[R]';Description='Reports Update Orchestrator service state.'},
    [pscustomobject]@{No=122;Group='Windows Update & Servicing';Name='Windows Modules Installer Health';Flags='[R]';Description='Reports TrustedInstaller service state.'},
    [pscustomobject]@{No=123;Group='Windows Update & Servicing';Name='Windows Update Medic Service Health';Flags='[R]';Description='Reports Windows Update Medic service state.'},
    [pscustomobject]@{No=124;Group='Windows Update & Servicing';Name='Delivery Optimization Configuration';Flags='[R]';Description='Reports Delivery Optimization policy values.'},
    [pscustomobject]@{No=125;Group='Windows Update & Servicing';Name='Installed Windows Capabilities';Flags='[R][A]';Description='Lists installed Windows capabilities.'},
    [pscustomobject]@{No=126;Group='Windows Update & Servicing';Name='Language Pack Inventory';Flags='[R]';Description='Lists current user language packs/input methods.'},
    [pscustomobject]@{No=127;Group='Windows Update & Servicing';Name='Installed Update Inventory';Flags='[R]';Description='Lists installed hotfix/update inventory.'},
    [pscustomobject]@{No=128;Group='Windows Update & Servicing';Name='Failed Windows Update Event Summary';Flags='[R][A]';Description='Summarizes recent Windows Update client events.'},
    [pscustomobject]@{No=129;Group='Windows Update & Servicing';Name='Pending Servicing Files';Flags='[R][A]';Description='Checks for common pending servicing XML artifacts.'},
    [pscustomobject]@{No=130;Group='Windows Update & Servicing';Name='Optional Feature Payload State';Flags='[R][A]';Description='Reports optional features whose payload has been removed.'},
    [pscustomobject]@{No=131;Group='Boot & Recovery';Name='Recovery Partition Inventory';Flags='[R][A]';Description='Reports Windows recovery partitions.'},
    [pscustomobject]@{No=132;Group='Boot & Recovery';Name='Recovery Volume Capacity';Flags='[R][A]';Description='Reports accessible recovery volume capacity.'},
    [pscustomobject]@{No=133;Group='Boot & Recovery';Name='Boot Manager Timeout';Flags='[R][A]';Description='Reports boot manager BCD settings.'},
    [pscustomobject]@{No=134;Group='Boot & Recovery';Name='BCD Boot Entry Inventory';Flags='[R][A]';Description='Reports all BCD entries.'},
    [pscustomobject]@{No=135;Group='Boot & Recovery';Name='SafeBoot Configuration';Flags='[R][A]';Description='Reports SafeBoot-related BCD state.'},
    [pscustomobject]@{No=136;Group='Boot & Recovery';Name='Boot Logging State';Flags='[R][A]';Description='Reports current BCD boot logging configuration.'},
    [pscustomobject]@{No=137;Group='Boot & Recovery';Name='Task Manager StartupApproved Inventory';Flags='[R][A]';Description='Reports Task Manager startup approval registry state.'},
    [pscustomobject]@{No=138;Group='Boot & Recovery';Name='Crash Dump Boot Configuration';Flags='[R][A]';Description='Reports CrashControl configuration.'},
    [pscustomobject]@{No=139;Group='Boot & Recovery';Name='Automatic Memory Dump Policy';Flags='[R][A]';Description='Reports automatic memory dump policy values.'},
    [pscustomobject]@{No=140;Group='Boot & Recovery';Name='Shutdown and Unexpected Restart Summary';Flags='[R]';Description='Summarizes shutdown, restart and unexpected shutdown events.'},
    [pscustomobject]@{No=141;Group='Network Configuration & Protocols';Name='DNS Server Configuration';Flags='[R]';Description='Reports DNS servers configured on interfaces.'},
    [pscustomobject]@{No=142;Group='Network Configuration & Protocols';Name='DNS-over-HTTPS Configuration';Flags='[R]';Description='Reports Windows DNS-over-HTTPS server templates/configuration.'},
    [pscustomobject]@{No=143;Group='Network Configuration & Protocols';Name='Network Profile Categories';Flags='[R]';Description='Reports Public/Private/Domain network profiles.'},
    [pscustomobject]@{No=144;Group='Network Configuration & Protocols';Name='IPv6 Binding Status';Flags='[R]';Description='Reports IPv6 binding state per network adapter.'},
    [pscustomobject]@{No=145;Group='Network Configuration & Protocols';Name='Interface Metric Analyzer';Flags='[R]';Description='Reports IP interface metrics and MTU.'},
    [pscustomobject]@{No=146;Group='Network Configuration & Protocols';Name='DHCP vs Static IP Inventory';Flags='[R]';Description='Reports DHCP state on IPv4 interfaces.'},
    [pscustomobject]@{No=147;Group='Network Configuration & Protocols';Name='NRPT Rules';Flags='[R]';Description='Reports Name Resolution Policy Table rules.'},
    [pscustomobject]@{No=148;Group='Network Configuration & Protocols';Name='TCP Global Settings';Flags='[R][A]';Description='Reports Windows global TCP settings.'},
    [pscustomobject]@{No=149;Group='Network Configuration & Protocols';Name='TCP Auto-Tuning State';Flags='[R][A]';Description='Highlights TCP receive-window auto-tuning configuration.'},
    [pscustomobject]@{No=150;Group='Network Configuration & Protocols';Name='PortProxy Rules';Flags='[R][A]';Description='Lists netsh interface portproxy rules.'},
    [pscustomobject]@{No=151;Group='Network Configuration & Protocols';Name='Listening TCP Ports';Flags='[R]';Description='Lists listening TCP endpoints.'},
    [pscustomobject]@{No=152;Group='Network Configuration & Protocols';Name='Listening UDP Endpoints';Flags='[R]';Description='Lists UDP endpoints.'},
    [pscustomobject]@{No=153;Group='Network Configuration & Protocols';Name='SMB Client Configuration';Flags='[R][A]';Description='Reports SMB client security and caching settings.'},
    [pscustomobject]@{No=154;Group='Network Configuration & Protocols';Name='SMB Server Configuration';Flags='[R][A]';Description='Reports SMB server protocol and signing settings.'},
    [pscustomobject]@{No=155;Group='Network Configuration & Protocols';Name='LLMNR Policy';Flags='[R]';Description='Reports multicast-name-resolution policy.'},
    [pscustomobject]@{No=156;Group='Network Configuration & Protocols';Name='NetBIOS over TCP/IP State';Flags='[R]';Description='Reports NetBIOS-over-TCP/IP configuration.'},
    [pscustomobject]@{No=157;Group='Network Configuration & Protocols';Name='Internet Connection Sharing Status';Flags='[R]';Description='Reports ICS service state.'},
    [pscustomobject]@{No=158;Group='Network Configuration & Protocols';Name='Mobile Hotspot Service Status';Flags='[R]';Description='Reports Windows Mobile Hotspot service state.'},
    [pscustomobject]@{No=159;Group='Network Configuration & Protocols';Name='Network Location Awareness Health';Flags='[R]';Description='Reports NLA service state.'},
    [pscustomobject]@{No=160;Group='Network Configuration & Protocols';Name='Windows Connection Manager Policy';Flags='[R]';Description='Reports Windows Connection Manager policy values.'},
    [pscustomobject]@{No=161;Group='Identity & Security Policy';Name='User Account Control (UAC) Configuration';Flags='[R]';Description='Reports important UAC security values.'},
    [pscustomobject]@{No=162;Group='Identity & Security Policy';Name='Windows Hello Policy';Flags='[R]';Description='Reports Windows Hello for Business policy.'},
    [pscustomobject]@{No=163;Group='Identity & Security Policy';Name='Local Password Policy';Flags='[R]';Description='Reports local password policy.'},
    [pscustomobject]@{No=164;Group='Identity & Security Policy';Name='Account Lockout Policy';Flags='[R]';Description='Reports local account lockout settings.'},
    [pscustomobject]@{No=165;Group='Identity & Security Policy';Name='Built-in Guest Account Status';Flags='[R]';Description='Reports the built-in Guest account state.'},
    [pscustomobject]@{No=166;Group='Identity & Security Policy';Name='Built-in Administrator Account Status';Flags='[R]';Description='Reports the built-in Administrator account state.'},
    [pscustomobject]@{No=167;Group='Identity & Security Policy';Name='AutoLogon Configuration';Flags='[R]';Description='Checks for Windows automatic logon configuration without reading passwords.'},
    [pscustomobject]@{No=168;Group='Identity & Security Policy';Name='Cached Interactive Logons Policy';Flags='[R]';Description='Reports cached domain-logon count policy.'},
    [pscustomobject]@{No=169;Group='Identity & Security Policy';Name='Advanced Audit Policy Summary';Flags='[R][A]';Description='Reports Windows advanced audit policy.'},
    [pscustomobject]@{No=170;Group='Identity & Security Policy';Name='PowerShell Script Block Logging';Flags='[R]';Description='Reports Script Block Logging policy.'},
    [pscustomobject]@{No=171;Group='Identity & Security Policy';Name='PowerShell Transcription Logging';Flags='[R]';Description='Reports PowerShell transcription policy.'},
    [pscustomobject]@{No=172;Group='Identity & Security Policy';Name='PowerShell Module Logging';Flags='[R]';Description='Reports PowerShell module logging policy.'},
    [pscustomobject]@{No=173;Group='Identity & Security Policy';Name='AppLocker Policy Status';Flags='[R][A]';Description='Reports effective AppLocker rule collection state.'},
    [pscustomobject]@{No=174;Group='Identity & Security Policy';Name='WDAC / Code Integrity Policy State';Flags='[R][A]';Description='Reports Device Guard / Code Integrity enforcement state.'},
    [pscustomobject]@{No=175;Group='Identity & Security Policy';Name='Windows Sandbox Feature';Flags='[R]';Description='Reports Windows Sandbox optional feature state.'},
    [pscustomobject]@{No=176;Group='Identity & Security Policy';Name='Microsoft Defender Application Guard';Flags='[R][A]';Description='Reports Application Guard feature state.'},
    [pscustomobject]@{No=177;Group='Identity & Security Policy';Name='Remote Assistance Status';Flags='[R]';Description='Reports Remote Assistance configuration.'},
    [pscustomobject]@{No=178;Group='Identity & Security Policy';Name='OpenSSH Server Status';Flags='[R]';Description='Reports OpenSSH Server service state.'},
    [pscustomobject]@{No=179;Group='Identity & Security Policy';Name='Remote Registry Status';Flags='[R]';Description='Reports Remote Registry service state.'},
    [pscustomobject]@{No=180;Group='Identity & Security Policy';Name='Credential Manager Target Count';Flags='[R]';Description='Counts stored credential targets without exposing target names or secrets.'},
    [pscustomobject]@{No=181;Group='Identity & Security Policy';Name='NTLM Restriction Policy';Flags='[R]';Description='Reports NTLM traffic restriction/audit policy.'},
    [pscustomobject]@{No=182;Group='Identity & Security Policy';Name='LAN Manager Authentication Level';Flags='[R]';Description='Reports LmCompatibilityLevel.'},
    [pscustomobject]@{No=183;Group='Identity & Security Policy';Name='SMB Guest Logon Policy';Flags='[R]';Description='Reports insecure SMB guest logon policy.'},
    [pscustomobject]@{No=184;Group='Identity & Security Policy';Name='Anonymous Access Restrictions';Flags='[R]';Description='Reports anonymous access restriction values.'},
    [pscustomobject]@{No=185;Group='Identity & Security Policy';Name='AutoRun / AutoPlay Policy';Flags='[R]';Description='Reports machine/user AutoRun policy.'},
    [pscustomobject]@{No=186;Group='Identity & Security Policy';Name='Removable Storage Policy';Flags='[R]';Description='Reports removable-storage restriction policy.'},
    [pscustomobject]@{No=187;Group='Identity & Security Policy';Name='Device Installation Restriction Policy';Flags='[R]';Description='Reports device installation restriction policy.'},
    [pscustomobject]@{No=188;Group='Identity & Security Policy';Name='Windows Security Options Snapshot';Flags='[R]';Description='Reports a focused snapshot of local security options.'},
    [pscustomobject]@{No=189;Group='Identity & Security Policy';Name='Local Privileged Group Membership Review';Flags='[R][A]';Description='Reviews membership of important local privileged groups.'},
    [pscustomobject]@{No=190;Group='Identity & Security Policy';Name='User Rights Assignment Snapshot';Flags='[R][A]';Description='Exports and reports local user-right assignments without changing them.'},
    [pscustomobject]@{No=191;Group='Deep Diagnostics & Event Channels';Name='Windows Event Log Service Health';Flags='[R]';Description='Reports Windows Event Log service state.'},
    [pscustomobject]@{No=192;Group='Deep Diagnostics & Event Channels';Name='Windows Error Reporting Policy';Flags='[R]';Description='Reports WER machine/user policy.'},
    [pscustomobject]@{No=193;Group='Deep Diagnostics & Event Channels';Name='Kernel Crash Dump Configuration';Flags='[R]';Description='Reports kernel crash dump settings.'},
    [pscustomobject]@{No=194;Group='Deep Diagnostics & Event Channels';Name='Windows Memory Diagnostic Results';Flags='[R][A]';Description='Reports recent Windows Memory Diagnostic result events.'},
    [pscustomobject]@{No=195;Group='Deep Diagnostics & Event Channels';Name='LiveKernelReports Footprint';Flags='[R]';Description='Measures LiveKernelReports dump storage.'},
    [pscustomobject]@{No=196;Group='Deep Diagnostics & Event Channels';Name='Reliability Critical Event Summary';Flags='[R]';Description='Reports recent Windows reliability records.'},
    [pscustomobject]@{No=197;Group='Deep Diagnostics & Event Channels';Name='Last Disk Check Results';Flags='[R]';Description='Reports recent Wininit/CHKDSK result events.'},
    [pscustomobject]@{No=198;Group='Deep Diagnostics & Event Channels';Name='Microsoft Defender Operational Event Summary';Flags='[R][A]';Description='Reports recent Defender Operational events.'},
    [pscustomobject]@{No=199;Group='Deep Diagnostics & Event Channels';Name='Windows Firewall Operational Event Summary';Flags='[R][A]';Description='Reports recent Windows Firewall operational events.'},
    [pscustomobject]@{No=200;Group='Deep Diagnostics & Event Channels';Name='Windows Update Operational Event Summary';Flags='[R][A]';Description='Reports recent Windows Update operational events.'},
    [pscustomobject]@{No=201;Group='Certificates & Trust';Name='Local Machine Root CA Store';Flags='[R]';Description='Trusted root CA inventory and expiration visibility.'},
    [pscustomobject]@{No=202;Group='Certificates & Trust';Name='Local Machine Personal Certificates';Flags='[R]';Description='Machine personal certificate inventory.'},
    [pscustomobject]@{No=203;Group='Certificates & Trust';Name='Current User Personal Certificates';Flags='[R]';Description='Current-user personal certificate inventory.'},
    [pscustomobject]@{No=204;Group='Certificates & Trust';Name='Expired Machine Certificates';Flags='[R]';Description='Finds expired certificates across machine stores.'},
    [pscustomobject]@{No=205;Group='Certificates & Trust';Name='Untrusted Certificate Store';Flags='[R]';Description='Reports certificates explicitly placed in the Disallowed store.'},
    [pscustomobject]@{No=206;Group='Certificates & Trust';Name='Code Signing Certificate Inventory';Flags='[R]';Description='Reports code-signing certificates without exporting private keys.'},
    [pscustomobject]@{No=207;Group='Certificates & Trust';Name='Trusted Publishers Store';Flags='[R]';Description='Reports Trusted Publisher certificates.'},
    [pscustomobject]@{No=208;Group='Certificates & Trust';Name='Enterprise Trust Store';Flags='[R]';Description='Reports enterprise trust certificates when present.'},
    [pscustomobject]@{No=209;Group='Certificates & Trust';Name='Certificate Auto-Enrollment Policy';Flags='[R]';Description='Reports machine/user certificate auto-enrollment policy.'},
    [pscustomobject]@{No=210;Group='Certificates & Trust';Name='Cryptographic Services Health';Flags='[R]';Description='Reports Cryptographic Services state.'},
    [pscustomobject]@{No=211;Group='Defender Advanced Security';Name='Defender Network Protection';Flags='[R]';Description='Reports Microsoft Defender Network Protection state.'},
    [pscustomobject]@{No=212;Group='Defender Advanced Security';Name='Defender PUA Protection';Flags='[R]';Description='Reports potentially unwanted application protection.'},
    [pscustomobject]@{No=213;Group='Defender Advanced Security';Name='Defender Cloud Protection';Flags='[R]';Description='Reports cloud-delivered protection settings.'},
    [pscustomobject]@{No=214;Group='Defender Advanced Security';Name='Defender Sample Submission Policy';Flags='[R]';Description='Reports Defender sample-submission consent configuration.'},
    [pscustomobject]@{No=215;Group='Defender Advanced Security';Name='Defender Scan Schedule';Flags='[R]';Description='Reports scheduled scan policy.'},
    [pscustomobject]@{No=216;Group='Defender Advanced Security';Name='Defender Scan CPU Limit';Flags='[R]';Description='Reports Defender scan CPU/performance settings.'},
    [pscustomobject]@{No=217;Group='Defender Advanced Security';Name='Defender Exclusion Extensions';Flags='[R]';Description='Reports excluded file extensions.'},
    [pscustomobject]@{No=218;Group='Defender Advanced Security';Name='Defender Exclusion Processes';Flags='[R]';Description='Reports process exclusions.'},
    [pscustomobject]@{No=219;Group='Defender Advanced Security';Name='CFA Protected Folders';Flags='[R]';Description='Reports Controlled Folder Access protected folders.'},
    [pscustomobject]@{No=220;Group='Defender Advanced Security';Name='Defender Quarantine Retention';Flags='[R]';Description='Reports quarantine and remediation scheduling settings.'},
    [pscustomobject]@{No=221;Group='Device Security & Driver Integrity';Name='Boot Integrity Flags';Flags='[R]';Description='Reports current BCD integrity-related options.'},
    [pscustomobject]@{No=222;Group='Device Security & Driver Integrity';Name='Kernel Driver Blocklist Policy';Flags='[R]';Description='Reports vulnerable-driver blocklist policy.'},
    [pscustomobject]@{No=223;Group='Device Security & Driver Integrity';Name='Device Guard Security Properties';Flags='[R]';Description='Reports Win32_DeviceGuard security properties.'},
    [pscustomobject]@{No=224;Group='Device Security & Driver Integrity';Name='Unsigned PnP Driver Inventory';Flags='[R]';Description='Reports unsigned PnP signed-driver records.'},
    [pscustomobject]@{No=225;Group='Device Security & Driver Integrity';Name='Problem PnP Devices';Flags='[R]';Description='Reports devices with problem/error state.'},
    [pscustomobject]@{No=226;Group='Device Security & Driver Integrity';Name='Driver Verifier Configuration';Flags='[R]';Description='Reports Driver Verifier settings.'},
    [pscustomobject]@{No=227;Group='Device Security & Driver Integrity';Name='Third-Party Driver Package Inventory';Flags='[R]';Description='Reports PnP driver packages using pnputil.'},
    [pscustomobject]@{No=228;Group='Device Security & Driver Integrity';Name='Driver Search and Update Policy';Flags='[R]';Description='Reports driver search/update policy.'},
    [pscustomobject]@{No=229;Group='Device Security & Driver Integrity';Name='Kernel PnP Error Events';Flags='[R]';Description='Reports recent Kernel-PnP errors.'},
    [pscustomobject]@{No=230;Group='Device Security & Driver Integrity';Name='Device Metadata Retrieval Policy';Flags='[R]';Description='Reports device metadata network-retrieval policy.'},
    [pscustomobject]@{No=231;Group='Group Policy & Enterprise Configuration';Name='Applied Computer Group Policy Summary';Flags='[R]';Description='Reports applied computer Group Policy summary.'},
    [pscustomobject]@{No=232;Group='Group Policy & Enterprise Configuration';Name='Applied User Group Policy Summary';Flags='[R]';Description='Reports applied user Group Policy summary.'},
    [pscustomobject]@{No=233;Group='Group Policy & Enterprise Configuration';Name='Windows Update for Business Policy';Flags='[R]';Description='Reports WUfB deferral/pause policy.'},
    [pscustomobject]@{No=234;Group='Group Policy & Enterprise Configuration';Name='OneDrive Enterprise Policy';Flags='[R]';Description='Reports enterprise OneDrive policy.'},
    [pscustomobject]@{No=235;Group='Group Policy & Enterprise Configuration';Name='Microsoft Edge Policy Snapshot';Flags='[R]';Description='Reports selected Microsoft Edge machine policies.'},
    [pscustomobject]@{No=236;Group='Group Policy & Enterprise Configuration';Name='Defender Policy Registry Snapshot';Flags='[R]';Description='Reports selected Defender policy registry values.'},
    [pscustomobject]@{No=237;Group='Group Policy & Enterprise Configuration';Name='Windows Hello for Business Policy';Flags='[R]';Description='Reports PassportForWork/WHfB policy.'},
    [pscustomobject]@{No=238;Group='Group Policy & Enterprise Configuration';Name='Remote Desktop Group Policy';Flags='[R]';Description='Reports Terminal Services/RDP policy.'},
    [pscustomobject]@{No=239;Group='Group Policy & Enterprise Configuration';Name='MDM Enrollment Registry Inventory';Flags='[R]';Description='Reports enrollment registry key inventory.'},
    [pscustomobject]@{No=240;Group='Group Policy & Enterprise Configuration';Name='PolicyManager Device Policy Snapshot';Flags='[R]';Description='Reports top-level PolicyManager device values.'},
    [pscustomobject]@{No=241;Group='File System & Data Protection';Name='Win32 Long Path Support';Flags='[R]';Description='Reports Win32 long-path support.'},
    [pscustomobject]@{No=242;Group='File System & Data Protection';Name='NTFS 8.3 Name Creation State';Flags='[R]';Description='Reports NTFS 8.3 name-creation behavior.'},
    [pscustomobject]@{No=243;Group='File System & Data Protection';Name='NTFS Last Access Timestamp Policy';Flags='[R]';Description='Reports NTFS last-access timestamp policy.'},
    [pscustomobject]@{No=244;Group='File System & Data Protection';Name='NTFS Symlink Evaluation Policy';Flags='[R]';Description='Reports symbolic-link evaluation policy.'},
    [pscustomobject]@{No=245;Group='File System & Data Protection';Name='EFS Current User Certificate Status';Flags='[R]';Description='Reports the current-user EFS certificate.'},
    [pscustomobject]@{No=246;Group='File System & Data Protection';Name='File History Service Status';Flags='[R]';Description='Reports File History service state.'},
    [pscustomobject]@{No=247;Group='File System & Data Protection';Name='Work Folders Service Status';Flags='[R]';Description='Reports Work Folders service state.'},
    [pscustomobject]@{No=248;Group='File System & Data Protection';Name='Offline Files Configuration';Flags='[R]';Description='Reports Offline Files/CSC configuration.'},
    [pscustomobject]@{No=249;Group='File System & Data Protection';Name='System Restore Configuration';Flags='[R]';Description='Reports System Restore policy/settings.'},
    [pscustomobject]@{No=250;Group='File System & Data Protection';Name='Windows Backup Operational Events';Flags='[R]';Description='Reports recent Windows backup events.'},
    [pscustomobject]@{No=251;Group='Advanced Networking & Remote Access';Name='Windows Firewall Logging Configuration';Flags='[R]';Description='Reports firewall log paths and logging settings.'},
    [pscustomobject]@{No=252;Group='Advanced Networking & Remote Access';Name='IPsec Rule Inventory';Flags='[R]';Description='Reports active IPsec rules.'},
    [pscustomobject]@{No=253;Group='Advanced Networking & Remote Access';Name='IPsec Main Mode Rule Inventory';Flags='[R]';Description='Reports active IPsec Main Mode rules.'},
    [pscustomobject]@{No=254;Group='Advanced Networking & Remote Access';Name='DNS Client Service Health';Flags='[R]';Description='Reports DNS Client service state.'},
    [pscustomobject]@{No=255;Group='Advanced Networking & Remote Access';Name='WPAD and Proxy Auto-Discovery Policy';Flags='[R]';Description='Reports WPAD/PAC/proxy auto-discovery configuration.'},
    [pscustomobject]@{No=256;Group='Advanced Networking & Remote Access';Name='HTTP.sys URL Reservations';Flags='[R]';Description='Reports HTTP.sys URL ACL reservations.'},
    [pscustomobject]@{No=257;Group='Advanced Networking & Remote Access';Name='HTTP.sys SSL Certificate Bindings';Flags='[R]';Description='Reports HTTP.sys SSL certificate bindings.'},
    [pscustomobject]@{No=258;Group='Advanced Networking & Remote Access';Name='WinRM Listener Inventory';Flags='[R]';Description='Reports configured WinRM listeners.'},
    [pscustomobject]@{No=259;Group='Advanced Networking & Remote Access';Name='Remote Desktop Firewall Rules';Flags='[R]';Description='Reports firewall rules associated with Remote Desktop.'},
    [pscustomobject]@{No=260;Group='Advanced Networking & Remote Access';Name='Terminal Session Inventory';Flags='[R]';Description='Reports current terminal sessions without disconnecting users.'},
    [pscustomobject]@{No=261;Group='Windows Apps & Runtime Components';Name='Installed .NET Runtimes';Flags='[R]';Description='Reports installed modern .NET runtimes.'},
    [pscustomobject]@{No=262;Group='Windows Apps & Runtime Components';Name='Installed .NET SDKs';Flags='[R]';Description='Reports installed .NET SDKs.'},
    [pscustomobject]@{No=263;Group='Windows Apps & Runtime Components';Name='Visual C++ Redistributable Inventory';Flags='[R]';Description='Reports installed Microsoft Visual C++ redistributables.'},
    [pscustomobject]@{No=264;Group='Windows Apps & Runtime Components';Name='Edge WebView2 Runtime Inventory';Flags='[R]';Description='Reports installed WebView2 runtime packages.'},
    [pscustomobject]@{No=265;Group='Windows Apps & Runtime Components';Name='Installed PowerShell Editions';Flags='[R]';Description='Reports Windows PowerShell and PowerShell availability.'},
    [pscustomobject]@{No=266;Group='Windows Apps & Runtime Components';Name='Windows Terminal Package Status';Flags='[R]';Description='Reports Windows Terminal Appx package state.'},
    [pscustomobject]@{No=267;Group='Windows Apps & Runtime Components';Name='Windows Package Manager Version';Flags='[R]';Description='Reports winget availability/version.'},
    [pscustomobject]@{No=268;Group='Windows Apps & Runtime Components';Name='OpenSSH Client Capability';Flags='[R]';Description='Reports OpenSSH Client capability state.'},
    [pscustomobject]@{No=269;Group='Windows Apps & Runtime Components';Name='OpenSSH Server Capability';Flags='[R]';Description='Reports OpenSSH Server capability state.'},
    [pscustomobject]@{No=270;Group='Windows Apps & Runtime Components';Name='App Installer Package Health';Flags='[R]';Description='Reports Microsoft Desktop App Installer package state.'},
    [pscustomobject]@{No=271;Group='System Services & Management';Name='Windows Management Instrumentation Health';Flags='[R]';Description='Reports Winmgmt service state.'},
    [pscustomobject]@{No=272;Group='System Services & Management';Name='RPC and DCOM Core Service Health';Flags='[R]';Description='Reports RPC/DCOM core service states.'},
    [pscustomobject]@{No=273;Group='System Services & Management';Name='DCOM Security Configuration';Flags='[R]';Description='Reports selected DCOM machine security settings.'},
    [pscustomobject]@{No=274;Group='System Services & Management';Name='Task Scheduler Service Health';Flags='[R]';Description='Reports Task Scheduler service state.'},
    [pscustomobject]@{No=275;Group='System Services & Management';Name='BITS Service Health';Flags='[R]';Description='Reports Background Intelligent Transfer Service state.'},
    [pscustomobject]@{No=276;Group='System Services & Management';Name='Windows Installer Service Health';Flags='[R]';Description='Reports Windows Installer service state.'},
    [pscustomobject]@{No=277;Group='System Services & Management';Name='COM+ Event System Health';Flags='[R]';Description='Reports COM+ Event System services.'},
    [pscustomobject]@{No=278;Group='System Services & Management';Name='User Profile Service Health';Flags='[R]';Description='Reports User Profile and User Manager services.'},
    [pscustomobject]@{No=279;Group='System Services & Management';Name='Application Information Service Health';Flags='[R]';Description='Reports Appinfo/UAC support service state.'},
    [pscustomobject]@{No=280;Group='System Services & Management';Name='Windows Licensing Service Health';Flags='[R]';Description='Reports Windows licensing-related services.'},
    [pscustomobject]@{No=281;Group='User Experience & Privacy';Name='File Explorer Search History Policy';Flags='[R]';Description='Reports Explorer search-history policy/presence.'},
    [pscustomobject]@{No=282;Group='User Experience & Privacy';Name='Recent Documents Policy';Flags='[R]';Description='Reports Recent Documents privacy policy.'},
    [pscustomobject]@{No=283;Group='User Experience & Privacy';Name='Windows Location Service Status';Flags='[R]';Description='Reports Windows Geolocation Service state.'},
    [pscustomobject]@{No=284;Group='User Experience & Privacy';Name='Camera Consent Configuration';Flags='[R]';Description='Reports user camera-consent configuration.'},
    [pscustomobject]@{No=285;Group='User Experience & Privacy';Name='Microphone Consent Configuration';Flags='[R]';Description='Reports user microphone-consent configuration.'},
    [pscustomobject]@{No=286;Group='User Experience & Privacy';Name='Windows Notification Configuration';Flags='[R]';Description='Reports notification/toast configuration.'},
    [pscustomobject]@{No=287;Group='User Experience & Privacy';Name='Windows Web Experience Pack Status';Flags='[R]';Description='Reports Web Experience Pack package state.'},
    [pscustomobject]@{No=288;Group='User Experience & Privacy';Name='Windows Copilot Policy';Flags='[R]';Description='Reports Windows Copilot policy values when present.'},
    [pscustomobject]@{No=289;Group='User Experience & Privacy';Name='Windows AI / Recall Policy Snapshot';Flags='[R]';Description='Reports Windows AI/Recall-related policy values when present.'},
    [pscustomobject]@{No=290;Group='User Experience & Privacy';Name='Consumer Experiences and Suggested Content';Flags='[R]';Description='Reports consumer-experience and suggested-content policy.'},
    [pscustomobject]@{No=291;Group='Advanced Diagnostics & Performance';Name='Processor Topology Inventory';Flags='[R]';Description='Reports CPU topology and virtualization capabilities.'},
    [pscustomobject]@{No=292;Group='Advanced Diagnostics & Performance';Name='Hypervisor Presence';Flags='[R]';Description='Reports Windows hypervisor-presence state.'},
    [pscustomobject]@{No=293;Group='Advanced Diagnostics & Performance';Name='System Uptime and Last Boot';Flags='[R]';Description='Reports OS boot time and memory baseline.'},
    [pscustomobject]@{No=294;Group='Advanced Diagnostics & Performance';Name='Memory Device Inventory';Flags='[R]';Description='Reports physical memory module inventory.'},
    [pscustomobject]@{No=295;Group='Advanced Diagnostics & Performance';Name='Disk Performance Snapshot';Flags='[R]';Description='Collects a one-second disk counter snapshot.'},
    [pscustomobject]@{No=296;Group='Advanced Diagnostics & Performance';Name='Top Memory Processes Snapshot';Flags='[R]';Description='Reports top processes by working set.'},
    [pscustomobject]@{No=297;Group='Advanced Diagnostics & Performance';Name='Top CPU Processes Snapshot';Flags='[R]';Description='Reports top processes by cumulative CPU time.'},
    [pscustomobject]@{No=298;Group='Advanced Diagnostics & Performance';Name='System Error Event Summary';Flags='[R]';Description='Reports recent System log events for triage.'},
    [pscustomobject]@{No=299;Group='Advanced Diagnostics & Performance';Name='Application Error Event Summary';Flags='[R]';Description='Reports recent Application log events for triage.'},
    [pscustomobject]@{No=300;Group='Advanced Diagnostics & Performance';Name='Device Setup Manager Event Summary';Flags='[R]';Description='Reports recent Device Setup Manager events.'}

)

$Script:GroupCatalog = @(
    [pscustomobject]@{No=1;Name='Disk & Storage';Description='Disk-space recovery, old files, caches, duplicates, volume health and TRIM.'},
    [pscustomobject]@{No=2;Name='Windows Update & Servicing';Description='Windows Update, component store, SFC/DISM, servicing state, capabilities and reserved storage.'},
    [pscustomobject]@{No=3;Name='Boot & Recovery';Description='WinRE, BCD, restore points and boot/recovery configuration.'},
    [pscustomobject]@{No=4;Name='Startup & Shell';Description='Startup entries, shell extensions, scheduled tasks, services, COM, shortcuts and PATH.'},
    [pscustomobject]@{No=5;Name='Applications & Caches';Description='Appx, browsers, OneDrive, Office, Store, Outlook, Teams and Explorer/application caches.'},
    [pscustomobject]@{No=6;Name='Network & Connectivity';Description='Wi-Fi, DNS, VPN/proxy, routes, adapters, SMB mappings/shares and time synchronization.'},
    [pscustomobject]@{No=7;Name='Windows Security';Description='Secure Boot, TPM, Defender, firewall, VBS, HVCI, Credential Guard and remote-access posture.'},
    [pscustomobject]@{No=8;Name='Privacy';Description='Advertising/diagnostic settings, clipboard/activity history and diagnostic-data storage.'},
    [pscustomobject]@{No=9;Name='Devices & Drivers';Description='DriverStore, Bluetooth, printers, ghost devices and physical storage health.'},
    [pscustomobject]@{No=10;Name='Performance & Memory';Description='Pagefile, Search indexing and memory/performance-related OS state.'},
    [pscustomobject]@{No=11;Name='Power & Sleep';Description='Hibernation, battery, power plans, Modern Standby and active power requests.'},
    [pscustomobject]@{No=12;Name='Diagnostics & Reliability';Description='Event logs, crash data, maintenance logs, boot performance, WHEA and Reliability Monitor.'},
    [pscustomobject]@{No=13;Name='Accounts & Access';Description='Local user profiles and local-account hygiene review.'},
    [pscustomobject]@{No=14;Name='Developer & Virtualization';Description='PowerShell modules, WSL, Hyper-V and developer environment integrity.'},
    [pscustomobject]@{No=15;Name='Storage Internals';Description='NTFS internals, Storage Spaces, VSS, EFS, CompactOS and Offline Files.'},
    [pscustomobject]@{No=16;Name='Network Configuration & Protocols';Description='DNS, IPv6, TCP, SMB, NRPT, portproxy, metrics and Windows networking policies.'},
    [pscustomobject]@{No=17;Name='Identity & Security Policy';Description='UAC, Windows Hello, local security policy, PowerShell logging, AppLocker, NTLM and access controls.'},
    [pscustomobject]@{No=18;Name='Deep Diagnostics & Event Channels';Description='Memory diagnostics, live-kernel reports, WER, disk-check, Defender, firewall and update event channels.'},
    [pscustomobject]@{No=19;Name='Certificates & Trust';Description='Certificate stores, trust anchors, code-signing certificates and cryptographic service posture.'},
    [pscustomobject]@{No=20;Name='Defender Advanced Security';Description='Advanced Microsoft Defender configuration, exclusions, cloud protection and ransomware controls.'},
    [pscustomobject]@{No=21;Name='Device Security & Driver Integrity';Description='Driver integrity, Device Guard, PnP problems, Driver Verifier and driver policy.'},
    [pscustomobject]@{No=22;Name='Group Policy & Enterprise Configuration';Description='Applied Group Policy, MDM/PolicyManager and enterprise Windows configuration.'},
    [pscustomobject]@{No=23;Name='File System & Data Protection';Description='NTFS behavior, EFS, File History, Work Folders, Offline Files and recovery configuration.'},
    [pscustomobject]@{No=24;Name='Advanced Networking & Remote Access';Description='IPsec, HTTP.sys, WinRM, RDP firewall exposure, WPAD and terminal sessions.'},
    [pscustomobject]@{No=25;Name='Windows Apps & Runtime Components';Description='Modern .NET, Visual C++, WebView2, PowerShell, Terminal, winget and Windows capabilities.'},
    [pscustomobject]@{No=26;Name='System Services & Management';Description='Core Windows management, RPC/DCOM, Task Scheduler, BITS, Installer and licensing services.'},
    [pscustomobject]@{No=27;Name='User Experience & Privacy';Description='Location, camera, microphone, notifications, Copilot/AI and consumer-experience configuration.'},
    [pscustomobject]@{No=28;Name='Advanced Diagnostics & Performance';Description='CPU, memory, hypervisor, process, performance-counter and event-log diagnostics.'}

)

$Script:ReportsMenuNumber = $Script:GroupCatalog.Count + 1


function Test-ResultNeedsAttention {
    param([Parameter(Mandatory)][object]$Result)
    $status = [string]$Result.Status
    return ($status -match '(?i)(warning|review|error|missing|broken|orphan|stale|pending|large|low space|health warning|failed|suspicious|invalid|unprotected|unencrypted)')
}

function Get-CleanupCandidateResults {
    param([object[]]$Rows = @())
    $cleanupModules = @(
        $Script:ModuleCatalog |
            Where-Object { ([string]$_.Flags).Contains('[C]') } |
            Select-Object -ExpandProperty No
    )
    return @(
        $Rows | Where-Object {
            ($cleanupModules -contains [int]$_.Module) -and
            ([string]$_.Status -notmatch '^(?i)(healthy|clear|info|present|system|active|enabled|not found|no data|unavailable)$')
        }
    )
}

function Show-ResultRows {
    param(
        [object[]]$Rows = @(),
        [string]$Title = 'Result Records'
    )
    Write-Title $Title
    $items = @($Rows)
    if ($items.Count -eq 0) {
        Write-Host 'No matching result records.' -ForegroundColor Green
        return
    }
    Write-Host ("Total records: {0}" -f $items.Count) -ForegroundColor Cyan
    Write-Host ''
    $view = @($items | Select-Object Module,Category,Item,Status,Size,Details,Recommendation)
    if ($view.Count -gt 35) {
        Write-Host 'Paged view: Space/Enter continues, Q closes the view.' -ForegroundColor DarkGray
        $view | Format-Table -Wrap -AutoSize | Out-Host -Paging
    } else {
        $view | Format-Table -Wrap -AutoSize | Out-Host
    }
}

function Show-ScanDashboard {
    param(
        [object[]]$Rows = @(),
        [string]$Context = 'Scan Results'
    )
    $items = @($Rows)
    $attention = @($items | Where-Object { Test-ResultNeedsAttention $_ })
    $cleanup = @(Get-CleanupCandidateResults -Rows $items)

    Write-Host ''
    Write-Host ('=' * 78) -ForegroundColor Cyan
    Write-Host ("  {0}" -f $Context) -ForegroundColor Cyan
    Write-Host ('=' * 78) -ForegroundColor Cyan
    Write-Host ("  Result records      : {0}" -f $items.Count) -ForegroundColor White
    Write-Host ("  Attention findings  : {0}" -f $attention.Count) -ForegroundColor Yellow
    Write-Host ("  Cleanup candidates  : {0}" -f $cleanup.Count) -ForegroundColor Green

    $statusSummary = @($items | Group-Object Status | Sort-Object Count -Descending | Select-Object Count,Name)
    if ($statusSummary.Count -gt 0) {
        Write-Host ''
        $statusSummary | Format-Table -AutoSize | Out-Host
    }
}

function Show-PostScanActions {
    param(
        [object[]]$Rows = @(),
        [string]$Context = 'Scan Results'
    )
    do {
        $items = @($Rows)
        $attention = @($items | Where-Object { Test-ResultNeedsAttention $_ })
        $cleanup = @(Get-CleanupCandidateResults -Rows $items)

        Show-ScanDashboard -Rows $items -Context $Context
        Write-Host ''
        Write-Host ' [V] View attention findings' -ForegroundColor Yellow
        Write-Host ' [A] View all result records' -ForegroundColor White
        Write-Host ' [C] View cleanup candidates' -ForegroundColor Green
        Write-Host ' [E] Export current in-memory report' -ForegroundColor Cyan
        Write-Host ' [B] Back' -ForegroundColor DarkGray
        Write-Host ''
        $choice = (Read-Host 'Selection').Trim()
        switch -Regex ($choice) {
            '^(?i:V)$' { Show-ResultRows -Rows $attention -Title 'Attention Findings'; Pause-Detox }
            '^(?i:A)$' { Show-ResultRows -Rows $items -Title 'All Result Records'; Pause-Detox }
            '^(?i:C)$' {
                Show-ResultRows -Rows $cleanup -Title 'Cleanup Candidates'
                Write-Host ''
                Write-Host 'Cleanup candidates are informational here. Run the related cleanup-capable module individually to preview and confirm an action.' -ForegroundColor Yellow
                Pause-Detox
            }
            '^(?i:E)$' { Export-DetoxReport; Pause-Detox }
            '^(?i:B)$' { return }
            default { Write-Host 'Invalid selection.' -ForegroundColor Red; Start-Sleep -Milliseconds 600 }
        }
    } while ($true)
}

function Show-ModuleCompletion {
    param(
        [Parameter(Mandatory)][int]$ModuleNumber,
        [Parameter(Mandatory)][int]$BeforeCount
    )

    $afterCount = $Script:Results.Count
    $added = [math]::Max(0, $afterCount - $BeforeCount)
    $meta = $Script:ModuleCatalog | Where-Object No -eq $ModuleNumber | Select-Object -First 1

    Write-Host ''
    Write-Host ('-' * 78) -ForegroundColor DarkGray
    if ($added -eq 0) {
        Write-Host 'Scan completed - no findings matched this module''s criteria.' -ForegroundColor Green
    } else {
        Write-Host ("Scan completed - {0} result record(s) added." -f $added) -ForegroundColor Green
    }
    if ($meta) {
        Write-Host ("Module: {0}" -f $meta.Name) -ForegroundColor DarkGray
    }
}

function Invoke-InteractiveModule {
    param([Parameter(Mandatory)][int]$Number)

    $meta = $Script:ModuleCatalog | Where-Object No -eq $Number | Select-Object -First 1
    if (-not $meta) { throw "Unknown module number: $Number" }

    Write-Title $meta.Name
    Write-Host ("About : {0}" -f $meta.Description) -ForegroundColor DarkGray
    Write-Host ("Mode  : {0}" -f $meta.Flags) -ForegroundColor DarkGray
    Write-Host ''

    $before = $Script:Results.Count
    Invoke-ModuleByNumber -Number $Number
    Show-ModuleCompletion -ModuleNumber $Number -BeforeCount $before
}

function Invoke-ScanSelection {
    param(
        [Parameter(Mandatory)][int[]]$Numbers,
        [Parameter(Mandatory)][string]$Title
    )

    Write-Title $Title
    $Script:Results.Clear()
    Write-Host 'Batch scans always run in REPORT-ONLY mode. No cleanup prompt is displayed.' -ForegroundColor Green
    Write-Host 'Detailed records are kept in memory and can be viewed from Reports > Show all result records.' -ForegroundColor DarkGray
    Write-Host ''

    $total = $Numbers.Count
    $current = 0
    $Script:BatchMode = $true

    try {
        foreach ($n in $Numbers) {
            $current++
            $meta = $Script:ModuleCatalog | Where-Object No -eq $n | Select-Object -First 1
            Write-ScanProgress -Current ($current-1) -Total $total -Activity ("Running: {0}" -f $meta.Name) -Transient

            try {
                Invoke-ModuleByNumber -Number $n -ReportOnly 6>$null | Out-Null
            } catch {
                Write-Log ("Module {0} ({1}) failed: {2}" -f $n,$meta.Name,$_.Exception.Message) 'ERROR'
                [void](Add-Result $n 'ModuleError' $meta.Name 'Error' $_.Exception.Message 'Run the module individually for details.')
            }

            Write-ScanProgress -Current $current -Total $total -Activity ("Completed: {0}" -f $meta.Name)
        }
    } finally {
        $Script:BatchMode = $false
    }

    Write-Title ("{0} - Complete" -f $Title)
    Write-Host ("Total result records: {0}" -f $Script:Results.Count) -ForegroundColor Green

    $summary = @(
        $Script:Results |
            Group-Object Module,Category |
            Select-Object @{N='Module/Category';E={$_.Name}},Count
    )

    if ($summary.Count -gt 0) {
        $summary | Format-Table -AutoSize | Out-Host
    } else {
        Write-Host 'Scan completed successfully. No findings matched the selected modules.' -ForegroundColor Green
    }

    Write-Host ''
    Write-Host 'Use Reports > Show all current result records at any time.' -ForegroundColor Cyan
    Show-PostScanActions -Rows @($Script:Results) -Context $Title
}

function Invoke-ScanAll {
    $numbers = @($Script:ModuleCatalog | Sort-Object No | Select-Object -ExpandProperty No)
    Invoke-ScanSelection -Numbers $numbers -Title ("Scanning All {0} Modules" -f $numbers.Count)
}

function Show-Legend {
    Write-Title 'Legend'
    Write-Host '[R] Report only' -ForegroundColor Cyan
    Write-Host '[C] Cleanup available after preview and confirmation' -ForegroundColor Green
    Write-Host '[A] Administrator rights may be required' -ForegroundColor Yellow
    Write-Host '[!] Higher-impact action; additional confirmation is used' -ForegroundColor Red
    Write-Host ''
    Write-Host 'Group menus use LOCAL numbering starting from 1.' -ForegroundColor DarkGray
    Write-Host 'Internal module IDs are hidden from the menu and are used only in reports/logs.' -ForegroundColor DarkGray
    Pause-Detox
}

function Show-GroupMenu {
    param([Parameter(Mandatory)][string]$GroupName)

    do {
        Write-Title $GroupName
        $mods = @($Script:ModuleCatalog | Where-Object Group -eq $GroupName)

        if ($mods.Count -eq 0) {
            Write-Host 'No modules are registered in this group.' -ForegroundColor Yellow
            Pause-Detox
            return
        }

        for ($i = 0; $i -lt $mods.Count; $i++) {
            $m = $mods[$i]
            Write-Host (" [{0,2}] {1,-43} {2}" -f ($i+1),$m.Name,$m.Flags) -ForegroundColor White
            Write-Host ("      {0}" -f $m.Description) -ForegroundColor DarkGray
        }

        Write-Host ''
        Write-Host (" [A] Scan this group ({0} modules, report-only)" -f $mods.Count) -ForegroundColor Green
        Write-Host ' [L] Legend' -ForegroundColor Cyan
        Write-Host ' [P] Test spinner and progress bar' -ForegroundColor Cyan
        Write-Host ' [B] Back' -ForegroundColor Yellow
        Write-Host ''

        $choice = (Read-Host 'Selection').Trim()

        if ($choice -match '^(?i:B)$') { return }
        if ($choice -match '^(?i:L)$') { Show-Legend; continue }
        if ($choice -match '^(?i:A)$') {
            Invoke-ScanSelection -Numbers @($mods.No) -Title ("Scanning Group: {0}" -f $GroupName)
            continue
        }

        if ($choice -match '^\d+$') {
            $localIndex = [int]$choice
            if ($localIndex -ge 1 -and $localIndex -le $mods.Count) {
                $selected = $mods[$localIndex - 1]
                try {
                    Invoke-InteractiveModule -Number $selected.No
                } catch {
                    Write-Host $_.Exception.Message -ForegroundColor Red
                }
                Pause-Detox
            } else {
                Write-Host ("Enter a number from 1 to {0}." -f $mods.Count) -ForegroundColor Red
                Start-Sleep -Milliseconds 700
            }
        } else {
            Write-Host 'Invalid selection.' -ForegroundColor Red
            Start-Sleep -Milliseconds 700
        }
    } while ($true)
}

function Show-ReportsMenu {
    do {
        Write-Title 'Reports'
        Write-Host (" Current in-memory results : {0}" -f $Script:Results.Count) -ForegroundColor DarkGray
        Write-Host ''
        Write-Host ' [1] Export current results to CSV + JSON + TXT'
        Write-Host ' [2] Open last TXT report in Notepad'
        Write-Host ' [3] Show current result summary'
        Write-Host ' [4] Show all current result records'
        Write-Host ' [5] Show cleanup candidates'
        Write-Host ' [B] Back'
        Write-Host ''

        $choice = (Read-Host 'Selection').Trim()

        switch -Regex ($choice) {
            '^1$' { Export-DetoxReport; Pause-Detox }
            '^2$' { Open-LastDetoxReport; Pause-Detox }
            '^3$' {
                Write-Host ''
                if ($Script:Results.Count -eq 0) {
                    Write-Host 'There are no in-memory scan results yet.' -ForegroundColor Yellow
                } else {
                    $Script:Results |
                        Group-Object Module,Status |
                        Sort-Object Count -Descending |
                        Select-Object Count,Name |
                        Format-Table -AutoSize |
                        Out-Host
                }
                Pause-Detox
            }
            '^4$' { Show-AllCurrentResults; Pause-Detox }
            '^5$' { Show-ResultRows -Rows @(Get-CleanupCandidateResults -Rows @($Script:Results)) -Title 'Cleanup Candidates'; Pause-Detox }
            '^(?i:B)$' { return }
            default { Write-Host 'Invalid selection.' -ForegroundColor Red; Start-Sleep -Milliseconds 700 }
        }
    } while ($true)
}

# ---------------------------------------------------------------------------
# Main menu
# ---------------------------------------------------------------------------
function Show-MainMenu {
    do {
        Write-BrandBanner -Section 'INTERACTIVE CONSOLE'

        $adminText = if (Test-IsAdministrator) { 'YES' } else { 'NO' }
        $adminColor = if (Test-IsAdministrator) { 'Green' } else { 'Yellow' }

        Write-Host 'Host:' -NoNewline -ForegroundColor DarkGray
        Write-Host (" {0}" -f $env:COMPUTERNAME) -NoNewline -ForegroundColor White
        Write-Host '   User:' -NoNewline -ForegroundColor DarkGray
        Write-Host (" {0}" -f $env:USERNAME) -NoNewline -ForegroundColor White
        Write-Host '   Admin:' -NoNewline -ForegroundColor DarkGray
        Write-Host (" {0}" -f $adminText) -NoNewline -ForegroundColor $adminColor
        Write-Host '   PS:' -NoNewline -ForegroundColor DarkGray
        Write-Host (" {0}" -f $PSVersionTable.PSVersion) -ForegroundColor White

        Write-Host ("Modules: {0}   Groups: {1}   Results in memory: {2}" -f $Script:ModuleCatalog.Count,$Script:GroupCatalog.Count,$Script:Results.Count) -ForegroundColor DarkGray
        Write-Host 'Windows 11 expansion: Update/Servicing | Boot/Recovery | Security Posture | Reliability | Power' -ForegroundColor DarkGray
        Write-Host ''

        Write-Host 'Commands:' -ForegroundColor White
        Write-Host '  A   Scan all modules (report-only)       H   Command help' -ForegroundColor Green
        Write-Host '  V   View attention findings              P   Progress test' -ForegroundColor Cyan
        Write-Host '  M   List all modules                      C   Clear results' -ForegroundColor Cyan
        Write-Host '  G   List groups                           Q   Exit' -ForegroundColor Cyan
        Write-Host ''

        Write-Host 'Scan groups:' -ForegroundColor White
        foreach ($g in $Script:GroupCatalog) {
            $count = @($Script:ModuleCatalog | Where-Object Group -eq $g.Name).Count
            Write-Host (" [{0,2}] {1,-34} {2,2} modules" -f $g.No,$g.Name,$count) -ForegroundColor White
        }

        Write-Host (" [{0,2}] Reports" -f $Script:ReportsMenuNumber) -ForegroundColor White
        Write-Host ''
        Write-Host 'Selection / command:' -NoNewline -ForegroundColor DarkGray
        $choice = (Read-Host).Trim()

        if ($choice -match '^\d+$') {
            $n = [int]$choice
            if ($n -ge 1 -and $n -le $Script:GroupCatalog.Count) {
                $group = $Script:GroupCatalog | Where-Object No -eq $n | Select-Object -First 1
                Show-GroupMenu -GroupName $group.Name
                continue
            }
            if ($n -eq $Script:ReportsMenuNumber) {
                Show-ReportsMenu
                continue
            }
        }

        switch -Regex ($choice) {
            '^(?i:A|scan-all)$' { Invoke-ScanAll }
            '^(?i:V|findings)$' { Show-ResultRows -Rows @(Get-AttentionResults -Rows @($Script:Results)) -Title 'Attention Findings'; Pause-Detox }
            '^(?i:M|list-modules)$' { Show-CliModuleList; Pause-Detox }
            '^(?i:G|list-groups)$' { Show-CliGroupList; Pause-Detox }
            '^(?i:H|help)$' { Show-CommandHelp; Pause-Detox }
            '^(?i:P|progress-test)$' { Test-ProgressIndicators; Pause-Detox }
            '^(?i:C)$' {
                $Script:Results.Clear()
                Write-Host 'In-memory results cleared.' -ForegroundColor Green
                Start-Sleep -Milliseconds 700
            }
            '^(?i:Q|quit|exit)$' {
                Write-Log 'Program closed by user.'
                Write-Host 'Exiting Digital Detox...' -ForegroundColor Green
                return
            }
            default {
                Write-Host 'Unknown selection or command. Press H for command help.' -ForegroundColor Red
                Start-Sleep -Milliseconds 900
            }
        }
    } while ($true)
}

