# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 241
    Name        = 'Win32 Long Path Support'
    Group       = 'File System & Data Protection'
    GroupId     = 23
    Flags       = '[R][S]'
    Description = 'Reports Win32 long-path support.'
    Adapter     = 'AuditCompat300'
    CompatId    = 241
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
