# WinScope 11 native module
[pscustomobject]@{
    Id                = 432
    Name              = 'Scheduled Tasks Using Highest Run Level'
    Group             = 'Services & Scheduled Tasks Deep Analysis'
    GroupId           = 35
    Flags             = '[R][N]'
    Description       = 'Reports tasks configured to run with highest privileges.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {
            $tasks=@(Get-ScheduledTask -ErrorAction Stop | Where-Object {$_.Principal.RunLevel -eq 'Highest'} | Sort-Object TaskPath,TaskName)
            foreach($t in $tasks) {
                & $Context.NewFinding 'TaskDeep' ("{0}{1}" -f $t.TaskPath,$t.TaskName) 'Review' ("UserId={0}; LogonType={1}; State={2}" -f $t.Principal.UserId,$t.Principal.LogonType,$t.State) 'Highest-privilege tasks should have trusted actions and documented ownership.' $null
            }
        } catch {
            & $Context.NewFinding 'TaskDeep' 'Highest scheduled tasks' 'Unavailable' $_.Exception.Message 'Scheduled task inventory failed.' $null
        }
    }
}
