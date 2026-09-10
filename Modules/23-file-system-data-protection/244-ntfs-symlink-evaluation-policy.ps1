# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 244
    Name        = 'NTFS Symlink Evaluation Policy'
    Group       = 'File System & Data Protection'
    GroupId     = 23
    Flags       = '[R][S]'
    Description = 'Reports symbolic-link evaluation policy.'
    Adapter     = 'AuditCompat300'
    CompatId    = 244
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
