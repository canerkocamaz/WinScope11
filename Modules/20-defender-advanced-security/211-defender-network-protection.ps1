# WinScope 11 module descriptor
[pscustomobject]@{
    Id          = 211
    Name        = 'Defender Network Protection'
    Group       = 'Defender Advanced Security'
    GroupId     = 20
    Flags       = '[R][S]'
    Description = 'Reports Microsoft Defender Network Protection state.'
    Adapter     = 'AuditCompat300'
    CompatId    = 211
    Risk        = 'ReportOnly'
    CleanupCapable = $false
    AdminHint      = $false
    ReportOnlyDefault = $true
}
