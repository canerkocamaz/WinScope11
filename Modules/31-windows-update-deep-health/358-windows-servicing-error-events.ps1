# WinScope 11 native module
[pscustomobject]@{
    Id                = 358
    Name              = 'Windows Servicing Error Events'
    Group             = 'Windows Update Deep Health'
    GroupId           = 31
    Flags             = '[R][N]'
    Description       = 'Reports recent servicing errors.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.EventSnapshot 'WindowsUpdateDeep' 'Servicing' 'System' 30 80 'Microsoft-Windows-Servicing' 'Recurring servicing errors should be correlated with DISM/CBS health.' -ErrorsOnly
    }
}
