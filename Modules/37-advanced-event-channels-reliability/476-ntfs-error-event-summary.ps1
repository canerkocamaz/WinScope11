# WinScope 11 native module
[pscustomobject]@{
    Id                = 476
    Name              = 'NTFS Error Event Summary'
    Group             = 'Advanced Event Channels & Reliability'
    GroupId           = 37
    Flags             = '[R][N]'
    Description       = 'Reports recent NTFS file-system errors from the System log.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        foreach($provider in @('Ntfs','Microsoft-Windows-Ntfs')) {
            try {
                $events=@(Get-WinEvent -FilterHashtable @{LogName='System';ProviderName=$provider;StartTime=(Get-Date).AddDays(-30)} -ErrorAction Stop | Where-Object {$_.Level -le 3} | Select-Object -First 60)
                foreach($e in $events) {
                    & $Context.NewFinding 'Reliability' ("{0} Event {1}" -f $provider,$e.Id) ([string]$e.LevelDisplayName) ("Time={0}; Message={1}" -f $e.TimeCreated,$e.Message) 'NTFS errors should be correlated with disk health, dirty-bit state, storage events, and backups.' $null
                }
            } catch {}
        }
    }
}
