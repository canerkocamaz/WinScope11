# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 117
    Name        = 'Windows Update Policy'
    Group       = 'Windows Update & Servicing'
    GroupId     = 2
    Flags       = '[R][S]'
    Description = 'Reports Windows Update policy values.'
    Adapter     = 'AuditCompat300'
    CompatId    = 117
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
