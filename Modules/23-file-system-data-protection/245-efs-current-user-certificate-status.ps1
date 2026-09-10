# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 245
    Name        = 'EFS Current User Certificate Status'
    Group       = 'File System & Data Protection'
    GroupId     = 23
    Flags       = '[R][S]'
    Description = 'Reports the current-user EFS certificate.'
    Adapter     = 'AuditCompat300'
    CompatId    = 245
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
