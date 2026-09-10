# WinScope 11 native module
[pscustomobject]@{
    Id                = 342
    Name              = 'Windows Update Scheduled Task Health'
    Group             = 'Windows Update Deep Health'
    GroupId           = 31
    Flags             = '[R][N]'
    Description       = 'Reports scheduled tasks associated with Windows Update and servicing.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {
            $tasks=@(Get-ScheduledTask -ErrorAction Stop | Where-Object {$_.TaskPath -match 'WindowsUpdate|UpdateOrchestrator|WaaSMedic'} | Sort-Object TaskPath,TaskName)
            if($tasks.Count -eq 0) {
                & $Context.NewFinding 'WindowsUpdateDeep' 'Windows Update tasks' 'NoData' 'No matching Windows Update scheduled tasks were returned.' 'Task names vary by Windows build.' $null
            } else {
                foreach($t in $tasks) {
                    & $Context.NewFinding 'WindowsUpdateDeep' ("{0}{1}" -f $t.TaskPath,$t.TaskName) ([string]$t.State) ("Author={0}" -f $t.Author) 'Windows servicing tasks are system-managed; report-only.' $null
                }
            }
        } catch {
            & $Context.NewFinding 'WindowsUpdateDeep' 'Windows Update tasks' 'Unavailable' $_.Exception.Message 'ScheduledTasks cmdlets may require elevated access for complete visibility.' $null
        }
    }
}
