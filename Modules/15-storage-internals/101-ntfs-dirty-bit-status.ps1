# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 101
    Name        = 'NTFS Dirty Bit Status'
    Group       = 'Storage Internals'
    GroupId     = 15
    Flags       = '[R][S]'
    Description = 'Checks fixed volumes for the NTFS dirty bit.'
    Adapter     = 'AuditCompat300'
    CompatId    = 101
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
