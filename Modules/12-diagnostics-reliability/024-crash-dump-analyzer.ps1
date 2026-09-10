# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 24
    Name        = 'Crash Dump Analyzer'
    Group       = 'Diagnostics & Reliability'
    GroupId     = 12
    Flags       = '[R][S]'
    Description = 'Finds old application crash dumps and previews cleanup candidates.'
    Adapter     = 'AuditCompat300'
    CompatId    = 24
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
