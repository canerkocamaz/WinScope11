# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 83
    Name        = 'Microsoft Defender SmartScreen'
    Group       = 'Windows Security'
    GroupId     = 7
    Flags       = '[R][S]'
    Description = 'Reports common SmartScreen policy and user configuration values.'
    Adapter     = 'AuditCompat300'
    CompatId    = 83
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
