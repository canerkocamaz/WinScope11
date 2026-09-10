# WinScope 11 native module
[pscustomobject]@{
    Id                = 346
    Name              = 'Update Reboot Coordinator Task Inventory'
    Group             = 'Windows Update Deep Health'
    GroupId           = 31
    Flags             = '[R][N]'
    Description       = 'Reports update-related reboot/restart scheduled tasks.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {
            $tasks=@(Get-ScheduledTask -ErrorAction Stop | Where-Object {$_.TaskName -match 'Reboot|Restart' -and $_.TaskPath -match 'Update|Orchestrator'} | Sort-Object TaskPath,TaskName)
            if($tasks.Count -eq 0) {
                & $Context.NewFinding 'WindowsUpdateDeep' 'Update reboot coordinator tasks' 'NoData' 'No matching reboot/restart update tasks were found.' 'Names vary by Windows build and servicing version.' $null
            } else {
                foreach($t in $tasks) {
                    & $Context.NewFinding 'WindowsUpdateDeep' ("{0}{1}" -f $t.TaskPath,$t.TaskName) ([string]$t.State) ("Author={0}" -f $t.Author) 'Reboot-coordination tasks are system-managed.' $null
                }
            }
        } catch {
            & $Context.NewFinding 'WindowsUpdateDeep' 'Update reboot coordinator tasks' 'Unavailable' $_.Exception.Message 'ScheduledTasks visibility may require administrator rights.' $null
        }
    }
}
