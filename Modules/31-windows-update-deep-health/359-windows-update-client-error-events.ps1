# WinScope 11 native module
[pscustomobject]@{
    Id                = 359
    Name              = 'Windows Update Client Error Events'
    Group             = 'Windows Update Deep Health'
    GroupId           = 31
    Flags             = '[R][N]'
    Description       = 'Reports recent Windows Update Client operational errors.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.EventSnapshot 'WindowsUpdateDeep' 'Windows Update Client' 'Microsoft-Windows-WindowsUpdateClient/Operational' 30 80 '' 'Correlate recurring errors with KB history and servicing state.' -ErrorsOnly
    }
}
