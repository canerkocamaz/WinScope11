# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 16
    Name        = '.NET Framework Inventory'
    Group       = 'Applications & Caches'
    GroupId     = 5
    Flags       = '[R][S]'
    Description = 'Reports installed .NET Framework registrations.'
    Adapter     = 'AuditCompat300'
    CompatId    = 16
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
