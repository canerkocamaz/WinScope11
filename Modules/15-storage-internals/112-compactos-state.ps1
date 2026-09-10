# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 112
    Name        = 'CompactOS State'
    Group       = 'Storage Internals'
    GroupId     = 15
    Flags       = '[R][S]'
    Description = 'Reports whether CompactOS is active.'
    Adapter     = 'AuditCompat300'
    CompatId    = 112
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
