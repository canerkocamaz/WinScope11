# WinScope 11 native module
[pscustomobject]@{
    Id                = 465
    Name              = 'AppLocker MSI and Script Event Summary'
    Group             = 'Advanced Event Channels & Reliability'
    GroupId           = 37
    Flags             = '[R][N]'
    Description       = 'Reports recent errors/warnings from Microsoft-Windows-AppLocker/MSI and Script.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.EventSnapshot 'AppLocker' 'AppLocker MSI and Script Event Summary' 'Microsoft-Windows-AppLocker/MSI and Script' 30 80 '' 'AppLocker MSI/Script events reveal application-control decisions for installers and scripts.' -ErrorsOnly
    }
}
