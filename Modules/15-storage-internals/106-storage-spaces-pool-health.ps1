# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 106
    Name        = 'Storage Spaces Pool Health'
    Group       = 'Storage Internals'
    GroupId     = 15
    Flags       = '[R][S]'
    Description = 'Reports Storage Spaces pool health and allocation.'
    Adapter     = 'AuditCompat300'
    CompatId    = 106
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
