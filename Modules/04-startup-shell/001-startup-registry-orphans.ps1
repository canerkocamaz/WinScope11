# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 1
    Name        = 'Startup Registry Orphans'
    Group       = 'Startup & Shell'
    GroupId     = 4
    Flags       = '[R][S]'
    Description = 'Validates Run entries and reports missing or unresolved executable targets.'
    Adapter     = 'AuditCompat300'
    CompatId    = 1
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
