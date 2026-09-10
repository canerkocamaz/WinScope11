# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 65
    Name        = 'Browser Profile Analyzer'
    Group       = 'Applications & Caches'
    GroupId     = 5
    Flags       = '[R][S]'
    Description = 'Measures and dates Edge, Chrome and Firefox profiles separately from cache analysis.'
    Adapter     = 'AuditCompat300'
    CompatId    = 65
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
