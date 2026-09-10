# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 119
    Name        = 'BITS Service Health'
    Group       = 'Windows Update & Servicing'
    GroupId     = 2
    Flags       = '[R][S]'
    Description = 'Reports Background Intelligent Transfer Service health.'
    Adapter     = 'AuditCompat300'
    CompatId    = 119
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
