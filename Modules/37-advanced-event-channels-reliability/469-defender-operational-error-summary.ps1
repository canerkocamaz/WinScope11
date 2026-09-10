# WinScope 11 native module
[pscustomobject]@{
    Id                = 469
    Name              = 'Defender Operational Error Summary'
    Group             = 'Advanced Event Channels & Reliability'
    GroupId           = 37
    Flags             = '[R][N]'
    Description       = 'Reports recent errors/warnings from Microsoft-Windows-Windows Defender/Operational.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.EventSnapshot 'Defender' 'Defender Operational Error Summary' 'Microsoft-Windows-Windows Defender/Operational' 30 80 '' 'Defender Operational errors should be correlated with engine, signature, scan, and policy state.' -ErrorsOnly
    }
}
