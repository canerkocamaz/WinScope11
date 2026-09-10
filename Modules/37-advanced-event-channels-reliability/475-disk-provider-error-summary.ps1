# WinScope 11 native module
[pscustomobject]@{
    Id                = 475
    Name              = 'Disk Provider Error Summary'
    Group             = 'Advanced Event Channels & Reliability'
    GroupId           = 37
    Flags             = '[R][N]'
    Description       = 'Reports recent disk provider error events from the System log.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        foreach($provider in @('disk','Microsoft-Windows-Disk')) {
            try {
                $events=@(Get-WinEvent -FilterHashtable @{LogName='System';ProviderName=$provider;StartTime=(Get-Date).AddDays(-30)} -ErrorAction Stop | Where-Object {$_.Level -le 3} | Select-Object -First 60)
                foreach($e in $events) {
                    & $Context.NewFinding 'Reliability' ("{0} Event {1}" -f $provider,$e.Id) ([string]$e.LevelDisplayName) ("Time={0}; Message={1}" -f $e.TimeCreated,$e.Message) 'Disk errors can indicate media, cabling, controller, firmware, or storage-stack problems.' $null
                }
            } catch {}
        }
    }
}
