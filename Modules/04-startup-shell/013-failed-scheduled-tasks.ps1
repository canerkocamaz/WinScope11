# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 13
    Name        = 'Failed Scheduled Tasks'
    Group       = 'Startup & Shell'
    GroupId     = 4
    Flags       = '[R][S]'
    Description = 'Reports scheduled tasks whose last run returned a non-zero result.'
    Adapter     = 'AuditCompat300'
    CompatId    = 13
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
