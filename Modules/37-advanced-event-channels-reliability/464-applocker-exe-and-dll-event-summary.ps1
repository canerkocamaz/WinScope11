# WinScope 11 native module
[pscustomobject]@{
    Id                = 464
    Name              = 'AppLocker EXE and DLL Event Summary'
    Group             = 'Advanced Event Channels & Reliability'
    GroupId           = 37
    Flags             = '[R][N]'
    Description       = 'Reports recent errors/warnings from Microsoft-Windows-AppLocker/EXE and DLL.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.EventSnapshot 'AppLocker' 'AppLocker EXE and DLL Event Summary' 'Microsoft-Windows-AppLocker/EXE and DLL' 30 80 '' 'AppLocker EXE/DLL events reveal allowed, audited, or blocked executable activity.' -ErrorsOnly
    }
}
