# WinScope 11 native module
[pscustomobject]@{
    Id                = 364
    Name              = 'Hypervisor Launch Configuration'
    Group             = 'Advanced Boot, UEFI & Firmware Security'
    GroupId           = 32
    Flags             = '[R][N]'
    Description       = 'Reports current BCD loader including hypervisor launch flags.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.CommandSnapshot 'FirmwareSecurity' 'Current BCD loader' 'bcdedit.exe' @('/enum','{current}') 'Review hypervisor/debug/testsigning flags; WinScope never changes BCD.'
    }
}
