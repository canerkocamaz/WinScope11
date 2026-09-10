# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 120
    Name        = 'Windows Update Service Health'
    Group       = 'Windows Update & Servicing'
    GroupId     = 2
    Flags       = '[R][S]'
    Description = 'Reports Windows Update service health.'
    Adapter     = 'AuditCompat300'
    CompatId    = 120
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
