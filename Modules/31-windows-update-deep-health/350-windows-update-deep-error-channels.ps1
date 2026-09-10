# WinScope 11 native module
[pscustomobject]@{
    Id                = 350
    Name              = 'Windows Update Deep Error Channels'
    Group             = 'Windows Update Deep Health'
    GroupId           = 31
    Flags             = '[R][N]'
    Description       = 'Reports recent Error/Critical events from Update Orchestrator and Windows Update Client channels.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $logs=@('Microsoft-Windows-UpdateOrchestrator/Operational','Microsoft-Windows-WindowsUpdateClient/Operational')
        foreach($log in $logs) {
            try {
                $info=Get-WinEvent -ListLog $log -ErrorAction Stop
                if(-not $info.IsEnabled) {
                    & $Context.NewFinding 'WindowsUpdateDeep' $log 'Disabled' 'Event channel is disabled.' 'Do not enable high-volume diagnostic channels without a troubleshooting need.' $null
                    continue
                }
                $events=@(Get-WinEvent -FilterHashtable @{LogName=$log;StartTime=(Get-Date).AddDays(-14)} -ErrorAction SilentlyContinue | Where-Object {$_.Level -le 3} | Select-Object -First 60)
                if($events.Count -eq 0) {
                    & $Context.NewFinding 'WindowsUpdateDeep' $log 'Healthy' 'No Error/Critical events found in the last 14 days.' 'No action required based on this event-channel check.' $null
                } else {
                    foreach($e in $events) {
                        & $Context.NewFinding 'WindowsUpdateDeep' ("{0} / Event {1}" -f $log,$e.Id) ([string]$e.LevelDisplayName) ("Time={0}; Message={1}" -f $e.TimeCreated,$e.Message) 'Recurring update errors should be correlated with KB/update history and servicing state.' $null
                    }
                }
            } catch {
                & $Context.NewFinding 'WindowsUpdateDeep' $log 'Unavailable' $_.Exception.Message 'The event channel may not exist on this Windows build.' $null
            }
        }
    }
}
