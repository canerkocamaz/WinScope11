#requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$core = Join-Path $root 'Core'

Import-Module (Join-Path $core 'WinScope.Engine.psm1') -Force
Import-Module (Join-Path $core 'WinScope.Reporting.psm1') -Force

Write-Host 'WinScope core runtime contract tests' -ForegroundColor Cyan

# ------------------------------------------------------------------
# Result constructor cardinality tests.
# These specifically protect Windows PowerShell 5.1 + StrictMode behavior.
# ------------------------------------------------------------------

$rDefault = New-WSProbeResult -ExecutionStatus 'Completed'
if($null -eq $rDefault){throw 'Default result constructor returned null.'}
if($rDefault.RecordCount -ne 0){throw "Default RecordCount expected 0, got $($rDefault.RecordCount)."}
if(@($rDefault.RawRecords).Count -ne 0){throw 'Default RawRecords expected empty array.'}
Write-Host 'PASS - Result contract: default empty records' -ForegroundColor Green

$rNull = New-WSProbeResult -ExecutionStatus 'Completed' -RawRecords $null
if($rNull.RecordCount -ne 0){throw "Null RecordCount expected 0, got $($rNull.RecordCount)."}
if(@($rNull.RawRecords).Count -ne 0){throw 'Null RawRecords expected empty array.'}
Write-Host 'PASS - Result contract: null records' -ForegroundColor Green

$rEmpty = New-WSProbeResult -ExecutionStatus 'Completed' -RawRecords @()
if($rEmpty.RecordCount -ne 0){throw "Empty RecordCount expected 0, got $($rEmpty.RecordCount)."}
if(@($rEmpty.RawRecords).Count -ne 0){throw 'Empty RawRecords expected empty array.'}
Write-Host 'PASS - Result contract: explicit empty array' -ForegroundColor Green

$one = [pscustomobject]@{Item='One';Status='Info'}
$rOne = New-WSProbeResult -ExecutionStatus 'Completed' -RawRecords @($one)
if($rOne.RecordCount -ne 1){throw "Single RecordCount expected 1, got $($rOne.RecordCount)."}
if(@($rOne.RawRecords).Count -ne 1){throw 'Single RawRecords count mismatch.'}
Write-Host 'PASS - Result contract: single record' -ForegroundColor Green

$list = New-Object System.Collections.Generic.List[object]
$list.Add([pscustomobject]@{Item='A';Status='Info'})
$list.Add([pscustomobject]@{Item='B';Status='Info'})

[object[]]$array = @(
    for($i=0; $i -lt $list.Count; $i++) {
        $list[$i]
    }
)

$rMany = New-WSProbeResult -ExecutionStatus 'Completed' -RawRecords $array
if($null -eq $rMany){throw 'Multi-record result constructor returned null.'}
if(-not ($rMany.PSObject.Properties.Name -contains 'RawRecords')){throw 'RawRecords property missing.'}
if($rMany.RecordCount -ne 2){throw "Expected RecordCount 2, got $($rMany.RecordCount)."}
if(@($rMany.RawRecords).Count -ne 2){throw 'RawRecords array count mismatch.'}
Write-Host 'PASS - Result contract: multiple records' -ForegroundColor Green

$fake = [pscustomobject]@{
    Id=999; Name='Synthetic Contract Test'; Group='Test'; Adapter='Native'
    Invoke={
        param($Context)
        & $Context.NewFinding 'QA' 'Synthetic finding' 'Info' 'Contract test' 'No action.' $null
    }
}
$result = Invoke-WSModuleProbe -Module $fake -ProjectRoot $root -RunId 'contract'
if($result.ExecutionStatus -ne 'Completed'){throw "Synthetic Native failed: $($result.ErrorMessage)"}
if($result.RecordCount -ne 1){throw "Expected 1 record, got $($result.RecordCount)"}
Write-Host 'PASS - Native adapter result contract' -ForegroundColor Green

$fail = [pscustomobject]@{
    Id=998; Name='Synthetic Failure Test'; Group='Test'; Adapter='Native'
    Invoke={ param($Context) throw 'Synthetic expected failure' }
}
$failed = Invoke-WSModuleProbe -Module $fail -ProjectRoot $root -RunId 'contract'
if($failed.ExecutionStatus -ne 'Failed'){throw 'Failure result did not return Failed.'}
foreach($p in @('ExecutionStatus','ErrorMessage','Duration','RawRecords','RecordCount')){
    if(-not ($failed.PSObject.Properties.Name -contains $p)){throw "Failure result missing $p"}
}
if($failed.RecordCount -ne 0){throw "Failure RecordCount expected 0, got $($failed.RecordCount)."}
if(@($failed.RawRecords).Count -ne 0){throw 'Failure RawRecords expected empty array.'}
Write-Host 'PASS - Failure result contract with empty records' -ForegroundColor Green

$temp = Join-Path $env:TEMP ('WinScopeContract_' + [guid]::NewGuid().ToString('N'))
New-Item -Path $temp -ItemType Directory -Force | Out-Null
try {
    $module = [pscustomobject]@{
        Id=999;Name='Synthetic Reporting';Group='Test';SourceGroupName='Test'
        MainGroupCode='9';MainGroupName='QA'
        SubGroupCode='9.1';SubGroupName='Runtime'
        LeafGroupCode='9.1.1';LeafGroupName='Contracts'
        Flags='[R][N]';Risk='ReportOnly'
    }

    $session=New-WSRunSession -BaseReportDir $temp -SelectedModules @($module) -Mode 'SelfTest'
    $record=ConvertTo-WSNormalizedRecord -Record ([pscustomobject]@{
        Category='QA';Item='Reporting';Status='Info';Details='Details';Recommendation='Recommendation'
    }) -Module $module -RunId $session.RunId

    [void](Save-WSModuleReport -Session $session -Module $module -Records @($record) -ExecutionStatus 'Completed')

    $execution=[pscustomobject]@{
        ModuleId=999;ModuleName='Synthetic Reporting';Group='Test'
        MainGroupCode='9';MainGroupName='QA'
        SubGroupCode='9.1';SubGroupName='Runtime'
        LeafGroupCode='9.1.1';LeafGroupName='Contracts'
        ExecutionStatus='Completed';ErrorMessage='';DurationMs=1;RecordCount=1
    }

    $combined=Save-WSCombinedReport -Session $session -Records @($record) -ModuleExecutions @($execution)
    $hier=Save-WSHierarchyReports -Session $session -Records @($record) -ModuleExecutions @($execution)

    foreach($path in @($combined.Csv,$combined.Json,$combined.Text,$combined.Html,$combined.Run,$hier.Index)){
        if(-not (Test-Path -LiteralPath $path)){throw "Expected report file missing: $path"}
    }

    Write-Host 'PASS - Reporting and hierarchy contract' -ForegroundColor Green
}
finally {
    if(Test-Path -LiteralPath $temp){ [System.IO.Directory]::Delete($temp,$true) }
}

Write-Host ''
Write-Host 'ALL CORE RUNTIME CONTRACT TESTS PASSED' -ForegroundColor Green
