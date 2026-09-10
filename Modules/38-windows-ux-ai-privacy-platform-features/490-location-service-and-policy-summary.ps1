# WinScope 11 native module
[pscustomobject]@{
    Id                = 490
    Name              = 'Location Service and Policy Summary'
    Group             = 'Windows UX, AI, Privacy & Platform Features'
    GroupId           = 38
    Flags             = '[R][N]'
    Description       = 'Reports Windows geolocation service and location policy.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.ServiceSnapshot 'Privacy' @('lfsvc') 'Geolocation service can be demand-started depending on app/location use.'
        & $Context.RegistrySnapshot 'Privacy' 'Location policy' 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors' @('DisableLocation','DisableWindowsLocationProvider','DisableSensors') 'Location policy should reflect privacy and application requirements.'
    }
}
