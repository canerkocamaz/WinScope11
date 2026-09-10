# WinScope 11 native module
[pscustomobject]@{
    Id                = 416
    Name              = 'PowerShell Module Logging Policy'
    Group             = 'Application Control & Code Integrity'
    GroupId           = 34
    Flags             = '[R][N]'
    Description       = 'Reports PowerShell Module Logging policy.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.RegistrySnapshot 'ApplicationControl' 'PowerShell ModuleLogging' 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging' @('EnableModuleLogging') 'Module Logging can improve audit visibility; module-name subkeys may define scope.'
    }
}
