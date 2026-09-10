# WinScope 11 native module
[pscustomobject]@{
    Id                = 477
    Name              = 'Storage Stack Error Event Summary'
    Group             = 'Advanced Event Channels & Reliability'
    GroupId           = 37
    Flags             = '[R][N]'
    Description       = 'Reports recent StorPort, storahci, and storage-class driver errors.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        foreach($provider in @('Microsoft-Windows-StorPort','storahci','Microsoft-Windows-Storage-ClassPnP')) {
            try {
                $events=@(Get-WinEvent -FilterHashtable @{LogName='System';ProviderName=$provider;StartTime=(Get-Date).AddDays(-30)} -ErrorAction Stop | Where-Object {$_.Level -le 3} | Select-Object -First 50)
                foreach($e in $events) {
                    & $Context.NewFinding 'Reliability' ("{0} Event {1}" -f $provider,$e.Id) ([string]$e.LevelDisplayName) ("Time={0}; Message={1}" -f $e.TimeCreated,$e.Message) 'Storage-stack errors may indicate controller, firmware, cabling, media, or driver instability.' $null
                }
            } catch {}
        }
    }
}
