# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 45
    Name        = 'Windows Maintenance Logs'
    Group       = 'Diagnostics & Reliability'
    GroupId     = 12
    Flags       = '[R][A][S]'
    Description = 'Measures CBS, DISM, MoSetup and Panther servicing/setup logs.'
    Adapter     = 'AuditCompat300'
    CompatId    = 45
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
