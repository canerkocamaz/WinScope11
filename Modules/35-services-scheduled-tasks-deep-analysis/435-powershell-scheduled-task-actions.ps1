# WinScope 11 native module
[pscustomobject]@{
    Id                = 435
    Name              = 'PowerShell Scheduled Task Actions'
    Group             = 'Services & Scheduled Tasks Deep Analysis'
    GroupId           = 35
    Flags             = '[R][N]'
    Description       = 'Reports scheduled-task actions that launch PowerShell or pwsh.'
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
                    if([string]$a.Execute -match '(?i)(powershell|pwsh)(\.exe)?$') {
                        & $Context.NewFinding 'TaskDeep' ("{0}{1}" -f $t.TaskPath,$t.TaskName) 'Review' ("Execute={0}; Arguments={1}; User={2}" -f $a.Execute,$a.Arguments,$t.Principal.UserId) 'PowerShell tasks can be legitimate automation; validate script path, arguments, signer and ownership.' $null
                    }
                }
            }
        } catch {
            & $Context.NewFinding 'TaskDeep' 'PowerShell task actions' 'Unavailable' $_.Exception.Message 'Scheduled task inventory failed.' $null
        }
    }
}
