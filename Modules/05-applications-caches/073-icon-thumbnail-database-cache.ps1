# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 73
    Name        = 'Icon & Thumbnail Database Cache'
    Group       = 'Applications & Caches'
    GroupId     = 5
    Flags       = '[R][S]'
    Description = 'Measures Explorer iconcache/thumbcache database footprint without deleting active databases.'
    Adapter     = 'AuditCompat300'
    CompatId    = 73
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
