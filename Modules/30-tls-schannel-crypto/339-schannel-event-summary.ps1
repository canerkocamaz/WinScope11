# WinScope 11 native module
[pscustomobject]@{
    Id                = 339
    Name              = 'Schannel Event Summary'
    Group             = 'TLS, Schannel & Crypto'
    GroupId           = 30
    Flags             = '[R][N]'
    Description       = 'Reports recent Schannel events from the Windows System log.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $false
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {
            $events=@(Get-WinEvent -FilterHashtable @{LogName='System';ProviderName='Schannel';StartTime=(Get-Date).AddDays(-30)} -ErrorAction Stop | Select-Object -First 80)
            if($events.Count -eq 0) {
                & $Context.NewFinding 'Schannel' 'Schannel events (30 days)' 'Healthy' 'No Schannel provider events were returned for the last 30 days.' 'No action required based on this check.' $null
            } else {
                foreach($e in $events) {
                    & $Context.NewFinding 'Schannel' ("Event {0}" -f $e.Id) ([string]$e.LevelDisplayName) ("Time={0}; Message={1}" -f $e.TimeCreated,$e.Message) 'Recurring TLS/Schannel errors may indicate certificate, protocol or cipher incompatibility.' $null
                }
            }
        } catch {
            & $Context.NewFinding 'Schannel' 'Schannel events' 'Unavailable' $_.Exception.Message 'The System log or Schannel provider may be unavailable to the current session.' $null
        }
    }
}
