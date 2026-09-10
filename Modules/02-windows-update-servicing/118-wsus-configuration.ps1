# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 118
    Name        = 'WSUS Configuration'
    Group       = 'Windows Update & Servicing'
    GroupId     = 2
    Flags       = '[R][S]'
    Description = 'Reports WSUS and Automatic Update policy configuration.'
    Adapter     = 'AuditCompat300'
    CompatId    = 118
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
