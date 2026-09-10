# WinScope 11 native module
[pscustomobject]@{
    Id                = 366
    Name              = 'TPM Device Information'
    Group             = 'Advanced Boot, UEFI & Firmware Security'
    GroupId           = 32
    Flags             = '[R][N]'
    Description       = 'Reports TPM device information through tpmtool.'
    Adapter           = 'Native'
    Risk              = 'ReportOnly'
    CleanupCapable    = $false
    AdminHint         = $true
    ReportOnlyDefault = $true
    Invoke            = {
        param($Context)
        & $Context.CommandSnapshot 'FirmwareSecurity' 'TPM device information' 'tpmtool.exe' @('getdeviceinformation') 'TPM information is report-only; no provisioning is performed.'
    }
}
