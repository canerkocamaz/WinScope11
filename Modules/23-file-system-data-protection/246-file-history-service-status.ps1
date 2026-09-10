# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 246
    Name        = 'File History Service Status'
    Group       = 'File System & Data Protection'
    GroupId     = 23
    Flags       = '[R][S]'
    Description = 'Reports File History service state.'
    Adapter     = 'AuditCompat300'
    CompatId    = 246
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
