# WinScope 11 native module
[pscustomobject]@{
    Id                = 369
    Name              = 'Boot Manager BCD Inventory'
    Group             = 'Advanced Boot, UEFI & Firmware Security'
    GroupId           = 32
    Flags             = '[R][N]'
    Description       = 'Reports Windows Boot Manager configuration.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.CommandSnapshot 'Boot' 'Boot Manager' 'bcdedit.exe' @('/enum','{bootmgr}') 'Boot Manager settings are report-only.'
    }
}
