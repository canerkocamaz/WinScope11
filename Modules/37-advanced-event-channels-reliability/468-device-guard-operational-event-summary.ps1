# WinScope 11 native module
[pscustomobject]@{
    Id                = 468
    Name              = 'Device Guard Operational Event Summary'
    Group             = 'Advanced Event Channels & Reliability'
    GroupId           = 37
    Flags             = '[R][N]'
    Description       = 'Reports recent errors/warnings from Microsoft-Windows-DeviceGuard/Operational.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.EventSnapshot 'DeviceGuard' 'Device Guard Operational Event Summary' 'Microsoft-Windows-DeviceGuard/Operational' 30 80 '' 'Device Guard events help explain VBS, Credential Guard, or code-integrity policy state.' -ErrorsOnly
    }
}
