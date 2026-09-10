# WinScope 11 native module
[pscustomobject]@{
    Id                = 354
    Name              = 'Update Session Orchestrator Service Health'
    Group             = 'Windows Update Deep Health'
    GroupId           = 31
    Flags             = '[R][N]'
    Description       = 'Reports UsoSvc state.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.ServiceSnapshot 'WindowsUpdateDeep' @('UsoSvc') 'UsoSvc coordinates Windows Update orchestration and can be trigger-started.'
    }
}
