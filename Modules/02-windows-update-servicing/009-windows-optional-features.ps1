# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 9
    Name        = 'Windows Optional Features'
    Group       = 'Windows Update & Servicing'
    GroupId     = 2
    Flags       = '[R][A][S]'
    Description = 'Lists Windows optional features that may deserve review.'
    Adapter     = 'AuditCompat300'
    CompatId    = 9
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
