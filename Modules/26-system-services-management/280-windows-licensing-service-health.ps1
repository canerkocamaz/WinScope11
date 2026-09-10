# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 280
    Name        = 'Windows Licensing Service Health'
    Group       = 'System Services & Management'
    GroupId     = 26
    Flags       = '[R][S]'
    Description = 'Reports Windows licensing-related services.'
    Adapter     = 'AuditCompat300'
    CompatId    = 280
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
