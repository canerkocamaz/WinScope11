# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 59
    Name        = 'Microsoft Defender Health'
    Group       = 'Windows Security'
    GroupId     = 7
    Flags       = '[R][S]'
    Description = 'Reports real-time protection, signature age, engine and scan information.'
    Adapter     = 'AuditCompat300'
    CompatId    = 59
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
