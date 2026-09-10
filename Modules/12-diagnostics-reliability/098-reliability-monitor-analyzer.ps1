# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 98
    Name        = 'Reliability Monitor Analyzer'
    Group       = 'Diagnostics & Reliability'
    GroupId     = 12
    Flags       = '[R][S]'
    Description = 'Shows recent Windows reliability records for recurring application/hardware failures.'
    Adapter     = 'AuditCompat300'
    CompatId    = 98
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
