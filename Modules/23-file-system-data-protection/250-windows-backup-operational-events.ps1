# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 250
    Name        = 'Windows Backup Operational Events'
    Group       = 'File System & Data Protection'
    GroupId     = 23
    Flags       = '[R][S]'
    Description = 'Reports recent Windows backup events.'
    Adapter     = 'AuditCompat300'
    CompatId    = 250
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
