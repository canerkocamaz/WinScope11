# WinScope 11 native module
[pscustomobject]@{
    Id                = 355
    Name              = 'Delivery Optimization Service Health'
    Group             = 'Windows Update Deep Health'
    GroupId           = 31
    Flags             = '[R][N]'
    Description       = 'Reports DoSvc state.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.ServiceSnapshot 'WindowsUpdateDeep' @('DoSvc') 'Delivery Optimization supports Windows Update and Store content delivery.'
    }
}
