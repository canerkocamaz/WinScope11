# WinScope 11 native module
[pscustomobject]@{
    Id                = 363
    Name              = 'Device Guard Security Properties'
    Group             = 'Advanced Boot, UEFI & Firmware Security'
    GroupId           = 32
    Flags             = '[R][N]'
    Description       = 'Reports detailed Device Guard/VBS properties.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {$d=Get-CimInstance -Namespace 'root\Microsoft\Windows\DeviceGuard' -ClassName Win32_DeviceGuard -ErrorAction Stop;& $Context.NewFinding 'FirmwareSecurity' 'Device Guard' 'Info' ("VBS={0}; Required={1}; Available={2}; Configured={3}; Running={4}" -f $d.VirtualizationBasedSecurityStatus,($d.RequiredSecurityProperties -join ','),($d.AvailableSecurityProperties -join ','),($d.SecurityServicesConfigured -join ','),($d.SecurityServicesRunning -join ',')) 'Interpret with the Windows build and security baseline.' $null}catch{& $Context.NewFinding 'FirmwareSecurity' 'Device Guard' 'Unavailable' $_.Exception.Message 'DeviceGuard WMI may be unavailable.' $null}
    }
}
