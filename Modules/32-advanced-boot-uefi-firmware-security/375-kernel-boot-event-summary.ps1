# WinScope 11 native module
[pscustomobject]@{
    Id                = 375
    Name              = 'Kernel Boot Event Summary'
    Group             = 'Advanced Boot, UEFI & Firmware Security'
    GroupId           = 32
    Flags             = '[R][N]'
    Description       = 'Reports recent Kernel-Boot errors/warnings.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.EventSnapshot 'Boot' 'Kernel-Boot' 'System' 30 80 'Microsoft-Windows-Kernel-Boot' 'Recurring boot events can indicate firmware, BCD or device initialization issues.' -ErrorsOnly
    }
}
