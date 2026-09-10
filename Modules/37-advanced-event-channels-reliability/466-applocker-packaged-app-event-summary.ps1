# WinScope 11 native module
[pscustomobject]@{
    Id                = 466
    Name              = 'AppLocker Packaged App Event Summary'
    Group             = 'Advanced Event Channels & Reliability'
    GroupId           = 37
    Flags             = '[R][N]'
    Description       = 'Reports recent errors/warnings from Microsoft-Windows-AppLocker/Packaged app-Execution.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.EventSnapshot 'AppLocker' 'AppLocker Packaged App Event Summary' 'Microsoft-Windows-AppLocker/Packaged app-Execution' 30 80 '' 'Packaged app AppLocker events provide application-control visibility for Store/MSIX apps.' -ErrorsOnly
    }
}
