# WinScope 11 native module
[pscustomobject]@{
    Id                = 478
    Name              = 'WHEA Hardware Error Event Summary'
    Group             = 'Advanced Event Channels & Reliability'
    GroupId           = 37
    Flags             = '[R][N]'
    Description       = 'Reports recent Windows Hardware Error Architecture events.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {
            $events=@(Get-WinEvent -FilterHashtable @{LogName='System';ProviderName='Microsoft-Windows-WHEA-Logger';StartTime=(Get-Date).AddDays(-30)} -ErrorAction Stop | Select-Object -First 100)
            if($events.Count -eq 0) {
                & $Context.NewFinding 'Reliability' 'WHEA hardware errors' 'Healthy' 'No WHEA-Logger events were returned for the last 30 days.' 'No action required based on this check.' $null
            } else {
                foreach($e in $events) {
                    & $Context.NewFinding 'Reliability' ("WHEA Event {0}" -f $e.Id) ([string]$e.LevelDisplayName) ("Time={0}; Message={1}" -f $e.TimeCreated,$e.Message) 'WHEA events can indicate CPU, memory, PCIe, storage, firmware, or power-related hardware faults.' $null
                }
            }
        } catch {
            & $Context.NewFinding 'Reliability' 'WHEA hardware errors' 'Unavailable' $_.Exception.Message 'System event access failed.' $null
        }
    }
}
