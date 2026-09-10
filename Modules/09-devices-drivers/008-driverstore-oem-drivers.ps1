# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 8
    Name        = 'DriverStore / OEM Drivers'
    Group       = 'Devices & Drivers'
    GroupId     = 9
    Flags       = '[R][A][S]'
    Description = 'Reports DriverStore size and PnP driver inventory without deleting drivers.'
    Adapter     = 'AuditCompat300'
    CompatId    = 8
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
