# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 51
    Name        = 'Xbox Game Bar and Capture Storage'
    Group       = 'Applications & Caches'
    GroupId     = 5
    Flags       = '[R][S]'
    Description = 'Reports Game DVR state and the local Videos\Captures footprint.'
    Adapter     = 'AuditCompat300'
    CompatId    = 51
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
