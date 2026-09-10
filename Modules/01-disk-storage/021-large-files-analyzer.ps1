# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 21
    Name        = 'Large Files Analyzer'
    Group       = 'Disk & Storage'
    GroupId     = 1
    Flags       = '[R][S]'
    Description = 'Searches user data for very large, old files without deleting them.'
    Adapter     = 'AuditCompat300'
    CompatId    = 21
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
