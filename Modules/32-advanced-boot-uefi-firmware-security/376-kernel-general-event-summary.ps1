# WinScope 11 native module
[pscustomobject]@{
    Id                = 376
    Name              = 'Kernel General Event Summary'
    Group             = 'Advanced Boot, UEFI & Firmware Security'
    GroupId           = 32
    Flags             = '[R][N]'
    Description       = 'Reports recent Kernel-General errors/warnings.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.EventSnapshot 'Boot' 'Kernel-General' 'System' 30 80 'Microsoft-Windows-Kernel-General' 'Use these events for boot/shutdown/time correlation.' -ErrorsOnly
    }
}
