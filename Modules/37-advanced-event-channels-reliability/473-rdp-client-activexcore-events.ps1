# WinScope 11 native module
[pscustomobject]@{
    Id                = 473
    Name              = 'RDP Client ActiveXCore Events'
    Group             = 'Advanced Event Channels & Reliability'
    GroupId           = 37
    Flags             = '[R][N]'
    Description       = 'Reports recent errors/warnings from Microsoft-Windows-TerminalServices-RDPClient/Operational.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.EventSnapshot 'RDP' 'RDP Client ActiveXCore Events' 'Microsoft-Windows-TerminalServices-RDPClient/Operational' 30 80 '' 'RDP client operational events can help troubleshoot outbound Remote Desktop connections.' -ErrorsOnly
    }
}
