# WinScope 11 native module
[pscustomobject]@{
    Id                = 440
    Name              = 'Scheduled Task Failure Result Summary'
    Group             = 'Services & Scheduled Tasks Deep Analysis'
    GroupId           = 35
    Flags             = '[R][N]'
    Description       = 'Reports tasks whose last run result is non-zero, with a bounded result set.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {
            $count=0
            foreach($t in @(Get-ScheduledTask -ErrorAction Stop | Sort-Object TaskPath,TaskName)) {
                if($count -ge 150){break}
                try {
                    $i=Get-ScheduledTaskInfo -TaskName $t.TaskName -TaskPath $t.TaskPath -ErrorAction Stop
                    if($i.LastRunTime -gt [datetime]::MinValue -and $i.LastTaskResult -ne 0) {
                        $count++
                        & $Context.NewFinding 'TaskDeep' ("{0}{1}" -f $t.TaskPath,$t.TaskName) 'Review' ("LastRun={0}; LastResult=0x{1:X8}; NextRun={2}" -f $i.LastRunTime,([uint32]$i.LastTaskResult),$i.NextRunTime) 'Non-zero results require task-specific interpretation; correlate with TaskScheduler Operational events.' $null
                    }
                } catch {}
            }
            if($count -eq 0) {
                & $Context.NewFinding 'TaskDeep' 'Failed task results' 'Healthy' 'No recent non-zero task results were returned in the bounded scan.' 'No action required based on this check.' $null
            }
        } catch {
            & $Context.NewFinding 'TaskDeep' 'Failed task results' 'Unavailable' $_.Exception.Message 'Scheduled task inventory failed.' $null
        }
    }
}
