# WinScope 11 native module
[pscustomobject]@{
    Id                = 378
    Name              = 'Kernel DMA Policy Snapshot'
    Group             = 'Advanced Boot, UEFI & Firmware Security'
    GroupId           = 32
    Flags             = '[R][N]'
    Description       = 'Reports DMA Guard related policy values.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.RegistrySnapshot 'FirmwareSecurity' 'DMA Guard policy' 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Kernel DMA Protection' @('DeviceEnumerationPolicy') 'DMA protection depends on firmware, hardware and policy.'
    }
}
