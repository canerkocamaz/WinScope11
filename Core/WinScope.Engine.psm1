Set-StrictMode -Version Latest

$script:AuditCompatLoaded = $false
$script:AuditCompatPath = $null
$script:AuditCompatModule = $null
$script:AuditCompatCommands = @{}

function Initialize-WSAuditCompatEngine {
    param([Parameter(Mandatory)][string]$ProjectRoot)

    if ($script:AuditCompatLoaded) { return }

    $script:AuditCompatPath = Join-Path $ProjectRoot 'AuditCompat\WinScope.AuditCompat300.psm1'
    if (-not (Test-Path -LiteralPath $script:AuditCompatPath)) {
        throw "Audit compatibility module was not found: $script:AuditCompatPath"
    }

    $script:AuditCompatModule = Import-Module `
        -Name $script:AuditCompatPath `
        -Force `
        -PassThru `
        -ErrorAction Stop

    if($null -eq $script:AuditCompatModule) {
        throw 'Audit compatibility module import returned no module object.'
    }

    $required = @(
        'Test-WSAuditCompatContract',
        'Clear-WSAuditCompatResults',
        'Get-WSAuditCompatResultCount',
        'Get-WSAuditCompatResultSlice',
        'Invoke-WSAuditCompatNumber'
    )

    $script:AuditCompatCommands = @{}
    foreach($name in $required) {
        $command = $script:AuditCompatModule.ExportedCommands[$name]
        if($null -eq $command) {
            throw "Audit compatibility module is missing exported command '$name'."
        }
        $script:AuditCompatCommands[$name] = $command
    }

    $contract = & $script:AuditCompatCommands['Test-WSAuditCompatContract']
    if($null -eq $contract) {
        throw 'Audit compatibility contract returned no result.'
    }
    if(-not $contract.DispatcherAvailable) {
        throw 'Audit compatibility internal dispatcher is unavailable in module scope.'
    }
    if(-not $contract.ResultsAvailable) {
        throw 'Audit compatibility Results collection is unavailable in module scope.'
    }
    if(-not $contract.BatchModeAvailable) {
        throw 'Audit compatibility BatchMode state is unavailable in module scope.'
    }

    $script:AuditCompatLoaded = $true
}

function Clear-WSAuditCompatResults {
    if(-not $script:AuditCompatLoaded) {
        return
    }

    & $script:AuditCompatCommands['Clear-WSAuditCompatResults']
}

function New-WSProbeResult {
    param(
        [Parameter(Mandatory)][string]$ExecutionStatus,
        [string]$ErrorMessage = '',
        [timespan]$Duration = ([timespan]::Zero),
        [AllowNull()][AllowEmptyCollection()][object[]]$RawRecords = @()
    )

    # Do not use an if-expression to produce @() here.
    # In Windows PowerShell 5.1 an empty pipeline result can collapse to $null
    # even when the target variable is declared as [object[]].
    [object[]]$safeRecords = @()

    if($null -ne $RawRecords) {
        $safeRecords = @(
            foreach($record in $RawRecords) {
                if($null -ne $record) {
                    $record
                }
            }
        )
    }

    [int]$recordCount = @($safeRecords).Count

    return [pscustomobject]@{
        ExecutionStatus = $ExecutionStatus
        ErrorMessage    = $ErrorMessage
        Duration        = $Duration
        RawRecords      = @($safeRecords)
        RecordCount     = $recordCount
    }
}

function New-WSNativeFinding {
    param(
        [Parameter(Mandatory)][string]$Category,
        [Parameter(Mandatory)][string]$Item,
        [Parameter(Mandatory)][string]$Status,
        [string]$Details = '',
        [string]$Recommendation = '',
        [AllowNull()][object]$SizeBytes = $null
    )

    $numericSize = $null
    $displaySize = ''

    if ($null -ne $SizeBytes) {
        try {
            $numericSize = [long]$SizeBytes
            if ($numericSize -ge 1GB) {
                $displaySize = ('{0:N2} GB' -f ($numericSize / 1GB))
            } elseif ($numericSize -ge 1MB) {
                $displaySize = ('{0:N2} MB' -f ($numericSize / 1MB))
            } elseif ($numericSize -ge 1KB) {
                $displaySize = ('{0:N2} KB' -f ($numericSize / 1KB))
            } else {
                $displaySize = ('{0} B' -f $numericSize)
            }
        } catch {
            $numericSize = $null
        }
    }

    [pscustomobject]@{
        Timestamp      = Get-Date
        Category       = $Category
        Item           = $Item
        Status         = $Status
        SizeBytes      = $numericSize
        Size           = $displaySize
        Details        = $Details
        Recommendation = $Recommendation
    }
}

function Invoke-WSNativeModule {
    param(
        [Parameter(Mandatory)][object]$Module,
        [Parameter(Mandatory)][string]$ProjectRoot,
        [Parameter(Mandatory)][string]$RunId
    )

    $started = Get-Date
    $status = 'Completed'
    $errorMessage = ''
    $records = @()

    try {
        if (-not ($Module.PSObject.Properties.Name -contains 'Invoke')) {
            throw "Native module $($Module.Id) has no Invoke scriptblock."
        }
        if ($Module.Invoke -isnot [scriptblock]) {
            throw "Native module $($Module.Id) Invoke property is not a scriptblock."
        }

        $context = [pscustomobject]@{
            ProjectRoot = $ProjectRoot
            RunId       = $RunId
            ModuleId    = [int]$Module.Id
            ModuleName  = [string]$Module.Name
            Group       = [string]$Module.Group
            Now         = Get-Date
            NewFinding  = {
                param(
                    [string]$Category,
                    [string]$Item,
                    [string]$Status,
                    [string]$Details = '',
                    [string]$Recommendation = '',
                    [AllowNull()][object]$SizeBytes = $null
                )
                New-WSNativeFinding -Category $Category -Item $Item -Status $Status `
                    -Details $Details -Recommendation $Recommendation -SizeBytes $SizeBytes
            }
            RegistrySnapshot = {
                param([string]$Category,[string]$Item,[string]$Path,[string[]]$Names,[string]$Recommendation)
                if(-not (Test-Path -LiteralPath $Path)) {
                    New-WSNativeFinding -Category $Category -Item $Item -Status 'NotConfigured' -Details ("Registry path not present: {0}" -f $Path) -Recommendation $Recommendation
                    return
                }
                $p=Get-ItemProperty -LiteralPath $Path -ErrorAction SilentlyContinue
                if($null -eq $p) {
                    New-WSNativeFinding -Category $Category -Item $Item -Status 'Unavailable' -Details ("Registry path could not be read: {0}" -f $Path) -Recommendation $Recommendation
                    return
                }
                if($null -eq $Names -or $Names.Count -eq 0) {
                    $pairs=@($p.PSObject.Properties | Where-Object {$_.Name -notmatch '^PS'} | ForEach-Object {"{0}={1}" -f $_.Name,$_.Value})
                    New-WSNativeFinding -Category $Category -Item $Item -Status 'Info' -Details ($pairs -join '; ') -Recommendation $Recommendation
                } else {
                    foreach($n in $Names) {
                        if($p.PSObject.Properties.Name -contains $n) {
                            New-WSNativeFinding -Category $Category -Item ("{0} / {1}" -f $Item,$n) -Status 'Info' -Details ("Value={0}" -f $p.$n) -Recommendation $Recommendation
                        } else {
                            New-WSNativeFinding -Category $Category -Item ("{0} / {1}" -f $Item,$n) -Status 'NotConfigured' -Details 'Value is not explicitly configured.' -Recommendation $Recommendation
                        }
                    }
                }
            }
            ServiceSnapshot = {
                param([string]$Category,[string[]]$Names,[string]$Recommendation)
                foreach($name in $Names) {
                    $svc=Get-Service -Name $name -ErrorAction SilentlyContinue
                    if($null -eq $svc) {
                        New-WSNativeFinding -Category $Category -Item $name -Status 'NotFound' -Details 'Service is not installed or unavailable.' -Recommendation $Recommendation
                    } else {
                        $start=''; $exit=''
                        try {$c=Get-CimInstance Win32_Service -Filter ("Name='{0}'" -f $name) -ErrorAction Stop;$start=[string]$c.StartMode;$exit=[string]$c.ExitCode}catch{}
                        New-WSNativeFinding -Category $Category -Item $svc.DisplayName -Status ([string]$svc.Status) -Details ("Name={0}; StartMode={1}; ExitCode={2}" -f $name,$start,$exit) -Recommendation $Recommendation
                    }
                }
            }
            CommandSnapshot = {
                param([string]$Category,[string]$Item,[string]$Command,[string[]]$Arguments,[string]$Recommendation)
                $cmd=Get-Command $Command -ErrorAction SilentlyContinue
                if($null -eq $cmd) {
                    New-WSNativeFinding -Category $Category -Item $Item -Status 'Unavailable' -Details ("{0} was not found." -f $Command) -Recommendation $Recommendation
                    return
                }
                try {
                    $o=(& $cmd.Source @Arguments 2>&1 | Out-String).Trim()
                    if([string]::IsNullOrWhiteSpace($o)){$o='Command returned no text output.'}
                    New-WSNativeFinding -Category $Category -Item $Item -Status 'Info' -Details $o -Recommendation $Recommendation
                } catch {
                    New-WSNativeFinding -Category $Category -Item $Item -Status 'Error' -Details $_.Exception.Message -Recommendation $Recommendation
                }
            }
            FolderFootprint = {
                param([string]$Category,[string]$Item,[string]$Path,[string]$Recommendation)
                if(-not (Test-Path -LiteralPath $Path)) {
                    New-WSNativeFinding -Category $Category -Item $Item -Status 'NotFound' -Details ("Path not present: {0}" -f $Path) -Recommendation $Recommendation
                    return
                }
                $files=@(Get-ChildItem -LiteralPath $Path -File -Recurse -Force -ErrorAction SilentlyContinue)
                $sum=($files|Measure-Object Length -Sum).Sum;if($null -eq $sum){$sum=0}
                New-WSNativeFinding -Category $Category -Item $Item -Status 'Info' -Details ("Files={0}; Path={1}" -f $files.Count,$Path) -Recommendation $Recommendation -SizeBytes ([long]$sum)
            }
            EventSnapshot = {
                param([string]$Category,[string]$Item,[string]$LogName,[int]$Days,[int]$MaxEvents,[string]$ProviderName,[string]$Recommendation,[switch]$ErrorsOnly)
                try {
                    $filter=@{LogName=$LogName;StartTime=(Get-Date).AddDays(-1*[math]::Abs($Days))}
                    if(-not [string]::IsNullOrWhiteSpace($ProviderName)){$filter.ProviderName=$ProviderName}
                    $events=@(Get-WinEvent -FilterHashtable $filter -ErrorAction Stop)
                    if($ErrorsOnly){$events=@($events|Where-Object {$_.Level -le 3})}
                    $events=@($events|Select-Object -First $MaxEvents)
                    if($events.Count -eq 0) {
                        New-WSNativeFinding -Category $Category -Item $Item -Status 'Healthy' -Details 'No matching events were returned.' -Recommendation $Recommendation
                    } else {
                        foreach($e in $events) {
                            New-WSNativeFinding -Category $Category -Item ("{0} / Event {1}" -f $Item,$e.Id) -Status ([string]$e.LevelDisplayName) -Details ("Time={0}; Provider={1}; Message={2}" -f $e.TimeCreated,$e.ProviderName,$e.Message) -Recommendation $Recommendation
                        }
                    }
                } catch {
                    New-WSNativeFinding -Category $Category -Item $Item -Status 'Unavailable' -Details $_.Exception.Message -Recommendation $Recommendation
                }
            }
        }

        $records = @(& $Module.Invoke $context | Where-Object { $null -ne $_ })
    } catch {
        $status = 'Failed'
        $errorMessage = $_.Exception.Message
        $records = @()
    }

    [object[]]$recordArray = $records

    return New-WSProbeResult `
        -ExecutionStatus $status `
        -ErrorMessage $errorMessage `
        -Duration ((Get-Date) - $started) `
        -RawRecords $recordArray
}

function Invoke-WSAuditCompatModule {
    param(
        [Parameter(Mandatory)][object]$Module,
        [Parameter(Mandatory)][string]$ProjectRoot,
        [Parameter(Mandatory)][string]$RunId
    )

    Initialize-WSAuditCompatEngine -ProjectRoot $ProjectRoot

    $before = [int](& $script:AuditCompatCommands['Get-WSAuditCompatResultCount'])
    $started = Get-Date
    $status = 'Completed'
    $errorMessage = ''

    try {
        & $script:AuditCompatCommands['Invoke-WSAuditCompatNumber'] `
            -Number ([int]$Module.CompatId)
    }
    catch {
        $status = 'Failed'
        $errorMessage = $_.Exception.Message
    }

    $duration = (Get-Date) - $started
    $after = [int](& $script:AuditCompatCommands['Get-WSAuditCompatResultCount'])

    [object[]]$newRecords = @()
    if ($after -gt $before) {
        $newRecords = @(
            & $script:AuditCompatCommands['Get-WSAuditCompatResultSlice'] `
                -StartIndex $before
        )
    }

    return New-WSProbeResult `
        -ExecutionStatus $status `
        -ErrorMessage $errorMessage `
        -Duration $duration `
        -RawRecords $newRecords
}

function Invoke-WSModuleProbe {
    param(
        [Parameter(Mandatory)][object]$Module,
        [Parameter(Mandatory)][string]$ProjectRoot,
        [Parameter(Mandatory)][string]$RunId
    )

    $adapter = if ($Module.PSObject.Properties.Name -contains 'Adapter') {
        [string]$Module.Adapter
    } else {
        'AuditCompat300'
    }

    $started = Get-Date

    try {
        $result = switch ($adapter) {
            'Native' {
                Invoke-WSNativeModule -Module $Module -ProjectRoot $ProjectRoot -RunId $RunId
            }
            'AuditCompat300' {
                Invoke-WSAuditCompatModule -Module $Module -ProjectRoot $ProjectRoot -RunId $RunId
            }
            default {
                throw "Unsupported WinScope module adapter: $adapter"
            }
        }

        if($null -eq $result) {
            throw "Module adapter '$adapter' returned no result object."
        }

        foreach($required in @('ExecutionStatus','ErrorMessage','Duration','RawRecords','RecordCount')) {
            if(-not ($result.PSObject.Properties.Name -contains $required)) {
                throw "Module adapter '$adapter' returned an invalid result object; missing property '$required'."
            }
        }

        [object[]]$safeRawRecords = @($result.RawRecords | Where-Object { $null -ne $_ })

        return New-WSProbeResult `
            -ExecutionStatus ([string]$result.ExecutionStatus) `
            -ErrorMessage ([string]$result.ErrorMessage) `
            -Duration ([timespan]$result.Duration) `
            -RawRecords $safeRawRecords
    }
    catch {
        return New-WSProbeResult `
            -ExecutionStatus 'Failed' `
            -ErrorMessage $_.Exception.Message `
            -Duration ((Get-Date) - $started) `
            -RawRecords @()
    }
}

Export-ModuleMember -Function Initialize-WSAuditCompatEngine,Clear-WSAuditCompatResults,Invoke-WSModuleProbe,New-WSNativeFinding,New-WSProbeResult
