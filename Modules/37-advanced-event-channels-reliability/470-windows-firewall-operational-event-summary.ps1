# WinScope 11 native module
[pscustomobject]@{
    Id                = 470
    Name              = 'Windows Firewall Operational Event Summary'
    Group             = 'Advanced Event Channels & Reliability'
    GroupId           = 37
    Flags             = '[R][N]'
    Description       = 'Reports recent errors/warnings from Microsoft-Windows-Windows Firewall With Advanced Security/Firewall.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.EventSnapshot 'Firewall' 'Windows Firewall Operational Event Summary' 'Microsoft-Windows-Windows Firewall With Advanced Security/Firewall' 30 80 '' 'Firewall operational events can reveal policy-load, filtering, and configuration issues.' -ErrorsOnly
    }
}
