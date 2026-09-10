# WinScope 11 native module
[pscustomobject]@{
    Id                = 462
    Name              = 'WMI Activity Operational Error Summary'
    Group             = 'Advanced Event Channels & Reliability'
    GroupId           = 37
    Flags             = '[R][N]'
    Description       = 'Reports recent errors/warnings from Microsoft-Windows-WMI-Activity/Operational.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.EventSnapshot 'WMI' 'WMI Activity Operational Error Summary' 'Microsoft-Windows-WMI-Activity/Operational' 30 80 '' 'Recurring WMI errors can indicate provider, repository, permission, or management issues.' -ErrorsOnly
    }
}
