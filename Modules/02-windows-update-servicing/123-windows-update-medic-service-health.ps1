# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 123
    Name        = 'Windows Update Medic Service Health'
    Group       = 'Windows Update & Servicing'
    GroupId     = 2
    Flags       = '[R][S]'
    Description = 'Reports Windows Update Medic service state.'
    Adapter     = 'AuditCompat300'
    CompatId    = 123
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
