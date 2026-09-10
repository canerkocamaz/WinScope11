# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 19
    Name        = 'Large Event Logs'
    Group       = 'Diagnostics & Reliability'
    GroupId     = 12
    Flags       = '[R][A][S]'
    Description = 'Finds unusually large Windows event logs.'
    Adapter     = 'AuditCompat300'
    CompatId    = 19
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
