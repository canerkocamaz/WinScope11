# WinScope 11 native module
[pscustomobject]@{
    Id                = 401
    Name              = 'Application Identity Service Health'
    Group             = 'Application Control & Code Integrity'
    GroupId           = 34
    Flags             = '[R][N]'
    Description       = 'Reports the Application Identity service used by AppLocker.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.ServiceSnapshot 'ApplicationControl' @('AppIDSvc') 'Application Identity is required for AppLocker enforcement and can be policy-managed.'
    }
}
