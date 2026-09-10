# WinScope 11 native module
[pscustomobject]@{
    Id                = 437
    Name              = 'Scheduled Task COM Handler Actions'
    Group             = 'Services & Scheduled Tasks Deep Analysis'
    GroupId           = 35
    Flags             = '[R][N]'
    Description       = 'Reports scheduled tasks that use COM handler actions.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {
            foreach($t in @(Get-ScheduledTask -ErrorAction Stop)) {
                foreach($a in @($t.Actions)) {
                    if($a.CimClass.CimClassName -match 'ComHandler') {
                        & $Context.NewFinding 'TaskDeep' ("{0}{1}" -f $t.TaskPath,$t.TaskName) 'Review' ("ClassId={0}; Data={1}; User={2}" -f $a.ClassId,$a.Data,$t.Principal.UserId) 'COM-handler tasks are used by Windows and applications; validate unexpected third-party class IDs.' $null
                    }
                }
            }
        } catch {
            & $Context.NewFinding 'TaskDeep' 'COM handler tasks' 'Unavailable' $_.Exception.Message 'Scheduled task inventory failed.' $null
        }
    }
}
