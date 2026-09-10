# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 75
    Name        = 'Large Duplicate Files Analyzer'
    Group       = 'Disk & Storage'
    GroupId     = 1
    Flags       = '[R][S]'
    Description = 'Uses size grouping plus SHA256 to confirm content-identical 50MB+ files.'
    Adapter     = 'AuditCompat300'
    CompatId    = 75
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
