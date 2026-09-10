# WinScope 11 native module
[pscustomobject]@{
    Id                = 368
    Name              = 'Baseboard Identity'
    Group             = 'Advanced Boot, UEFI & Firmware Security'
    GroupId           = 32
    Flags             = '[R][N]'
    Description       = 'Reports system baseboard identity for firmware correlation.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $false
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        try {$b=Get-CimInstance Win32_BaseBoard -ErrorAction Stop;& $Context.NewFinding 'FirmwareSecurity' 'Baseboard' 'Info' ("Manufacturer={0}; Product={1}; Version={2}; Serial={3}" -f $b.Manufacturer,$b.Product,$b.Version,$b.SerialNumber) 'Use board identity to correlate vendor firmware support.' $null}catch{& $Context.NewFinding 'FirmwareSecurity' 'Baseboard' 'Unavailable' $_.Exception.Message 'CIM access failed.' $null}
    }
}
