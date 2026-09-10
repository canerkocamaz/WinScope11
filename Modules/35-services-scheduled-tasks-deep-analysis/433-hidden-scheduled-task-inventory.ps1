# WinScope 11 native module
[pscustomobject]@{
    Id                = 433
    Name              = 'Hidden Scheduled Task Inventory'
    Group             = 'Services & Scheduled Tasks Deep Analysis'
    GroupId           = 35
    Flags             = '[R][N]'
    Description       = 'Reports scheduled tasks configured as hidden.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {
            $tasks=@(Get-ScheduledTask -ErrorAction Stop | Where-Object {$_.Settings.Hidden} | Sort-Object TaskPath,TaskName)
            if($tasks.Count -eq 0) {
                & $Context.NewFinding 'TaskDeep' 'Hidden tasks' 'Healthy' 'No hidden scheduled tasks were returned.' 'No action required based on this check.' $null
            } else {
                foreach($t in $tasks) {
                    & $Context.NewFinding 'TaskDeep' ("{0}{1}" -f $t.TaskPath,$t.TaskName) 'Review' ("UserId={0}; State={1}" -f $t.Principal.UserId,$t.State) 'Hidden tasks can be legitimate Windows tasks; validate unexpected third-party entries.' $null
                }
            }
        } catch {
            & $Context.NewFinding 'TaskDeep' 'Hidden tasks' 'Unavailable' $_.Exception.Message 'Scheduled task inventory failed.' $null
        }
    }
}
