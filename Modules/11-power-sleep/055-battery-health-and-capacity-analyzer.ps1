# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 55
    Name        = 'Battery Health and Capacity Analyzer'
    Group       = 'Power & Sleep'
    GroupId     = 11
    Flags       = '[R][S]'
    Description = 'Estimates battery wear from Windows firmware-reported design/full-charge capacity.'
    Adapter     = 'AuditCompat300'
    CompatId    = 55
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
