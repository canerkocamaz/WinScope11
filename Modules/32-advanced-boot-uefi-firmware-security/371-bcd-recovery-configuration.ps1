# WinScope 11 native module
[pscustomobject]@{
    Id                = 371
    Name              = 'BCD Recovery Configuration'
    Group             = 'Advanced Boot, UEFI & Firmware Security'
    GroupId           = 32
    Flags             = '[R][N]'
    Description       = 'Reports current loader recovery references.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.CommandSnapshot 'Boot' 'Current loader recovery configuration' 'bcdedit.exe' @('/enum','{current}') 'Recovery references should be preserved unless a supported recovery repair is required.'
    }
}
