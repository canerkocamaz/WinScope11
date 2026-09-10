# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 104
    Name        = 'Volume Mount Points'
    Group       = 'Storage Internals'
    GroupId     = 15
    Flags       = '[R][S]'
    Description = 'Reports Windows volume mount points and volume metadata.'
    Adapter     = 'AuditCompat300'
    CompatId    = 104
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
