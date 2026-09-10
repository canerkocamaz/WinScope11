# WinScope 11 native module
[pscustomobject]@{
    Id                = 340
    Name              = 'CAPI2 Operational Error Summary'
    Group             = 'TLS, Schannel & Crypto'
    GroupId           = 30
    Flags             = '[R][N]'
    Description       = 'Reports recent errors from the CAPI2 Operational event channel.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $false
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        $log='Microsoft-Windows-CAPI2/Operational'
        try {
            $info=Get-WinEvent -ListLog $log -ErrorAction Stop
            if(-not $info.IsEnabled) {
                & $Context.NewFinding 'Crypto' $log 'Disabled' 'CAPI2 Operational log is disabled.' 'Enable only when certificate-chain troubleshooting requires it; logging configuration is not changed automatically.' $null
            } else {
                $events=@(Get-WinEvent -FilterHashtable @{LogName=$log;StartTime=(Get-Date).AddDays(-30)} -ErrorAction SilentlyContinue | Where-Object {$_.Level -le 3} | Select-Object -First 60)
                if($events.Count -eq 0) {
                    & $Context.NewFinding 'Crypto' $log 'Healthy' 'No Error/Critical CAPI2 events found in the last 30 days.' 'No action required based on this check.' $null
                } else {
                    foreach($e in $events) {
                        & $Context.NewFinding 'Crypto' ("CAPI2 Event {0}" -f $e.Id) ([string]$e.LevelDisplayName) ("Time={0}; Message={1}" -f $e.TimeCreated,$e.Message) 'Recurring CAPI2 errors can indicate certificate-chain or cryptographic validation problems.' $null
                    }
                }
            }
        } catch {
            & $Context.NewFinding 'Crypto' $log 'Unavailable' $_.Exception.Message 'The CAPI2 channel may not be available or enabled on this system.' $null
        }
    }
}
