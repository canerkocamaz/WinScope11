# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 129
    Name        = 'Pending Servicing Files'
    Group       = 'Windows Update & Servicing'
    GroupId     = 2
    Flags       = '[R][A][S]'
    Description = 'Checks for common pending servicing XML artifacts.'
    Adapter     = 'AuditCompat300'
    CompatId    = 129
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
