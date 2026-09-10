# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 114
    Name        = 'ReFS Volume Inventory'
    Group       = 'Storage Internals'
    GroupId     = 15
    Flags       = '[R][S]'
    Description = 'Reports any ReFS volumes.'
    Adapter     = 'AuditCompat300'
    CompatId    = 114
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
