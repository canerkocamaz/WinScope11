# WinScope 11 native module
[pscustomobject]@{
    Id                = 472
    Name              = 'RDP Remote Connection Manager Events'
    Group             = 'Advanced Event Channels & Reliability'
    GroupId           = 37
    Flags             = '[R][N]'
    Description       = 'Reports recent errors/warnings from Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.EventSnapshot 'RDP' 'RDP Remote Connection Manager Events' 'Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational' 30 80 '' 'RemoteConnectionManager events help explain RDP authentication and connection issues.' -ErrorsOnly
    }
}
