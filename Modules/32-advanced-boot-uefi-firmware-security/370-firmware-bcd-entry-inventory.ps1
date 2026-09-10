# WinScope 11 native module
[pscustomobject]@{
    Id                = 370
    Name              = 'Firmware BCD Entry Inventory'
    Group             = 'Advanced Boot, UEFI & Firmware Security'
    GroupId           = 32
    Flags             = '[R][N]'
    Description       = 'Reports firmware boot entries where available.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.CommandSnapshot 'Boot' 'Firmware BCD entries' 'bcdedit.exe' @('/enum','FIRMWARE') 'Do not delete unknown firmware boot entries.'
    }
}
