# WinScope 11 native module
[pscustomobject]@{
    Id                = 374
    Name              = 'Hypervisor Presence Cross-Check'
    Group             = 'Advanced Boot, UEFI & Firmware Security'
    GroupId           = 32
    Flags             = '[R][N]'
    Description       = 'Reports whether Windows currently detects a hypervisor.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $false
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {$c=Get-CimInstance Win32_ComputerSystem -ErrorAction Stop;& $Context.NewFinding 'FirmwareSecurity' 'Hypervisor' $(if($c.HypervisorPresent){'Present'}else{'NotPresent'}) ("Manufacturer={0}; Model={1}" -f $c.Manufacturer,$c.Model) 'Hypervisor presence can result from Hyper-V, VBS or other virtualization.' $null}catch{& $Context.NewFinding 'FirmwareSecurity' 'Hypervisor' 'Unavailable' $_.Exception.Message 'CIM access failed.' $null}
    }
}
