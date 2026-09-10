# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 249
    Name        = 'System Restore Configuration'
    Group       = 'File System & Data Protection'
    GroupId     = 23
    Flags       = '[R][S]'
    Description = 'Reports System Restore policy/settings.'
    Adapter     = 'AuditCompat300'
    CompatId    = 249
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
