# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 82
    Name        = 'LSA Protection'
    Group       = 'Windows Security'
    GroupId     = 7
    Flags       = '[R][A][S]'
    Description = 'Reports RunAsPPL/LSA protection registry state without changing it.'
    Adapter     = 'AuditCompat300'
    CompatId    = 82
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
