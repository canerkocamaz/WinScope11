# WinScope 11 native module
[pscustomobject]@{
    Id                = 377
    Name              = 'Boot Configuration Security Flags'
    Group             = 'Advanced Boot, UEFI & Firmware Security'
    GroupId           = 32
    Flags             = '[R][N]'
    Description       = 'Reports test/debug/integrity flags from current BCD configuration.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.CommandSnapshot 'Boot' 'BCD security/debug flags' 'bcdedit.exe' @('/enum','{current}') 'Investigate unexpected testsigning, debug or nointegritychecks settings before modification.'
    }
}
