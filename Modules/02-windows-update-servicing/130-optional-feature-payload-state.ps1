# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 130
    Name        = 'Optional Feature Payload State'
    Group       = 'Windows Update & Servicing'
    GroupId     = 2
    Flags       = '[R][A][S]'
    Description = 'Reports optional features whose payload has been removed.'
    Adapter     = 'AuditCompat300'
    CompatId    = 130
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
