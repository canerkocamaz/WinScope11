# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 23
    Name        = 'Recycle Bin Analyzer'
    Group       = 'Disk & Storage'
    GroupId     = 1
    Flags       = '[R][S]'
    Description = 'Reports Recycle Bin usage and asks before emptying it.'
    Adapter     = 'AuditCompat300'
    CompatId    = 23
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
