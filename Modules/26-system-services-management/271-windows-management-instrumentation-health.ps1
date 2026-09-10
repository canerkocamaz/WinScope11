# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 271
    Name        = 'Windows Management Instrumentation Health'
    Group       = 'System Services & Management'
    GroupId     = 26
    Flags       = '[R][S]'
    Description = 'Reports Winmgmt service state.'
    Adapter     = 'AuditCompat300'
    CompatId    = 271
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
