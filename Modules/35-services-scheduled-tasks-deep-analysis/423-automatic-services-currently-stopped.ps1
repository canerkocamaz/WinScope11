# WinScope 11 native module
[pscustomobject]@{
    Id                = 423
    Name              = 'Automatic Services Currently Stopped'
    Group             = 'Services & Scheduled Tasks Deep Analysis'
    GroupId           = 35
    Flags             = '[R][N]'
    Description       = 'Reports automatic-start services that are currently stopped for manual review.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {
            $svcs=@(Get-CimInstance Win32_Service -ErrorAction Stop | Where-Object {$_.StartMode -eq 'Auto' -and $_.State -eq 'Stopped'} | Sort-Object Name)
            if($svcs.Count -eq 0) {
                & $Context.NewFinding 'ServiceDeep' 'Automatic stopped services' 'Healthy' 'No automatic-start stopped services were returned.' 'Trigger/delayed behavior should still be considered for individual services.' $null
            } else {
                foreach($s in $svcs) {
                    & $Context.NewFinding 'ServiceDeep' $s.DisplayName 'Review' ("Name={0}; ExitCode={1}; Path={2}" -f $s.Name,$s.ExitCode,$s.PathName) 'Automatic-but-stopped does not always mean failure; correlate with service triggers, dependencies and event logs.' $null
                }
            }
        } catch {
            & $Context.NewFinding 'ServiceDeep' 'Automatic stopped services' 'Unavailable' $_.Exception.Message 'CIM service inventory failed.' $null
        }
    }
}
