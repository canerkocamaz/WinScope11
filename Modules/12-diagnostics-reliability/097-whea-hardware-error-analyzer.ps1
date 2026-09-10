# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 97
    Name        = 'WHEA Hardware Error Analyzer'
    Group       = 'Diagnostics & Reliability'
    GroupId     = 12
    Flags       = '[R][A][S]'
    Description = 'Reviews recent WHEA-Logger hardware-error events from the System log.'
    Adapter     = 'AuditCompat300'
    CompatId    = 97
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $true
    ReportOnlyDefault = $true
}
