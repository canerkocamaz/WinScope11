# WinScope 11 native module
[pscustomobject]@{
    Id                = 353
    Name              = 'Windows Update Medic Service Health'
    Group             = 'Windows Update Deep Health'
    GroupId           = 31
    Flags             = '[R][N]'
    Description       = 'Reports WaaSMedicSvc state.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.ServiceSnapshot 'WindowsUpdateDeep' @('WaaSMedicSvc') 'Windows Update Medic is a protected servicing component and may be trigger-started.'
    }
}
