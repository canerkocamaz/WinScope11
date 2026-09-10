# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 11
    Name        = 'Bluetooth Device Inventory'
    Group       = 'Devices & Drivers'
    GroupId     = 9
    Flags       = '[R][S]'
    Description = 'Lists Bluetooth PnP devices for manual review.'
    Adapter     = 'AuditCompat300'
    CompatId    = 11
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
