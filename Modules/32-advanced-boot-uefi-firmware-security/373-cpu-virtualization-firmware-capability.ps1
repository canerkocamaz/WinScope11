# WinScope 11 native module
[pscustomobject]@{
    Id                = 373
    Name              = 'CPU Virtualization Firmware Capability'
    Group             = 'Advanced Boot, UEFI & Firmware Security'
    GroupId           = 32
    Flags             = '[R][N]'
    Description       = 'Reports CPU virtualization and SLAT capability.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $false
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {$c=Get-CimInstance Win32_Processor -ErrorAction Stop|Select-Object -First 1;& $Context.NewFinding 'FirmwareSecurity' $c.Name 'Info' ("VirtualizationFirmwareEnabled={0}; SLAT={1}; VMMonitor={2}" -f $c.VirtualizationFirmwareEnabled,$c.SecondLevelAddressTranslationExtensions,$c.VMMonitorModeExtensions) 'These capabilities support Hyper-V and VBS.' $null}catch{& $Context.NewFinding 'FirmwareSecurity' 'CPU virtualization' 'Unavailable' $_.Exception.Message 'CIM access failed.' $null}
    }
}
