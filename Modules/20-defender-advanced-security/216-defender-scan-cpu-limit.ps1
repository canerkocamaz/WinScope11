# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 216
    Name        = 'Defender Scan CPU Limit'
    Group       = 'Defender Advanced Security'
    GroupId     = 20
    Flags       = '[R][S]'
    Description = 'Reports Defender scan CPU/performance settings.'
    Adapter     = 'AuditCompat300'
    CompatId    = 216
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
