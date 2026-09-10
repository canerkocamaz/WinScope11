# WinScope 11 native module
[pscustomobject]@{
    Id                = 431
    Name              = 'Scheduled Tasks Running as SYSTEM'
    Group             = 'Services & Scheduled Tasks Deep Analysis'
    GroupId           = 35
    Flags             = '[R][N]'
    Description       = 'Reports scheduled tasks whose principal runs as LocalSystem.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {
            $tasks=@(Get-ScheduledTask -ErrorAction Stop | Where-Object {$_.Principal.UserId -match '^(SYSTEM|S-1-5-18)$'} | Sort-Object TaskPath,TaskName)
            foreach($t in $tasks) {
                & $Context.NewFinding 'TaskDeep' ("{0}{1}" -f $t.TaskPath,$t.TaskName) 'Info' ("RunLevel={0}; LogonType={1}; State={2}" -f $t.Principal.RunLevel,$t.Principal.LogonType,$t.State) 'SYSTEM tasks are common for Windows maintenance; focus on unexpected third-party actions.' $null
            }
        } catch {
            & $Context.NewFinding 'TaskDeep' 'SYSTEM scheduled tasks' 'Unavailable' $_.Exception.Message 'Scheduled task inventory failed.' $null
        }
    }
}
