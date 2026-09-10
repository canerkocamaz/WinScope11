# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 46
    Name        = 'Volume Space and File System Health'
    Group       = 'Disk & Storage'
    GroupId     = 1
    Flags       = '[R][S]'
    Description = 'Reports free-space percentage and Windows volume health information.'
    Adapter     = 'AuditCompat300'
    CompatId    = 46
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
