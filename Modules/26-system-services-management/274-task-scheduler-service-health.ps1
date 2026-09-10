# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 274
    Name        = 'Task Scheduler Service Health'
    Group       = 'System Services & Management'
    GroupId     = 26
    Flags       = '[R][S]'
    Description = 'Reports Task Scheduler service state.'
    Adapter     = 'AuditCompat300'
    CompatId    = 274
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
