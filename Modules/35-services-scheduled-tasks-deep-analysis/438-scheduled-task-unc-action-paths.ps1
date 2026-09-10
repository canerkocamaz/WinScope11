# WinScope 11 native module
[pscustomobject]@{
    Id                = 438
    Name              = 'Scheduled Task UNC Action Paths'
    Group             = 'Services & Scheduled Tasks Deep Analysis'
    GroupId           = 35
    Flags             = '[R][N]'
    Description       = 'Reports scheduled-task actions that execute directly from UNC/network paths.'
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
                    $exe=[string]$a.Execute
                    if($exe -match '^\\\\') {
                        & $Context.NewFinding 'TaskDeep' ("{0}{1}" -f $t.TaskPath,$t.TaskName) 'Review' ("UNC Execute={0}; Arguments={1}; User={2}" -f $exe,$a.Arguments,$t.Principal.UserId) 'Network-hosted task actions depend on remote trust/availability and should have documented ownership.' $null
                    }
                }
            }
        } catch {
            & $Context.NewFinding 'TaskDeep' 'UNC task actions' 'Unavailable' $_.Exception.Message 'Scheduled task inventory failed.' $null
        }
    }
}
