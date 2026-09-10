# WinScope 11 native module
[pscustomobject]@{
    Id                = 367
    Name              = 'BIOS and UEFI Firmware Inventory'
    Group             = 'Advanced Boot, UEFI & Firmware Security'
    GroupId           = 32
    Flags             = '[R][N]'
    Description       = 'Reports BIOS/UEFI vendor, version, serial and release date.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $false
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {$b=Get-CimInstance Win32_BIOS -ErrorAction Stop;& $Context.NewFinding 'FirmwareSecurity' $b.Name 'Info' ("Manufacturer={0}; Version={1}; ReleaseDate={2}; Serial={3}" -f $b.Manufacturer,$b.SMBIOSBIOSVersion,$b.ReleaseDate,$b.SerialNumber) 'Compare firmware with OEM advisories and supported update channels.' $null}catch{& $Context.NewFinding 'FirmwareSecurity' 'BIOS/UEFI' 'Unavailable' $_.Exception.Message 'CIM access failed.' $null}
    }
}
