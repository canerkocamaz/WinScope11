# WinScope 11 native module
[pscustomobject]@{
    Id                = 467
    Name              = 'Code Integrity Operational Event Summary'
    Group             = 'Advanced Event Channels & Reliability'
    GroupId           = 37
    Flags             = '[R][N]'
    Description       = 'Reports recent errors/warnings from Microsoft-Windows-CodeIntegrity/Operational.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.EventSnapshot 'CodeIntegrity' 'Code Integrity Operational Event Summary' 'Microsoft-Windows-CodeIntegrity/Operational' 30 80 '' 'Code Integrity events can reveal blocked, unsigned, or invalid code and driver problems.' -ErrorsOnly
    }
}
