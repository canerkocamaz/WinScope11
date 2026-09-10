# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 68
    Name        = 'Scheduled Task Orphan Actions'
    Group       = 'Startup & Shell'
    GroupId     = 4
    Flags       = '[R][A][S]'
    Description = 'Finds scheduled-task executable targets that are confirmed missing.'
    Adapter     = 'AuditCompat300'
    CompatId    = 68
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
