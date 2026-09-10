# WinScope 11 native module
[pscustomobject]@{
    Id                = 471
    Name              = 'RDP Local Session Manager Events'
    Group             = 'Advanced Event Channels & Reliability'
    GroupId           = 37
    Flags             = '[R][N]'
    Description       = 'Reports recent errors/warnings from Microsoft-Windows-TerminalServices-LocalSessionManager/Operational.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.EventSnapshot 'RDP' 'RDP Local Session Manager Events' 'Microsoft-Windows-TerminalServices-LocalSessionManager/Operational' 30 80 '' 'RDP LocalSessionManager events help trace local/remote session lifecycle and failures.' -ErrorsOnly
    }
}
