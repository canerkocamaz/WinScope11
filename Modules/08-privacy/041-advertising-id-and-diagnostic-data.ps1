# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 41
    Name        = 'Advertising ID and Diagnostic Data'
    Group       = 'Privacy'
    GroupId     = 8
    Flags       = '[R][S]'
    Description = 'Reports Advertising ID and diagnostic-data policy values without changing them.'
    Adapter     = 'AuditCompat300'
    CompatId    = 41
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
