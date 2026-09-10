# WinScope 11 native module
[pscustomobject]@{
    Id                = 352
    Name              = 'Automatic Updates Policy'
    Group             = 'Windows Update Deep Health'
    GroupId           = 31
    Flags             = '[R][N]'
    Description       = 'Reports Automatic Updates policy and scheduling values.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.RegistrySnapshot 'WindowsUpdateDeep' 'Automatic Updates policy' 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' @('UseWUServer','AUOptions','NoAutoUpdate','ScheduledInstallDay','ScheduledInstallTime') 'Update scheduling is often centrally managed.'
    }
}
