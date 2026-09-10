# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 67
    Name        = 'Ghost USB / Storage Device Inventory'
    Group       = 'Devices & Drivers'
    GroupId     = 9
    Flags       = '[R][A][S]'
    Description = 'Reports likely non-present USB/storage PnP devices without removing them.'
    Adapter     = 'AuditCompat300'
    CompatId    = 67
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
