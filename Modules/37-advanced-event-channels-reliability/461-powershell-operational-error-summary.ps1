# WinScope 11 native module
[pscustomobject]@{
    Id                = 461
    Name              = 'PowerShell Operational Error Summary'
    Group             = 'Advanced Event Channels & Reliability'
    GroupId           = 37
    Flags             = '[R][N]'
    Description       = 'Reports recent errors/warnings from Microsoft-Windows-PowerShell/Operational.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.EventSnapshot 'PowerShell' 'PowerShell Operational Error Summary' 'Microsoft-Windows-PowerShell/Operational' 30 80 '' 'PowerShell Operational errors can reveal script, engine, or policy failures.' -ErrorsOnly
    }
}
