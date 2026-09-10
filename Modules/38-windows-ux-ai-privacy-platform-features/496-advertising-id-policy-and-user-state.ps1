# WinScope 11 native module
[pscustomobject]@{
    Id                = 496
    Name              = 'Advertising ID Policy and User State'
    Group             = 'Windows UX, AI, Privacy & Platform Features'
    GroupId           = 38
    Flags             = '[R][N]'
    Description       = 'Reports machine advertising-ID policy and current-user state.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.RegistrySnapshot 'Privacy' 'AdvertisingInfo policy' 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo' @('DisabledByGroupPolicy') 'Advertising ID policy controls personalized application advertising behavior.'
        & $Context.RegistrySnapshot 'Privacy' 'User AdvertisingInfo' 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo' @('Enabled') 'Current-user advertising ID state is informational.'
    }
}
