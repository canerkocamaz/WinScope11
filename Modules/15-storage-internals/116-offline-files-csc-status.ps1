# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 116
    Name        = 'Offline Files / CSC Status'
    Group       = 'Storage Internals'
    GroupId     = 15
    Flags       = '[R][S]'
    Description = 'Reports Offline Files service state.'
    Adapter     = 'AuditCompat300'
    CompatId    = 116
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
