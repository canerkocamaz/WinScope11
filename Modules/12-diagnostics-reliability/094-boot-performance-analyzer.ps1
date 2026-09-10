# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 94
    Name        = 'Boot Performance Analyzer'
    Group       = 'Diagnostics & Reliability'
    GroupId     = 12
    Flags       = '[R][S]'
    Description = 'Reads recent Diagnostics-Performance boot events and boot-duration metrics.'
    Adapter     = 'AuditCompat300'
    CompatId    = 94
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
