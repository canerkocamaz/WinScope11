# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 243
    Name        = 'NTFS Last Access Timestamp Policy'
    Group       = 'File System & Data Protection'
    GroupId     = 23
    Flags       = '[R][S]'
    Description = 'Reports NTFS last-access timestamp policy.'
    Adapter     = 'AuditCompat300'
    CompatId    = 243
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
