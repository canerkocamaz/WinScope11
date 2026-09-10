# WinScope 11 native module
[pscustomobject]@{
    Id                = 372
    Name              = 'Windows Recovery Environment Status'
    Group             = 'Advanced Boot, UEFI & Firmware Security'
    GroupId           = 32
    Flags             = '[R][N]'
    Description       = 'Reports WinRE state and location.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.CommandSnapshot 'Boot' 'Windows RE' 'reagentc.exe' @('/info') 'WinRE configuration is report-only.'
    }
}
