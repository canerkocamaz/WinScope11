# WinScope 11 native module
[pscustomobject]@{
    Id                = 351
    Name              = 'Windows Update Source Policy'
    Group             = 'Windows Update Deep Health'
    GroupId           = 31
    Flags             = '[R][N]'
    Description       = 'Reports WSUS/WUfB update-source policy.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.RegistrySnapshot 'WindowsUpdateDeep' 'Windows Update policy' 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' @('WUServer','WUStatusServer','UpdateServiceUrlAlternate','DoNotConnectToWindowsUpdateInternetLocations') 'Interpret with WSUS/WUfB/MDM policy.'
    }
}
