# WinScope 11 native module
[pscustomobject]@{
    Id                = 361
    Name              = 'Firmware Type Detection'
    Group             = 'Advanced Boot, UEFI & Firmware Security'
    GroupId           = 32
    Flags             = '[R][N]'
    Description       = 'Reports firmware mode from Windows computer information'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $false
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {$x=Get-ComputerInfo -Property BiosFirmwareType -ErrorAction Stop;& $Context.NewFinding 'FirmwareSecurity' 'Firmware type' 'Info' ("BiosFirmwareType={0}" -f $x.BiosFirmwareType) 'UEFI is required for many modern Windows platform-security features.' $null}catch{& $Context.NewFinding 'FirmwareSecurity' 'Firmware type' 'Unavailable' $_.Exception.Message 'Get-ComputerInfo failed.' $null}
    }
}
