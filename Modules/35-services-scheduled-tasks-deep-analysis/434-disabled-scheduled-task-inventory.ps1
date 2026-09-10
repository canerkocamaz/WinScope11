# WinScope 11 native module
[pscustomobject]@{
    Id                = 434
    Name              = 'Disabled Scheduled Task Inventory'
    Group             = 'Services & Scheduled Tasks Deep Analysis'
    GroupId           = 35
    Flags             = '[R][N]'
    Description       = 'Reports disabled scheduled tasks.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {
            $tasks=@(Get-ScheduledTask -ErrorAction Stop | Where-Object {$_.State -eq 'Disabled'} | Sort-Object TaskPath,TaskName)
            foreach($t in $tasks) {
                & $Context.NewFinding 'TaskDeep' ("{0}{1}" -f $t.TaskPath,$t.TaskName) 'Info' ("UserId={0}; Author={1}" -f $t.Principal.UserId,$t.Author) 'Disabled tasks may represent retired software or intentional hardening; report-only.' $null
            }
        } catch {
            & $Context.NewFinding 'TaskDeep' 'Disabled tasks' 'Unavailable' $_.Exception.Message 'Scheduled task inventory failed.' $null
        }
    }
}
