# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 275
    Name        = 'BITS Service Health'
    Group       = 'System Services & Management'
    GroupId     = 26
    Flags       = '[R][S]'
    Description = 'Reports Background Intelligent Transfer Service state.'
    Adapter     = 'AuditCompat300'
    CompatId    = 275
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
