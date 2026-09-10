# WinScope 11 native module
[pscustomobject]@{
    Id                = 474
    Name              = 'Kernel Power Critical Event Summary'
    Group             = 'Advanced Event Channels & Reliability'
    GroupId           = 37
    Flags             = '[R][N]'
    Description       = 'Reports recent critical/error Kernel-Power System events.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {
            $events=@(Get-WinEvent -FilterHashtable @{LogName='System';ProviderName='Microsoft-Windows-Kernel-Power';StartTime=(Get-Date).AddDays(-30)} -ErrorAction Stop | Where-Object {$_.Level -le 3} | Select-Object -First 80)
            if($events.Count -eq 0) {
                & $Context.NewFinding 'Reliability' 'Kernel-Power events' 'Healthy' 'No critical/error Kernel-Power events were returned for the last 30 days.' 'No action required based on this check.' $null
            } else {
                foreach($e in $events) {
                    & $Context.NewFinding 'Reliability' ("Kernel-Power Event {0}" -f $e.Id) ([string]$e.LevelDisplayName) ("Time={0}; Message={1}" -f $e.TimeCreated,$e.Message) 'Repeated unexpected power-loss or sleep/resume failures require hardware, power, firmware, and driver correlation.' $null
                }
            }
        } catch {
            & $Context.NewFinding 'Reliability' 'Kernel-Power events' 'Unavailable' $_.Exception.Message 'System event access failed.' $null
        }
    }
}
