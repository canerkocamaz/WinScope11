# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 225
    Name        = 'Problem PnP Devices'
    Group       = 'Device Security & Driver Integrity'
    GroupId     = 21
    Flags       = '[R][S]'
    Description = 'Reports devices with problem/error state.'
    Adapter     = 'AuditCompat300'
    CompatId    = 225
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
