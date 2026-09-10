# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 102
    Name        = 'NTFS Compression State'
    Group       = 'Storage Internals'
    GroupId     = 15
    Flags       = '[R][S]'
    Description = 'Reports compression state on the system drive.'
    Adapter     = 'AuditCompat300'
    CompatId    = 102
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
