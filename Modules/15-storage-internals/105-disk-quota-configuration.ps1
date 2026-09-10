# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 105
    Name        = 'Disk Quota Configuration'
    Group       = 'Storage Internals'
    GroupId     = 15
    Flags       = '[R][A][S]'
    Description = 'Reports NTFS quota configuration for the system volume.'
    Adapter     = 'AuditCompat300'
    CompatId    = 105
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
