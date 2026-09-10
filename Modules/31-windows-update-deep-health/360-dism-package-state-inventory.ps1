# WinScope 11 native module
[pscustomobject]@{
    Id                = 360
    Name              = 'DISM Package State Inventory'
    Group             = 'Windows Update Deep Health'
    GroupId           = 31
    Flags             = '[R][N]'
    Description       = 'Reports online servicing package state using DISM.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.CommandSnapshot 'WindowsUpdateDeep' 'DISM package state' 'dism.exe' @('/Online','/Get-Packages','/English') 'Packages are report-only; never remove servicing packages manually.'
    }
}
