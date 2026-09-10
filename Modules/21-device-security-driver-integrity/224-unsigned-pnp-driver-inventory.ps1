# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 224
    Name        = 'Unsigned PnP Driver Inventory'
    Group       = 'Device Security & Driver Integrity'
    GroupId     = 21
    Flags       = '[R][S]'
    Description = 'Reports unsigned PnP signed-driver records.'
    Adapter     = 'AuditCompat300'
    CompatId    = 224
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
