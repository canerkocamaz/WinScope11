# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 64
    Name        = 'Microsoft Teams Cache Analyzer'
    Group       = 'Applications & Caches'
    GroupId     = 5
    Flags       = '[R][S]'
    Description = 'Measures classic and new Teams local cache/data locations.'
    Adapter     = 'AuditCompat300'
    CompatId    = 64
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
