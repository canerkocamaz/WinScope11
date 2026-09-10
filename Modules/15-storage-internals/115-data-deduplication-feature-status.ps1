# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 115
    Name        = 'Data Deduplication Feature Status'
    Group       = 'Storage Internals'
    GroupId     = 15
    Flags       = '[R][S]'
    Description = 'Reports Data Deduplication feature availability/state.'
    Adapter     = 'AuditCompat300'
    CompatId    = 115
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
