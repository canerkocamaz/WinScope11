# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 227
    Name        = 'Third-Party Driver Package Inventory'
    Group       = 'Device Security & Driver Integrity'
    GroupId     = 21
    Flags       = '[R][S]'
    Description = 'Reports PnP driver packages using pnputil.'
    Adapter     = 'AuditCompat300'
    CompatId    = 227
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
