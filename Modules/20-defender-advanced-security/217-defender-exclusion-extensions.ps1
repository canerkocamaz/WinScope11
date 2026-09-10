# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 217
    Name        = 'Defender Exclusion Extensions'
    Group       = 'Defender Advanced Security'
    GroupId     = 20
    Flags       = '[R][S]'
    Description = 'Reports excluded file extensions.'
    Adapter     = 'AuditCompat300'
    CompatId    = 217
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
