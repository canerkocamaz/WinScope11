# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 91
    Name        = 'Windows Update History'
    Group       = 'Windows Update & Servicing'
    GroupId     = 2
    Flags       = '[R][S]'
    Description = 'Shows recent Windows Update results and repeated failure candidates.'
    Adapter     = 'AuditCompat300'
    CompatId    = 91
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
