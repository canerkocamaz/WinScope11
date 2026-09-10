# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 17
    Name        = 'Appx Package Health'
    Group       = 'Applications & Caches'
    GroupId     = 5
    Flags       = '[R][A][S]'
    Description = 'Checks Appx package health without touching WindowsApps directly.'
    Adapter     = 'AuditCompat300'
    CompatId    = 17
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
